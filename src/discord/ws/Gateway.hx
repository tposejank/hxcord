package discord.ws;

import discord.types.Intents;
import discord.utils.events.GatewayResetEvent;
import discord.utils.log.Log;
import discord.utils.events.GatewayReceiveEvent;
import haxe.ws.Types.MessageType;
import discord.ws.tools.Opcodes;
import discord.ws.tools.Payload;
import discord.ws.tools.Payload.HeartbeatPayload;
import discord.ws.tools.Payload.IdentifyPayload;
import discord.ws.tools.Payload.ResumePayload;
import haxe.ws.WebSocket;
import haxe.Json;

enum abstract GatewayEvent(String) from String to String {
    var GATEWAY_RECEIVE_EVENT = 'GATEWAY_RECEIVE_EVENT';
    var GATEWAY_RESET_EVENT = 'GATEWAY_RESET_EVENT';
}

/**
 * This class is based on
 * https://github.com/SanicBTW/HxDiscordGateway/blob/master/source/discord/Gateway.hx
 */
class Gateway extends discord.utils.events.EventDispatcher {
	var ticked:Bool = false;
    private var ws:WebSocket;

    var hb_timer:haxe.Timer;

    /**
     * The token to access the Gateway. It is not recommended to share.
     */
    private var _token:String = null;

    /**
     * Internal tracker for the Gateway be initialized or not.
     */
    private var initialized:Bool = false;

    // Gateway connection parameters

    /**
     * The sequence number of the events sent & received via the gateway.
     */
    private var _lastSequenceNum:Int = null;

    private var _sessionID:String = null;

    /**
     * The resume URL, received in the `READY` event (Opcode 0)
     */
    private var resumeURL:String = null;

    #if html5
    /**
     * Error codes for HTML5 to ignore.
     */
    private var blacklistedErrors:Array<Int> = [4004, 4010, 4011, 4012, 4013, 4014];
    #end

    /**
     * The ammount of time to pass between each Heartbeat
     * 
     * Received in the `HELLO` event (Opcode 10) 
     * Keep-Alive
     */
    private var heartbeatDelay:Int = 0; // MS

    /**
     * Unix timestamp of the last heartbeat (1) sent.
     */
    private var lastHeartbeatSent:Float = 0;

    /**
     * Unix timestamp of the last heartbeat (11) received.
     */
    private var lastHeartbeatAckReceived:Float = 0;

    /**
     * Measures latency between a HEARTBEAT and a HEARTBEAT_ACK in seconds.
     */
    public var latency(get, never):Float;

    public var intents:Intents;

    /**
     * Initialize the Gateway
     * @param token The application token
     */
    public function new(token:String, intents:Intents) {
        this._token = token;
        this.intents = intents;
        super();
    }

    /**
     * Initialize the `WebSocket`.
     */
    public function initializeWebsocket(url:String = "wss://gateway.discord.gg/?v=10&encoding=json"):Void {
        #if sys
        sys.ssl.Socket.DEFAULT_VERIFY_CERT = false;
        #end

        if (ws != null) this.dispatchEvent(new GatewayResetEvent());

        ws = new WebSocket(url);
        addListeners();
    }

    /**
     * Forcibly shut down the WebSocket.
     */
    public function shutDown():Void {
        ws.close();
    }

    function tick()
    {
        // trace('tick');
        // THIS IS SPAMMY
    }

    /**
     * This should be executed everytime the gateway is re-assigned
     */
    private function addListeners()
    {
        trace("Adding listeners to the new WebSocket client");

        // Listeners for start options
        ws.onopen = () ->
        {
            trace('Opened');
            initialized = true;
        }

        ws.onmessage = (daType:MessageType) -> {
            // dumb fix, but lets us send the Identify
            // even before ws.onopen() was called
            if (ws.state == Body && !initialized) {
                initialized = true;
            }

            switch (daType) {
                case StrMessage(content):
                    haxe.EntryPoint.runInMainThread(onMessage.bind(content));
                case BytesMessage(content):
                    trace(content);
                    // this is unused
            }
        }

        ws.onerror = (msg:String) ->
        {
            trace('[WS ERR] ${msg}');
        }

        ws.onclose = () ->
        {
            if (hb_timer != null) hb_timer.stop();
            initialized = false;
            trace('[WS CLS] Websocket was closed. Reconnect in progress');

            // Force close the client just in case
            ws.close();

            tryReconnection();
        }

        #if sys
        if (!ticked) {
            haxe.MainLoop.add(tick);
            ticked = true;
        }
        #end
    }

    /**
     * Called when the `WebSocket` receives a message from the Gateway.
     * Currently, `Opcodes` which are receivable are:
     * - `HEARTBEAT`: Fired periodically by the client to keep the connection alive.
     * - `RECONNECT`: You should attempt to reconnect and resume immediately.
     * - `INVALID_SESSION`: The session has been invalidated. You should reconnect and identify/resume accordingly.
     * - `HELLO`: Sent immediately after connecting *(to the Gateway)*, contains the `heartbeat_interval` to use.
     * - `HEARTBEAT_ACK`: Sent in response to receiving a heartbeat to acknowledge that it has been received.
     * @param msg Message (JSON content) sent by the Gateway
     */
    private function onMessage(msg:String) {
        // trace('         ${msg}');
        final json:Dynamic = Json.parse(msg);

        final data:Payload =
        {
            op: json.op,
            d: json.d,
            s: json.s,
            t: json.t
        };

        trace('Received ${data.op}');

        switch(data.op)
        {
            case HELLO:  
                heartbeatDelay = data.d.heartbeat_interval;

                // The App just started
                if (resumeURL == null) {
                    identify();

                    if (hb_timer != null) hb_timer.stop();
                    hb_timer = new haxe.Timer(heartbeatDelay);
                    hb_timer.run = () -> {
                        heartbeat();
                    }
                }
                else // The app is resuming from a Resume event
                {
                    heartbeat();
                    haxe.EntryPoint.runInMainThread(()->{
                        if (hb_timer != null) hb_timer.stop();
                        hb_timer = new haxe.Timer(heartbeatDelay);
                        hb_timer.run = () -> {
                            heartbeat();
                        }
                    });
                    
                    trace("Trying to reconnect from previous session");
                    var payload:ResumePayload = new ResumePayload(_token, _sessionID, _lastSequenceNum);
                    send(payload.toString());
                }

            case HEARTBEAT_ACK:
                lastHeartbeatAckReceived = Sys.time();
                trace(latency * 1000);
                trace('Acknowleged sent by Discord');

            case INVALID_SESSION:
                // Look into this properly
                // Because we have some cache we can straight up call the identify function, this only happens when trying to resume the previous session so we shouln't have a problem now
                trace("Re-identifying due to invalid session, probably thrown by the resume handler");
                identify();

            case RECONNECT:
                trace("Gateway wants to reconnect, trying to reconnect");
                tryReconnection();

            case DISPATCH:
                // apparently i only need to set the seq on this type of opcode
                _lastSequenceNum = data.s;

                switch (data.t)
                {
                    case "READY":
                        _sessionID = data.d.session_id;
                        resumeURL = data.d.resume_gateway_url;
                }

                var event:GatewayReceiveEvent = new GatewayReceiveEvent(data);
                this.dispatchEvent(event);

            default:
                trace(data);
                return;
        }
    }

    /**
     * Logs into the Gateway
     * Provided you have the token, you're good to go.
     */
    private function identify()
    {
        var payload:IdentifyPayload = new IdentifyPayload(_token, this.intents);

        // Can't access https://discord.com/api/v10/applications/ no more even with the auth token, Discord pls fix this

        send(payload.toString());
    }

    /**
     * Tries reconnecting to the Gateway,
     * usually called 
     */
    private function tryReconnection()
    {
        try 
        {
            #if html5
            // On HTML5 the argument is a CloseEvent 
            var e:js.html.CloseEvent = cast e;
    
            // run if it isnt blacklisted or if the exit was NOT clean
            if (!blacklistedErrors.contains(e.code) || !e.wasClean)
            {
                // re-initialize the gateway if the resume gateway url is null
                if (resumeURL == null)
                    initializeWebsocket();
                else
                    reconnect(); // try reconncting
            }
            #else
    
            // e is still unknown on other targets so we just going to ignore it lol
            if (resumeURL == null)
                initializeWebsocket();
            else
                reconnect(); // try reconncting
            #end
        }
        catch (ex)
        {
            trace('${ex}, Cannot reconnect');
            shutDown();
        }
    }

    // Reconnect / Resume the connection to the gateway in case we get disconnected from it
    private function reconnect()
    {
        trace('Trying to reconnect to ${resumeURL}');
        initializeWebsocket('${resumeURL}/?v=10&encoding=json');
    }

    // Keep-Alive
    private function heartbeat()
    {
        var payload:HeartbeatPayload = new HeartbeatPayload(_lastSequenceNum);
        if (ws.state == Closed)
        {
            trace('Failed to HeartBeat: Gateway is closed!');
            return;
        }

        trace("Heartbeat sent");
        lastHeartbeatSent = Sys.time();
        send(payload.toString());
    }

    private function send(data:String)
    {
        if (!initialized) {
            trace('WebSocket not initialized (Client-Denied Send)');
            return;
        } else {
            trace('Sending ${Json.parse(data)?.op ?? '?'}');
        }

        ws.send(data);
    }

    function get_latency():Float {
        return lastHeartbeatAckReceived - lastHeartbeatSent;
    }
}