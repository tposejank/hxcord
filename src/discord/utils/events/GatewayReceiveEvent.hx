package discord.utils.events;

import discord.utils.events.EventDispatcher.Event;
import discord.Gateway.Payload;

/**
 * An event called when the Web Socket receives a payload message.
 * @param payload The data sent by the Discord Gateway
 */
class GatewayReceiveEvent extends Event {
    public var payload:Payload;

    public function new (payload:Payload) {
        this.payload = payload;
        super("GATEWAY_RECEIVE_EVENT", false, false);
    }
}