package discord;

// Events
import sys.thread.Thread;
import sys.thread.ElasticThreadPool;
import discord.Flags.Intents;
import sys.thread.Deque;
import discord.Http.MultipartData;
import discord.utils.events.MemberEvents.MemberUnban;
import discord.utils.events.MemberEvents.MemberBan;
import haxe.Json;
import discord.Http.Route;
import discord.Http.HTTPClient;
import discord.utils.events.EventDispatcher.Event;
import discord.utils.events.GuildEvents;
import discord.utils.events.GatewayEvents;
import discord.utils.events.UserEvents;

import discord.Guild.GuildPayload;
import discord.log.Log;
import discord.Gateway.Payload;
import discord.User.UserPayload;
import discord.User.ClientUser;

using discord.utils.MapUtils;

class ConnectionState {
    public var _users:Map<String, User> = new Map<String, User>();
    public var _guilds:Map<String, Guild> = new Map<String, Guild>();

    public var client:Client;
    public var dispatch:Event->Bool;

    public var http:HTTPClient;

    public var intents:Intents;
    public var ws:Gateway;

    // guild chunking variables
    private var guilds_to_chunk:Array<Guild> = [];
    private var guild_chunk_next_signal:Deque<Bool> = new Deque<Bool>();
    private var _chunk_guilds:Bool;
    private var all_guilds_arrived = false;
    private var all_guilds_arrived_timeout = 2.0;
    private var all_guilds_arrived_tmr:haxe.Timer;
    private var already_chunking = false;
    private var guild_dispatch_list:Map<String, Guild> = new Map<String, Guild>();

    public function new(client:Client, dispatch:Event->Bool, http:HTTPClient) {
        this.dispatch = dispatch;
        this.client = client;
        this.http = http;

        this.intents = client.intents;
        this.ws = client.ws;

        this._chunk_guilds = intents.guild_members;
    }

    /**
     * The user this Client is connected to.
     */
    public var user:ClientUser;
    public var application_id:String;
    public var application_flags:Dynamic;

    public var self_id(get, never):String;
    function get_self_id():String {
        return this.user.id ?? null;
    }

    public function chunk_guild(guild:Guild) {
        ws.request_chunks(guild.id, false, 0);
    }

    private function _delay_ready() {
        if (already_chunking) return;

        all_guilds_arrived = true;
        already_chunking = true;

        client.thread_pool.run(() -> {
            for (guild in guilds_to_chunk) {
                if (_guild_needs_chunking(guild)) {
                    chunk_guild(guild);
                    guild_chunk_next_signal.pop(true);

                    if (guild.unavailable == false) {
                        this.dispatch(new GuildAvailable(guild));
                    } else {
                        this.dispatch(new GuildJoin(guild));
                    }
                } else {
                    if (guild.unavailable == false) {
                        this.dispatch(new GuildAvailable(guild));
                    } else {
                        this.dispatch(new GuildJoin(guild));
                    }
                }
            }
            guilds_to_chunk = null;
            this.dispatch(new Ready());
        });
    }

    public function store_user(data:UserPayload):User {
        var user_id:String = data.id;

        if (_users.exists(user_id)) {
            return _users.get(user_id);
        } else {
            var user:User = new User(this, data);
            _users.set(user_id, user);
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
            case 'GUILD_UPDATE':
                parse_guild_update(payload.d);
            case 'GUILD_DELETE':
                parse_guild_delete(payload.d);
            case 'GUILD_BAN_ADD':
                parse_guild_ban_add(payload.d);
            case 'GUILD_BAN_REMOVE':
                parse_guild_ban_remove(payload.d);
            case 'GUILD_ROLE_CREATE':
                parse_guild_role_create(payload.d);
            case 'GUILD_ROLE_DELETE':
                parse_guild_role_delete(payload.d);
            case 'GUILD_ROLE_UPDATE':
                parse_guild_role_update(payload.d);
            case 'GUILD_MEMBERS_CHUNK':
                parse_guild_members_chunk(payload.d);
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

    public function _remove_guild(guild:Guild) {
        _guilds.remove(guild.id);
        
        // for emoji in guild.emojis:
        //     self._emojis.pop(emoji.id, None)

        // for sticker in guild.stickers:
        //     self._stickers.pop(sticker.id, None)

        guild = null;
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

        var user = data.user;
        var member_id = user.id;
        var member:Member = guild.get_member(member_id);
        if (member == null) {
            Log.error('PRESENCE_UPDATE is referencing an unknown member ID $member_id in guild $guild_id, discarding.');
            return;
        }

        // TBD: Missing member._copy

        var user_update:Array<User> = member._presence_update(data, data.user);
        if (user_update != null) {
            dispatch(new UserUpdate(user_update[0], user_update[1]));
        }
        //dispatch('presence_update')
    }

    public function put_in_chunk_deque(guild:Guild) {
        if (!all_guilds_arrived && guilds_to_chunk != null) {
            guilds_to_chunk.push(guild);
            return true;
        } else {
            return false;
        }
    }

    public function parse_guild_create(data:Dynamic):Void {
        var unavailable:Bool = data.unavailable;
        if (unavailable)
            return;

        if (!this.all_guilds_arrived) {
            if (this.all_guilds_arrived_tmr != null) {
                this.all_guilds_arrived_tmr.stop();
            }

            haxe.MainLoop.runInMainThread(() -> {
                this.all_guilds_arrived_tmr = haxe.Timer.delay(_delay_ready, Std.int(this.all_guilds_arrived_timeout * 1000));
            });
        }

        var guild:Guild = _get_create_guild(data);

        if (put_in_chunk_deque(guild))
            return;

        if (_guild_needs_chunking(guild)) {
            guild_dispatch_list.set(guild.id, guild);
            chunk_guild(guild);
            return;
        }

        if (unavailable == false) {
            this.dispatch(new GuildAvailable(guild));
        } else {
            this.dispatch(new GuildJoin(guild));
        }
    }

    function _guild_needs_chunking(guild:Guild):Bool {
        return this._chunk_guilds && !guild.chunked && !(this.intents.guild_presences && !guild.large);
    }

    public function parse_guild_update(data:Dynamic) {
        var guild:Guild = this._get_guild(data.id);
        if (guild != null) {
            // TBD: guild.copy
            guild._from_data(data);
            this.dispatch(new GuildUpdate(guild));
        } else {
            Log.error('GUILD_UPDATE is referencing an unknown guild ID ${data.id}. Discarding.');
        }
    }

    public function parse_guild_delete(data:Dynamic) {
        var guild:Guild = this._get_guild(data.id);
        if (guild == null) {
            Log.error('GUILD_DELETE is referencing an unknown guild ID ${data.id}. Discarding.');
            return;
        }

        if (data.unavailable ?? false) {
            guild.unavailable = true;
            this.dispatch(new GuildUnavailable(guild));
            return;
        }

        // if self._messages is not None:
        //     self._messages: Optional[Deque[Message]] = deque(
        //         (msg for msg in self._messages if msg.guild != guild), maxlen=self.max_messages
        //     )

        this.dispatch(new GuildRemove(guild));
        _remove_guild(guild);
    }

    public function parse_guild_ban_add(data:Dynamic):Void {
        var guild:Guild = this._get_guild(data.guild_id);
        if (guild != null) {
            var user = new User(this, data.user);
            var member:Dynamic = guild.get_member(user.id) ?? user;
            this.dispatch(new MemberBan(guild, member));
        }
    }

    public function parse_guild_ban_remove(data:Dynamic):Void {
        var guild:Guild = this._get_guild(data.guild_id);
        if (guild != null && data.user != null) {
            var user = this.store_user(data.user);
            this.dispatch(new MemberUnban(guild, user));
        }
    }

    public function parse_guild_role_create(data:Dynamic):Void {
        var guild:Guild = this._get_guild(data.guild_id);
        if (guild == null) {
            Log.error('GUILD_ROLE_CREATE is referencing an unknown guild ID: ${data.guild_id}. Discarding!');
            return;
        }

        var role:Role = new Role(guild, this, data.role);
        guild._add_role(role);
        this.dispatch(new GuildRoleCreate(role));
    }

    public function parse_guild_role_delete(data:Dynamic):Void {
        var guild:Guild = this._get_guild(data.guild_id);
        if (guild == null) {
            Log.error('GUILD_ROLE_DELETE is referencing an unknown guild ID: ${data.guild_id}. Discarding!');
            return;
        }

        var role:Role = guild._remove_role(data.role_id);
        this.dispatch(new GuildRoleDelete(role));
    }

    public function parse_guild_role_update(data:Dynamic) {
        var guild:Guild = this._get_guild(data.guild_id);
        if (guild == null) {
            Log.error('GUILD_ROLE_UPDATE is referencing an unknown guild ID: ${data.guild_id}. Discarding!');
            return;
        }

        var role = guild.get_role(data.role.id);
        if (role != null) {
            // var old_role = Role._copy(role);
            // TBD: missing role.copy
            role._update(data.role);
            this.dispatch(new GuildRoleUpdate(role));
        }
    }

    public function parse_guild_members_chunk(data:Dynamic) {
        var guild_id = data.guild_id;
        var guild = this._get_guild(guild_id);
        var presences = data.presences ?? [];

        if (guild == null) {
            Log.warn('Got an invalid guild in GUILD_MEMBERS_CHUNK?');
            return;
        }

        var members:Array<Member> = [];
        for (member in data.members ?? []) {
            members.push(new Member(member, guild, this));
        }

        Log.debug('Processing ${members.length} members of a GUILD_MEMBERS_CHUNK.');

        if (presences.length > 0) {
            var member_map:Map<String, Member> = new Map<String, Member>();
            for (m in members) member_map.set(m.id, m);

            for (presence in presences) {
                var user = presence.user;
                var m_id = presence.user.id;
                var m = member_map.get(m_id);
                m._presence_update(presence, user);
            }
        }

        guild.add_members(members);

        var complete:Bool = (data.chunk_index + 1) == data.chunk_count;

        if (complete && (guilds_to_chunk != null)) {
            this.guild_chunk_next_signal.add(true);
        } else if (complete && guild_dispatch_list.exists(guild.id)) {
            guild_dispatch_list.remove(guild.id);
            if (guild.unavailable == false) {
    public function parse_message_create(data:Dynamic):Void {
        // channel, _ = self._get_guild_channel(data)
        // # channel would be the correct type here
        // message = Message(channel=channel, data=data, state=self)  # type: ignore
        // self.dispatch('message', message)
        // if self._messages is not None:
        //     self._messages.append(message)
        // # we ensure that the channel is either a TextChannel, VoiceChannel, or Thread
        // if channel and channel.__class__ in (TextChannel, VoiceChannel, Thread, StageChannel):
        //     channel.last_message_id = message.id  # type: ignore

        var message = new Message(this, null, data);
                            filename: "file_test_0.jpg"
                        }
                    ]
                }, [sys.io.File.getBytes('youreasigma.jpg')]));
        } else if (StringTools.startsWith(message.content, 'hxcordDELETETHIS')) {
            var result = http.delete_message(data.channel_id, data.id, 'hi');
            trace('i think its me');
            trace(result);
        } else if (StringTools.startsWith(message.content, 'hxcordtro')) {
            var reqdata = http.request(new Route('POST', '/channels/${data.channel_id}/messages'), '{"content":"[tro](https://cdn.discordapp.com/emojis/1191617845528895588.webp?size=48&quality=lossless&name=tro)"}', null);
        } else if (StringTools.startsWith(message.content, 'hxcordkeoiki')) {
            var reqdata = http.request(new Route('POST', '/channels/${data.channel_id}/messages'), '{"content":"[keoiki](https://cdn.discordapp.com/emojis/1030168800785596486.webp?size=48&quality=lossless&name=keoiki)"}', null);
        }

        this.dispatch(new discord.utils.events.MessageEvents.Message(message));
    }
}