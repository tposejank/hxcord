package discord.utils.events;

import discord.utils.events.EventDispatcher.Event;
import discord.Gateway.Payload;

/**
 * An event called when the Web Socket receives a payload message.
 * @param payload The data sent by the Discord Gateway
 */
class GatewayReceive extends Event {
    public var payload:Payload;

    public function new (payload:Payload) {
        this.payload = payload;
        super("GATEWAY_RECEIVE", false, false);
    }
}

/**
 * An event called when the websocket is `not null` and it has been reset (due to a reconnection).
 */
class GatewayReset extends Event {
    public function new() {
        super('GATEWAY_RESET');
    }
}

class Connect extends Event {
    public function new() {
        super('connect');
    }
}