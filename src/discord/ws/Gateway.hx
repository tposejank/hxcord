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
    private var _lastSequenceNum:Int;

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

    private var _weSentZeroToDiscord:Bool = false;

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
            // trace('Opened');
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
            Log.error('[WS ERR] ${msg}');
        }

        ws.onclose = (code:Int, message:String) ->
        {
            if (hb_timer != null) hb_timer.stop();
            initialized = false;
            Log.error('[WS CLS] Websocket closed with code $code');
            Log.error('[CL MSG] $message');

            // Force close the client just in case
            if (ws.state != Closed) {
                ws.close();
            }

            handleDisconnectCode(code, message);
        }

        #if sys
        if (!ticked) {
            haxe.MainLoop.add(tick);
            ticked = true;
        }
        #end
    }

    public function handleDisconnectCode(code:Int, message:String) {
        var shouldNotTryToReconnect:Bool = false; // just in case you try catched it...
        switch (code) {
            case 4000:
                Log.error('[CL VBS] Discord gave us an unknown error.');
            case 4001:
                Log.error('[CL VBS] We sent an invalid opcode?');
            case 4002:
                Log.error('[CL VBS] Discord couldn\'t decode our payload?');
            case 4003:
                if (_weSentZeroToDiscord) {
                    Log.error('[CL VBS] We sent a payload before identifying?');
                } else { 
                    Log.error('[CL VBS] The session has been invalidated.');
                }
            case 4004:
                throw 'Please provide a valid token.';
                shouldNotTryToReconnect = true; 
            case 4005:
                Log.error('[CL VBS] More than one Identify payload sent?');
            case 4007:
                Log.error('[CL VBS] Mismatch in sequence when resuming?');
            case 4008:
                Log.error('[CL VBS] We\'ve been rate limited...');
            case 4009:
                Log.error('[CL VBS] The session timed out.');
            case 4010:
                throw 'Invalid shard given when Identifying.';
                shouldNotTryToReconnect = true; 
            case 4011:
                throw 'You are required to shard your connection in order to connect.';
                shouldNotTryToReconnect = true; 
            case 4012:
                throw 'Invalid API version given to Gateway.';
                shouldNotTryToReconnect = true; 
            case 4013:
                throw 'Invalid intents.';
                shouldNotTryToReconnect = true; 
            case 4014:
                Log.error('[CL VBS] Please apply for the intents ${intents.value} if your bot has more than 100 guilds.');
                Log.error('[CL VBS] If it isn\'t, please enable it in the Developer Portal:');
                Log.error('[CL VBS] https://discord.com/developers/docs/topics/gateway#privileged-intents');
                throw 'Privileged intent provided, this intent is disallowed.';
                shouldNotTryToReconnect = true; 
        }

        if (!shouldNotTryToReconnect) {
            Log.info('[CL VBS] Reconnect in progress...');
            tryReconnection();
        }
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

            default:
                trace(data);
                return;
        }

        var event:GatewayReceiveEvent = new GatewayReceiveEvent(data);
        this.dispatchEvent(event);
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
     * Tries reconnecting to the Gateway
     */
    private function tryReconnection()
    {
        try 
        {
            // e is still unknown on other targets so we just going to ignore it lol
            if (resumeURL == null)
                initializeWebsocket();
            else {
                Log.info('Trying to reconnect on $resumeURL...');
                reconnect();
            }
        }
        catch (ex)
        {
            Log.error('${ex}, Cannot reconnect');
            shutDown();
        }
    }

    // Reconnect / Resume the connection to the gateway in case we get disconnected from it
    private function reconnect()
    {
        Log.info('Trying to reconnect to ${resumeURL}');
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
        var opcodeSent:Int = Json.parse(data)?.op ?? -1;

        if (opcodeSent == Opcodes.DISPATCH) _weSentZeroToDiscord = true;

        if (!initialized) {
            trace('WebSocket not initialized (Client-Denied Send)');
            return;
        } else {
            trace('Sending $opcodeSent');
        }

        ws.send(data);
    }

    function get_latency():Float {
        return lastHeartbeatAckReceived - lastHeartbeatSent;
    }
}