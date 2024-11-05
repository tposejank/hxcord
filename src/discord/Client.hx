package discord;

import discord.Http.HTTPClient;
import haxe.Exception;
import discord.log.Log;
import discord.State.ConnectionState;
import haxe.Json;
import discord.Flags.Intents;
import discord.Gateway;
import discord.User.ClientUser;
import discord.utils.events.EventDispatcher;
import discord.utils.events.GatewayEvents;

class Client extends EventDispatcher {
    // Thanks Haxe, for being able to achieve only
    // single-inheritance!

    /**
     * The Client's Discord token.
     */
    private var token:String;

    public var intents:Intents;

    /**
     * The Gateway this client is connected to.
     */
    public var ws:Gateway;

    /**
     * Measures latency between a HEARTBEAT and a HEARTBEAT_ACK in seconds.
     */
    public var latency(get, never):Float;

    /**
     * The user this Client is connected to.
     */
    public var user(get, never):ClientUser;

    public var state:ConnectionState;

    public var http:HTTPClient;

    public function new(_token:String, intents:Intents) {
        super();

        Log.init(LogLevel.TEST);

        this.token = _token;
        this.intents = intents;
        ws = new Gateway(this.token, intents);

        this.http = new HTTPClient(this.token);
        this.state = new ConnectionState(this, this.dispatchEvent, this.http);

        ws.addEventListener(GatewayEvent.GATEWAY_RECEIVE_EVENT, onMessage);
        ws.addEventListener(GatewayEvent.GATEWAY_RECEIVE_EVENT, state.on_dispatch, false, 1);
    }

    /**
     * Connect to the Gateway and
     * begin operating the Client.
     */
    public function run():Void {
        ws.initializeWebSocket();
    }

    /**
     * Waits for a WebSocket event to be dispatched.
     * 
     * This could be used to wait for a user to reply to a message,
     * or to react to a message, or to edit a message in a self-contained
     * way.
     * @param type The event name, similar to the event reference but without the `on_` prefix, to wait for.
     * @param callback The function triggered when the conditions are met, whether `check` be provided, or the event be sent.
     * @param check A callback to check what to wait for. If this function returns `false`, the event will 
     * @param timeout The number of seconds to wait before timing out and raising a timeout exception.
     */
    public function wait_for(type:String, callback:Dynamic->Void, ?check:Dynamic->Bool, ?timeout:Float) {
        var onTriggered:Event->Void = null;
        var timeoutTimer:haxe.Timer = null;

        if (timeout != null) {
            timeoutTimer = new haxe.Timer(Std.int(timeout * 1000));
            timeoutTimer.run = () -> {
                timeoutTimer.stop();
                if (onTriggered != null) removeEventListener(type, onTriggered);
                throw new Exception("Timed out"); // TBD: Errors class
            }
        }

        onTriggered = (event:Event) -> {
            // call the check to see if the developer wants this event
            if (check != null) {
                if (check(event)) {
                    callback(event);
                    removeEventListener(type, onTriggered);
                }
            } else { // no check was provided; call inmediately
                callback(event);
                removeEventListener(type, onTriggered);
            }
        }

        addEventListener(type, onTriggered);
    }

    public function onMessage(event:GatewayReceive) {
        // for (guild in user?.mutual_guilds ?? []) {
        //     trace(guild.name);
        //     trace(guild.id);
        // }
    }

    public function get_latency():Float {
        return ws?.latency ?? -1;
    }

    public function get_user():ClientUser {
        return state.user;
    }
}