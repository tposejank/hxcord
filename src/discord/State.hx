package discord;

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
            return user;
        }
    }

    public function on_dispatch(event:GatewayReceiveEvent) {
        var payload:Payload = event.payload;

        switch(payload.t) {
            case 'GUILD_CREATE':
                parse_guild_create(payload.d);
        }
    }

    public function _get_guild(guild_id:String):Guild {
        return _guilds.get(guild_id);
    }

    public function _add_guild(guild:Guild) {
        _guilds.set(guild.id, guild);
    }

    public function _get_create_guild(data:Dynamic):Guild {
        if (data.unavailable == false) {
            var guild:Guild = _get_guild(data.id);
            if (guild != null) {
                guild.unavailable = false;
                trace('The guild is returning');
                return guild;
            }
        }

        trace('The guild is NOT available');

        var guild:Guild = new Guild(data, this);
        _guilds.set(guild.id, guild);
        return guild;
    }

    public function parse_guild_create(data:Dynamic) {
        var unavailable:Bool = data.unavailable;
        if (unavailable)
            return;

        trace('CREATING GUILD!!');
        trace(data);

        var guild:Guild = _get_create_guild(data);

        if (unavailable == false) {
            // client.dispatchEvent();
        } else {
            // client.dispatchEvent();
        }
        
        trace(_guilds.exists(data.id));
    }
}