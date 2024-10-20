package discord.utils.events;

import discord.utils.events.EventDispatcher.Event;

/**
 * An event called when the websocket is `not null` and it has been reset (due to a reconnection).
 */
class GatewayResetEvent extends Event {
    public function new() {
        super('GATEWAY_RESET_EVENT');
    }
}