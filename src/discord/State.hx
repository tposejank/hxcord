package discord;

import discord.log.Log;
import discord.Gateway.Payload;
import discord.utils.events.GatewayReceiveEvent;
import discord.User.UserPayload;

class ConnectionState {
    public var _users:Map<String, User> = new Map<String, User>();
    public var _guilds:Map<String, Guild> = new Map<String, Guild>();

    public var client:Client;

    public function new(client:Client) {
        this.client = client;
    }

    public function store_user(data:UserPayload):User {
        var user_id:String = data.id;

        if (_users.exists(user_id))
            return _users.get(user_id);
        else {
            var user:User = new User(this, data);
            _users.set(user_id, user);
            trace('Created user $user_id');
            return user;
        }
    }

    public function on_dispatch(event:GatewayReceiveEvent) {
        var payload:Payload = event.payload;

        switch(payload.t) {
            case 'GUILD_CREATE':
                parse_guild_create(payload.d);
            case 'PRESENCE_UPDATE':
                parse_presence_update(payload.d);
            case 'MESSAGE_CREATE':
                parse_message_create(payload.d);
        }
    }

    public function _get_guild(guild_id:String):Guild {
        return _guilds.get(guild_id);
    }

    public function _add_guild(guild:Guild):Void {
        _guilds.set(guild.id, guild);
    }

    public function _get_create_guild(data:Dynamic):Guild {
        if (data.unavailable == false) {
            var guild:Guild = _get_guild(data.id);
            if (guild != null) {
                guild.unavailable = false;
                return guild;
            }
        }

        var guild:Guild = new Guild(data, this);
        _guilds.set(guild.id, guild);
        return guild;
    }

    public function parse_guild_create(data:Dynamic):Void {
        var unavailable:Bool = data.unavailable;
        if (unavailable)
            return;

        var guild:Guild = _get_create_guild(data);

        if (unavailable == false) {
            // client.dispatchEvent();
        } else {
            // client.dispatchEvent();
        }
    }

    public function parse_presence_update(data:Dynamic):Void {
        var guild_id = data.guild_id;

        var guild:Guild = _get_guild(guild_id);
        if (guild == null) {
            Log.error('PRESENCE_UPDATE is referencing an unknown guild ID $guild_id, discarding.');
            return;
        }

        var user = data.user; // No need to note type as UserPayload
        var member_id = user.id;
        var member:Member = guild.get_member(member_id);
        if (member == null) {
            Log.error('PRESENCE_UPDATE is referencing an unknown member ID $member_id in guild $guild_id, discarding.');
            return;
        }

        if (member._presence_update(data, data.user)) {
            //dispatch('user_update')
        }
        //dispatch('presence_update')
    }

    public function parse_message_create(data:Dynamic):Void {
        trace("Hello!");
    }
}