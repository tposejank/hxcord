package discord.utils.events;

import discord.utils.events.EventDispatcher.Event;

class UserUpdate extends Event {
    public var old_user:User;
    public var new_user:User;
    public function new(old_user:User, new_user:User) {
        this.old_user = old_user;
        this.new_user = new_user;
        super('user_update');
    }
}