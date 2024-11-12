package discord;

import discord.utils.errors.GatewayErrors;
import discord.Flags.Intents;
import discord.utils.events.GatewayEvents;
import discord.log.Log;
import haxe.ws.Types.MessageType;
import haxe.ws.WebSocket;
import haxe.Json;

@:structInit
@:publicFields
class Payload
{
    var op:Opcodes;
    var d:Dynamic;
    var s:Null<Int> = null;
    var t:Null<String> = null;

    public function new(op:Opcodes, d:Dynamic, ?s:Null<Int>, ?t:Null<String>)
    {
        this.op = op;
        this.d = d;
        this.s = s;
        this.t = t;
    }

    public function toString()
    {
        return Json.stringify({
            op: this.op,
            d: this.d,
            s: this.s,
            t: this.t
        });
    }
}

/**
 * Implements a WebSocket for Discord's gateway version 10.
 * 
 * This class is based on
 * https://github.com/SanicBTW/HxDiscordGateway/blob/master/source/discord/Gateway.hx
 */
class Gateway extends discord.utils.events.EventDispatcher {
    private var ticked:Bool = false;

    /**
     * The WebSocket that maintains the connection with Discord's Gateway.
     */
    public var ws:WebSocket;

    /**
     * The timer for Heartbeat events.
     */
    public var hb_timer:haxe.Timer;

    /**
     * The token to access the Gateway. It is not recommended to share.
     */
    private var _token:String = null;

    /**
     * Internal tracker for the Gateway be initialized or not.
     */
    public var initialized:Bool = false;

    // Gateway connection parameters

    /**
     * The sequence number of the events sent & received via the gateway.
     */
    private var _last_sequence_num:Null<Int>;

    private var _session_id:String = null;

    /**
     * The resume URL, received in the `READY` event (Opcode 0)
     */
    public var resume_url:String = null;

    /**
     * The ammount of time to pass between each Heartbeat
     * 
     * Received in the `HELLO` event (Opcode 10) 
     */
    public var heartbeat_delay:Int = 0; // MS

    /**
     * Unix timestamp of the last heartbeat (1) sent.
     */
    public var last_heartbeat_sent:Float = 0;

    /**
     * Unix timestamp of the last heartbeat (11) received.
     */
    public var last_heartbeat_ack_received:Float = 0;

    /**
     * Measures latency between a HEARTBEAT and a HEARTBEAT_ACK in seconds.
     */
    public var latency(get, never):Float;

    /**
     * The intents of `this` gateway.
     */
    public var intents:Intents;

    /**
     * Whether to compress the connection or not. 
     * This value is only sent after an Identify is 
     * requested.
     */
    public var compress_connection:Bool = true;

    private var zero_sent:Bool = false;
    private var identified:Bool = false;

    /**
     * Initializes the Gateway.
     * @param token The application token.
     * @param intents The intents to log into the gateway with.
     */
    public function new(token:String, intents:Intents) {
        this._token = token;
        this.intents = intents;
        super();
    }

    /**
     * Initializes the `WebSocket`.
     * @param url The url to connect to.
     */
    public function initializeWebSocket(url:String = "wss://gateway.discord.gg/?v=10&encoding=json"):Void {
        #if sys
        sys.ssl.Socket.DEFAULT_VERIFY_CERT = false;
        #end

        identified = false;

        if (ws != null) {
            this.dispatchEvent(new GatewayReset());
            try { 
                ws.close(true);
                ws = null; 
                Log.debug('Successfully closed WebSocket');
            } catch (e) {
                Log.error('[HAXEWS] Could not close the WebSocket: $e');
            }
        }

        Log.debug('Connection starting at ${url}');
        ws = new WebSocket(url, false);
        addListeners();
    }

    /**
     * Shut down the WebSocket.
     */
    public function shutDown():Void {
        ws.close(true);
    }

    function tick() {}

    /**
     * This should be executed everytime the gateway is re-assigned
     */
    private function addListeners():Void
    {
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
                    haxe.EntryPoint.runInMainThread(on_message.bind(content));
                case BytesMessage(content):
                    // haxe.zip automatically uses zlib-flush
                    haxe.EntryPoint.runInMainThread(
                        on_message
                        .bind(haxe.zip.Uncompress.run(
                            content.readAllAvailableBytes()
                        ).toString())
                    );
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
            Log.error('[HAXEWS] WebSocket closed with code $code');
            Log.error('[DISCRD] $message');

            handle_disconnect_code(code, message);
        }

        #if sys
        if (!ticked) {
            haxe.MainLoop.add(tick);
            ticked = true;
        }
        #end

        try {
            ws.open();
        } catch (e) {
            Log.error('Unable to open the WebSocket: $e');
        }
    }

    /**
     * According to [this issue](https://github.com/discord/discord-api-docs/pull/7172#issue-2546244404), the close codes
     * `4001`, `4003`, `4004`, `4005`, `4007`, `4009`, `4010`, `4011`, `4012`, `4013` and `4014` CANNOT be resumed.
     */
    public function handle_disconnect_code(code:Int, message:String):Void {
        // should a reconnection not be attempted?
        var should_not_reconnect:Bool = false;
        // should resume be invalidated?
        var should_invalidate_resume:Bool = false;

        switch (code) {
            case 4000:
                Log.error('[HXCORD] Discord gave us an unknown error.');
            case 4001:
                Log.error('[HXCORD] We sent an invalid opcode.');
                should_invalidate_resume = true;
            case 4002:
                Log.error('[HXCORD] Discord couldn\'t decode our payload.');
            case 4003:
                if (zero_sent && !identified) 
                    Log.error('[HXCORD] Payload sent before identifying.');
                else 
                    Log.error('[HXCORD] The session has been invalidated.');

                should_invalidate_resume = true;
            case 4004:
                throw new GatewayUnauthorized('Please provide a valid token.');
                should_not_reconnect = true;
                should_invalidate_resume = true;
            case 4005:
                Log.error('[HXCORD] More than one Identify payload sent.');
                should_invalidate_resume = true;
            case 4007:
                Log.error('[HXCORD] Mismatch in sequence when resuming.');
                should_invalidate_resume = true;
            case 4008:
                Log.error('[HXCORD] Rate limit encountered.');
            case 4009:
                Log.error('[HXCORD] The session timed out.');
                should_invalidate_resume = true;
            case 4010:
                throw new GatewayShardRequired('Invalid shard given when Identifying.');
                should_not_reconnect = true; 
                should_invalidate_resume = true;
            case 4011:
                throw new GatewayShardRequired('You are required to shard your connection in order to connect.');
                should_not_reconnect = true; 
                should_invalidate_resume = true;
            case 4012:
                throw new GatewayInvalidParameters('Invalid API version given to Gateway.');
                should_not_reconnect = true; 
                should_invalidate_resume = true;
            case 4013:
                throw 'Invalid intents.';
                should_not_reconnect = true; 
                should_invalidate_resume = true;
            case 4014:
                Log.error('[HXCORD] Please apply for the intents ${intents.value} if your bot has more than 100 guilds.');
                Log.error('[HXCORD] If it is not in +100 guilds, please enable it in the Developer Portal:');
                Log.error('[HXCORD] https://discord.com/developers/docs/topics/gateway#privileged-intents');
                should_not_reconnect = true;
                should_invalidate_resume = true;
                throw new GatewayUnauthorized('Privileged intents ${intents.value} provided, these intents are disallowed.');
        }

        if (should_invalidate_resume) {
            invalidate_resume(); 
        }

        if (!should_not_reconnect) {
            Log.info('Reconnection started and in progress');
            try_reconnection();
        }
    }

    /**
     * Deletes all resume credentials and forces the client to resume when possible.
     * 
     * This will NOT close the connection, but rather have the client not resume the next time a connection is opened (and is resumable).
     */
    public function invalidate_resume():Void {
        this.resume_url = null;
        this._session_id = null;
        // start a new session
        this._last_sequence_num = null;
    }

    private function reinitialize_hb_timer():Void {
        haxe.EntryPoint.runInMainThread(()->{
            if (hb_timer != null) hb_timer.stop();
            hb_timer = new haxe.Timer(heartbeat_delay);
            hb_timer.run = () -> {
                heartbeat();
            }
        });
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
    private function on_message(msg:String) {
        final json:Dynamic = Json.parse(msg);

        final data:Payload =
        {
            op: json.op,
            d: json.d,
            s: json.s,
            t: json.t
        };

        Log.debug('Received ${data.op} ${data.t ?? ''}');
        Log.test(msg);

        switch(data.op)
        {
            case HELLO:  
                heartbeat_delay = data.d.heartbeat_interval;

                // No resume credentials available
                if (resume_url == null) {
                    identify();
                    heartbeat();
                    reinitialize_hb_timer();
                }
                else // The app is resuming from a Resume event
                {
                    Log.info("Trying to resume from previous session");
                    resume();
                    heartbeat();
                    reinitialize_hb_timer();
                }

            case HEARTBEAT_ACK:
                // measure latency
                last_heartbeat_ack_received = Sys.time();

            case INVALID_SESSION:
                // The invalid session is resumable!!
                if (data.d == true) {
                    // try to resume
                    Log.warn("Invalid session received but resumable.");
                } else {
                    Log.warn("Re-identifying due to invalid session");
                    // do NOT try to resume here
                    invalidate_resume();
                }
                try_reconnection();

            case RECONNECT:
                Log.info("Reconnect requested.");
                // do not let the server close on us
                try_reconnection(true);

            case DISPATCH:
                _last_sequence_num = data.s;

                switch (data.t)
                {
                    case "READY":
                        _session_id = data.d.session_id;
                        resume_url = data.d.resume_gateway_url;
                        identified = true;
                    case "RESUMED":
                        Log.info('Successfully resumed session');
                }
            
            case HEARTBEAT:
                Log.warn('Discord wants a heartbeat');
                heartbeat();

                Log.debug('Reinitializing the heartbeat timer');
                reinitialize_hb_timer();

            default:
                trace(data);
                return;
        }

        this.dispatchEvent(new GatewayReceive(data));
    }

    /**
     * Logs into the Gateway
     * Provided you have the token, you're good to go.
     */
    private function identify():Void
    {
        var payload:Payload = new Payload(IDENTIFY, {
            token: this._token, // token
            intents: this.intents.value,
            properties: {
                os: "Bot (hxcord)",
                browser: #if cpp "CPP" #elseif neko "Neko" #elseif hl "HashLink" #else "Unknown Haxe Target" #end,
                device: "Haxe - " + #if windows "Windows" #elseif macos "MacOS" #elseif linux "Linux" #else "Unknown Device" #end
            },
            large_threshold: 250,
            compress: compress_connection
        });

        send(payload.toString());
    }

    private function resume():Void
    {
        var payload:Payload = new Payload(RESUME, {
            token: this._token,
            session_id: this._session_id,
            seq: this._last_sequence_num
        });

        send(payload.toString());
    }

    /**
     * Tries reconnecting to the Gateway
     */
    private function try_reconnection(skip_wait:Bool = false)
    {
        if (!skip_wait) {
            Log.debug('Waiting 0.5s to handle the reconnection');
            Sys.sleep(0.5); // reduce spam
        }

        try 
        {
            if (resume_url == null)
                initializeWebSocket();
            else 
                reconnect();
        }
        catch (ex)
        {
            shutDown();
            throw new GatewayCantReconnect('Cannot reconnect: ${ex}');
        }
    }

    // Reconnect / Resume the connection to the gateway in case we get disconnected from it
    private function reconnect():Void
    {
        initializeWebSocket('${resume_url}/?v=10&encoding=json');
    }

    // Heartbeat, also known as the Keep-Alive
    private function heartbeat()
    {
        var payload:Payload = new Payload(HEARTBEAT, null, _last_sequence_num);
        if (ws.state == Closed)
        {
            Log.error('Cannot send a heartbeat when the Gateway is closed!');
            return;
        }

        last_heartbeat_sent = Sys.time();
        send(payload.toString());
    }

    private function send(data:String)
    {
        var opcode_sent:Int = Json.parse(data)?.op ?? -1;

        if (opcode_sent == Opcodes.DISPATCH) zero_sent = true;

        if (!initialized) {
            Log.error('WebSocket not initialized (Client-Denied Send)');
            return;
        }

        Log.debug('Sending ${opcode_sent}');

        Log.test(data);

        ws.send(data);
    }

    function get_latency():Float {
        return last_heartbeat_ack_received - last_heartbeat_sent;
    }

    public function request_chunks(guild_id:String, presences:Bool = true, limit:Int = 0) {
        var payload:Payload = new Payload(Opcodes.REQUEST_GUILD_MEMBERS, {
                guild_id: guild_id,
                presences: presences,
                limit: limit,
                query: ""
        });

        // if nonce:
        //     payload['d']['nonce'] = nonce

        // if user_ids:
        //     payload['d']['user_ids'] = user_ids

        // if query is not None:
        //     payload['d']['query'] = query

        send(haxe.Json.stringify(payload));
    }
}

/**
 * Represents each [Gateway Opcode](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes).
 * 
 * This class is from
 * https://github.com/SanicBTW/HxDiscordGateway/blob/master/source/discord/gateway/Opcodes.hx
 */
enum abstract Opcodes(Int) to Int
{
    /**
     * An event was dispatched.
     *
     * Client action: *Receive*
     */
    var DISPATCH = 0;

    /**
     * Fired periodically by the client to keep the connection alive.
     *
     * Client action: *Send* / *Receive*
     */
    var HEARTBEAT = 1;

    /**
     * Starts a new session during the initial handshake.
     *
     * Client action: *Send*
     */
    var IDENTIFY = 2;

    /**
     * Update the client's presence.
     *
     * Client action: *Send*
     */
    var PRESENCE_UPDATE = 3;

    /**
     * Used to join/leave or move between voice channels.
     *
     * Client action: *Send*
     */
    var VOICE_STATE_UPDATE = 4;

    /**
     * Resume a previous session that was disconnected.
     *
     * Client action: *Send*
     */
    var RESUME = 6;

    /**
     * You should attempt to reconnect and resume immediately.
     *
     * Client action: *Receive*
     */
    var RECONNECT = 7;

    /**
     * Request information about offline guild members in a large guild.
     *
     * Client action: *Send*
     */
    var REQUEST_GUILD_MEMBERS = 8;

    /**
     * The session has been invalidated. 
     *
     * You should reconnect and identify/resume accordingly.
     *
     * Client action: *Receive*
     */
    var INVALID_SESSION = 9;

    /**
     * Sent immediately after connecting, contains the `heartbeat_interval` to use.
     *
     * Client action: *Receive*
     */
    var HELLO = 10;

    /**
     * Sent in response to receiving a heartbeat to acknowledge that it has been received.
     *
     * Client action: *Receive*
     */
    var HEARTBEAT_ACK = 11;
    
    /**
     * Request information about soundboard sounds in a set of guilds.
     * 
     * Client action: *Send*
     */
    var REQUEST_SOUNDBOARD_SOUNDS = 31;
}