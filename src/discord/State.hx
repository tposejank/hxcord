package discord;

// Events
import discord.utils.events.EventDispatcher.Event;
import discord.utils.events.GuildEvents;
import discord.utils.events.GatewayEvents;

import discord.Guild.GuildPayload;
import discord.log.Log;
import discord.Gateway.Payload;
import discord.User.UserPayload;
import discord.User.ClientUser;

class ConnectionState {
    public var _users:Map<String, User> = new Map<String, User>();
    public var _guilds:Map<String, Guild> = new Map<String, Guild>();

    public var client:Client;
    public var dispatch:Event->Bool;

    public function new(client:Client, dispatch:Event->Bool) {
        this.dispatch = dispatch;
        this.client = client;
    }

    /**
     * The user this Client is connected to.
     */
    public var user:ClientUser;
    public var application_id:String;
    public var application_flags:Dynamic;

    public function store_user(data:UserPayload):User {
        var user_id:String = data.id;

        if (_users.exists(user_id)) {
            Log.test('Requested user $user_id already exists, returning cached');
            return _users.get(user_id);
        } else {
            var user:User = new User(this, data);
            _users.set(user_id, user);
            Log.test('Created user $user_id');
            return user;
        }
    }

    public function on_dispatch(event:GatewayReceive) {
        var payload:Payload = event.payload;

        switch(payload.t) {
            case 'READY':
                parse_ready(payload.d);
            case 'GUILD_CREATE':
                parse_guild_create(payload.d);
            case 'PRESENCE_UPDATE':
                parse_presence_update(payload.d);
            case 'MESSAGE_CREATE':
                parse_message_create(payload.d);
        }
    }

    public function _add_guild_from_data(data:GuildPayload):Guild {
        var guild:Guild = new Guild(data, this);
        _add_guild(guild);
        return guild;
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
                guild._from_data(data);
                return guild;
            }
        }

        var guild:Guild = new Guild(data, this);
        _guilds.set(guild.id, guild);
        return guild;
    }

    public function clear(views:Bool = true) {
        this.user = null;
        this._users = [];
        this._guilds = [];
    }

    public function parse_ready(data:Dynamic):Void {
        clear(false);
        var user:ClientUser = new ClientUser(this, data.user);
        this.user = user;
        this._users.set(user.id, user);

        Log.debug('Created ClientUser for ${user.id}');

        var userhandle = '@${user.name}';
        if (user.discriminator != '0') userhandle = '${user.name}#${user.discriminator}';
        Log.info('Logged in as ${userhandle}');

        if (this.application_id == null) {
            var application = data.application;

            this.application_id = application?.id ?? null;
            this.application_flags = application?.flags ?? null;
        }

        // shitty compiler error fix
        var guild_datas:Array<GuildPayload> = data.guilds;
        for (guild_data in guild_datas) {
            _add_guild_from_data(guild_data);
        }

        this.dispatch(new Connect());
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

    public function parse_guild_create(data:Dynamic):Void {
        var unavailable:Bool = data.unavailable;
        if (unavailable)
            return;

        var guild:Guild = _get_create_guild(data);

        if (unavailable == false) {
            this.dispatch(new GuildAvailable(guild));
        } else {
            this.dispatch(new GuildJoin(guild));
        }
    }

    public function parse_message_create(data:Dynamic):Void {
        trace("Hello!");
    }
}