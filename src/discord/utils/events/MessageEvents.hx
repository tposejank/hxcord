package discord.utils.events;

import discord.utils.events.EventDispatcher.Event;

/**
 * Fired when a message is created.
 */
class Message extends Event {
    public var message:discord.Message;

    public function new(message:discord.Message) {
        this.message = message;
        super('message');
    }
}