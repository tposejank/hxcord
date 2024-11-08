package discord.utils.events;

import discord.utils.events.EventDispatcher.Event;

/**
 * An event called when a guild is available.
 */
class GuildAvailable extends Event {
    public var guild:Guild;

    public function new(guild:Guild) {
        this.guild = guild;
        super("guild_available");
    }
}

/**
 * An event called when a guild is unavailable.
 */
 class GuildUnavailable extends Event {
    public var guild:Guild;

    public function new(guild:Guild) {
        this.guild = guild;
        super("guild_unavailable");
    }
}

/**
 * An event called when a guild is joined.
 */
class GuildJoin extends Event {
    public var guild:Guild;

    public function new(guild:Guild) {
        this.guild = guild;
        super("guild_join");
    }
}

/**
 * An event called when a guild is removed.
 */
 class GuildRemove extends Event {
    public var guild:Guild;

    public function new(guild:Guild) {
        this.guild = guild;
        super("guild_remove");
    }
}

/**
 * An event called when a guild is updated.
 */
 class GuildUpdate extends Event {
    public var guild:Guild;

    public function new(guild:Guild) {
        this.guild = guild;
        super("guild_update");
    }
}

/**
 * An event called when a role is created in a guild.
 */
 class GuildRoleCreate extends Event {
    public var role:Role;

    public function new(role:Role) {
        this.role = role;
        super("guild_role_create");
    }
}

/**
 * An event called when a role is deleted in a guild.
 */
 class GuildRoleDelete extends Event {
    public var role:Role;

    public function new(role:Role) {
        this.role = role;
        super("guild_role_delete");
    }
}

/**
 * An event called when a role is updated in a guild.
 */
 class GuildRoleUpdate extends Event {
    public var role:Role;

    public function new(role:Role) {
        this.role = role;
        super("guild_role_update");
    }
}