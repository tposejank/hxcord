package discord.utils.events;

import discord.utils.events.EventDispatcher.Event;

/**
 * An event called when a guild is available.
 */
class GuildAvailable extends Event {
    public var guild:Guild;

    public function new(guild:Guild) {
        this.guild = guild;
        super("guild_available", false, false);
    }
}

/**
 * An event called when a guild is joined.
 */
class GuildJoin extends Event {
    public var guild:Guild;

    public function new(guild:Guild) {
        this.guild = guild;
        super("guild_join", false, false);
    }
}