package discord;

import haxe.Json;
import discord.types.Intents;
import discord.ws.Gateway;
import discord.user.User.ClientUser;
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

    public function new(_token:String, intents:Intents) {
        super();

        this.token = _token;
        this.intents = intents;
        ws = new Gateway(this.token, intents);

        ws.addEventListener(GatewayEvent.GATEWAY_RECEIVE_EVENT, onMessage);
    }

    /**
     * Connect to the Gateway and
     * begin operating the Client.
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