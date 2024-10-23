package discord;

import discord.State.ConnectionState;
import haxe.Json;
import discord.Flags.Intents;
import discord.Gateway;
import discord.User.ClientUser;
import discord.utils.events.EventDispatcher;
import discord.utils.events.GatewayReceiveEvent;

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
    public var user:ClientUser;

    public var state:ConnectionState;

    public function new(_token:String, intents:Intents) {
        super();

        this.token = _token;
        this.intents = intents;
        ws = new Gateway(this.token, intents);

        this.state = new ConnectionState(this);

        ws.addEventListener(GatewayEvent.GATEWAY_RECEIVE_EVENT, onMessage);
        ws.addEventListener(GatewayEvent.GATEWAY_RECEIVE_EVENT, state.on_dispatch);
    }

    /**
     * Connect to the Gateway and
     * begin operating the Client.
     * 
     * This is a blocking call, and nothing will run after this is called,
     * unless explicitly called by `Client`.
     */
    public function run():Void {
        ws.initializeWebsocket();
    }

    public function onMessage(event:GatewayReceiveEvent) {
        trace(Json.stringify(event.payload));
    }

    function get_latency():Float {
        return ws?.latency ?? -1;
    }
}