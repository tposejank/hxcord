package discord.utils.events;

import discord.utils.events.EventDispatcher.Event;

/**
 * An event called when a member is banned.
 */
class MemberBan extends Event {
    public var guild:Guild;
    /**
     * Can be either `Member` or `User`.
     */
    public var member:Dynamic;

    public function new(guild:Guild, member:Dynamic) {
        this.guild = guild;
        this.member = member;
        super('member_ban');
    }
}

/**
 * An event called when a member is unbanned.
 */
class MemberUnban extends Event {
    public var guild:Guild;
    public var user:User;

    public function new(guild:Guild, user:User) {
        this.guild = guild;
        this.user = user;
        super('member_unban');
    }
}