package discord;

import discord.Message.PartialMessage;
import discord.utils.errors.Errors.TypeError;
import discord.Permissions.Permission;
import haxe.ValueException;
import haxe.exceptions.NotImplementedException;
import discord.State.ConnectionState;
import discord.Snowflake;

using discord.utils.MapUtils;

typedef BaseChannelPayload = {
    var id:String;
    var name:String;
}

typedef BaseGuildChannelPayload = {
    >BaseChannelPayload,
    var guild_id:String;
    var position:Int;
    // var permission_overw  permissions later
    var nsfw:Bool;
    @:optional var parent_id:String;
}

typedef BaseTextChannelPayload = {
    >BaseGuildChannelPayload,
    var topic:String;
    @:optional var last_message_id:String;
    var last_pin_timestamp:String;
    var rate_limit_per_user:Int;
    var default_thread_rate_limit_per_user:Int;
    var default_auto_archive_duration:Int; // seconds (??)
    var type:Int; // make enum ChannelType or smth
}

typedef TextChannelPayload = {
    >BaseTextChannelPayload,
    var type:Int;
}

typedef NewsChannelPayload = {
    >BaseTextChannelPayload,
    var type:Int;
}

// :upside_down:
typedef TextChannelUnion = {
    >TextChannelPayload,
    >NewsChannelPayload,
}

typedef VoiceChannelPayload = {
    >BaseTextChannelPayload,
    var type:Int;
    var bitrate:Int;
    var user_limit:Int;
    @:optional var rtc_region:String;
    var video_quality_mode:Int; // 1, 2
}

typedef CategoryChannelPayload = {
    >BaseGuildChannelPayload,
    var type:Int;
}

typedef StageChannelPayload = {
    >BaseGuildChannelPayload,
    var type:Int;
    var bitrate:Int;
    var user_limit:Int;
    @:optional var rtc_region:String;
}

// typedef Thread  i hate threads

typedef ForumTagPayload = {
    var id:String;
    var name:String;
    var moderated:Bool;
    @:optional var emoji_id:String;
    @:optional var emoji_name:String;
}

typedef DefaultReactionPayload = {
    var emoji_id:String;
    var emoji_name:String;
}

typedef BaseForumChannelPayload = {
    >BaseTextChannelPayload,
    var available_tags:Array<ForumTagPayload>;
    @:optional var default_reaction_emoji:DefaultReactionPayload;
    @:optional var default_sort_order:Int; // 0, 1
    @:optional var default_forum_layout:Int; // 0, 1, 2
    @:optional var flags:Int;
}

typedef ForumChannelPayload = {
    >BaseForumChannelPayload,
    var type:Int;
}

typedef MediaChannelPayload = {
    >BaseForumChannelPayload,
    var type:Int;
}

typedef GuildChannelPayload = {
    >TextChannelPayload,
    >NewsChannelPayload,
    >VoiceChannelPayload,
    >CategoryChannelPayload,
    >StageChannelPayload,
    // thread
    >ForumChannelPayload,
    >MediaChannelPayload,
}

enum abstract ChannelType(Int) from Int to Int {
    var text = 0;
    var _private = 1; // prefixed with a _ because haxe
    var voice = 2;
    var group = 3;
    var category = 4;
    var news = 5;
    var news_thread = 10;
    var public_thread = 11;
    var private_thread = 12;
    var stage_voice = 13;
    var forum = 15;
    var media = 16;
}

/**
 * The common starting point for a Discord `Guild` channel.
 */
class GuildChannel extends Messageable {
    /**
     * The channel name.
     */
    public var name:String;
    /**
     * The guild the channel belongs to.
     */
    public var guild:Guild;
    /**
     * The position in the channel list. This is a number that starts at 0.
     * e.g. the top channel is position 0.
     */
    public var position:Int;

    public var type(get, never):ChannelType;

    public var category_id:String;

    public var _overwrites:Array<Dynamic>;

    public var _sorting_bucket(get, never):Int;

    public function _update(guild:Guild, data:GuildChannelPayload) {
        throw new NotImplementedException();
    }

    function get__sorting_bucket():Int {
        throw new NotImplementedException();
    }

    function get_type() {
        throw new NotImplementedException();
    }

    public function toString():String return this.name;

    public function move(position:Int, parent_id:String, lock_permissions:Bool = false, reason:String = '') {
        if (position < 0) throw new ValueException("Channel position cannot be negative");

        var http = this._state.http;
        var bucket = this._sorting_bucket;
        var channels:Array<GuildChannel> = [];
        for (c in this.guild.channels) {
            if (c._sorting_bucket == bucket) channels.push(c);
        }

        channels.sort((a, b) -> {
            return a.position - b.position;
        });

        channels.remove(this); // haxe does not raise!!!

        var index:Int = 0;
        for (i in 0...channels.length) {
            if (channels[i].position >= position) {
                index = i;
                break;
            }
        }

        channels.insert(index, this);

        var payload = [];
        for (_index => c in channels) {
            var d:Dynamic = { // dynamic makes compiler not scream
                id: c.id,
                position: _index
            };
            if (parent_id != null && c.id == this.id) {
                d.parent_id = parent_id;
                d.lock_permissions = lock_permissions;
            }
            payload.push(d);
        }

        http.bulk_channel_update(this.guild.id, haxe.Json.stringify(payload), reason);
    }

    public function _edit() {} // too much for now

    /**
     * The string that allows you to mention the channel.
     */
    public var mention(get, never):String;
    function get_mention():String return '<#${this.id}>';

    /**
     * Returns a URL that allows the client to jump to the channel.
     */
    public var jump_url(get, never):String;
    function get_jump_url():String return 'https://discord.com/channels/${this.guild.id}/${this.id}';
    
    /**
     * Returns the channel's creation time in UTC.
     */
    public var created_at(get, never):Date;
    function get_created_at():Date return Utils.snowflake_time(this.id);

    /**
     * The category this channel belongs to.
     * 
     * If there is no category then this is `null`.
     */
    public var category(get, never):CategoryChannel;
    function get_category() {
        return cast guild.get_channel(category_id);
    }

    function _apply_implicit_permissions(base:Permissions) {
        if (!base.send_messages) {
            base.send_tts_messages = false;
            base.mention_everyone = false;
            base.embed_links = false;
            base.attach_files = false;
        }

        if (!base.view_channel) {
            var denied = Permissions.all_channel();
            base.value &= ~denied.value;
        }
    }

    /**
     * Handles permission resolution for the `Member` 
     * or `Role`.
     * 
     * This function takes into consideration the following cases:
     * 
     * - Guild owner
     * - Guild roles
     * - Channel overrides
     * - Member overrides
     * - Implicit permissions
     * - Member timeout
     * - User installed app
     * 
     * If a `Role` is passed, then it checks the permissions
     * someone with that role would have, which is essentially:
     * 
     * - The default role permissions
     * - The permissions of the role used as a parameter
     * - The default role permission overwrites
     * - The permission overwrites of the role used as a parameter
     * 
     * @param obj The object to resolve permissions for. This could be either
     * a member or a role. If it's a role then member overwrites
     * are not computed.
     * @return Permissions The resolved permissions for the member or role.
     */
    public function permissions_for(obj:Dynamic):Permissions {
        if (obj is Snowflake) {
            if (this.guild.owner_id == cast(obj, Snowflake).id) {
                return Permissions.all();
            }
        }

        var default_role = this.guild.default_role;
        if (default_role != null) {
            if (this._state.self_id == obj.id) 
                return Permissions._user_installed_permissions(true);
            else 
                return Permissions.none();
        }

        var base = Permissions.fromValue(default_role.permissions.value);
        
        if (obj is Role) {
            var _obj = cast(obj, Role);
            base.value |= _obj._permissions;

            if (base.administrator)
                return Permissions.all();

            // try:
            //     maybe_everyone = self._overwrites[0]
            //     if maybe_everyone.id == self.guild.id:
            //         base.handle_overwrite(allow=maybe_everyone.allow, deny=maybe_everyone.deny)
            // except IndexError:
            //     pass

            if (_obj.is_default())
                return base;

            // overwrite = utils.get(self._overwrites, type=_Overwrites.ROLE, id=obj.id)
            // if overwrite is not None:
            //     base.handle_overwrite(overwrite.allow, overwrite.deny)
            
        } else if (obj is Member) {
            var _obj = cast(obj, Member);

            var roles = _obj._roles;
            for (role_id in roles) {
                var role = this.guild.get_role(role_id);
                if (role != null) {
                    base.value |= role._permissions;
                }
            }

            if (base.administrator)
                return Permissions.all();

            // so much code abt overwrites 

            // # Apply @everyone allow/deny first since it's special
            // try:
            //     maybe_everyone = self._overwrites[0]
            //     if maybe_everyone.id == self.guild.id:
            //         base.handle_overwrite(allow=maybe_everyone.allow, deny=maybe_everyone.deny)
            //         remaining_overwrites = self._overwrites[1:]
            //     else:
            //         remaining_overwrites = self._overwrites
            // except IndexError:
            //     remaining_overwrites = self._overwrites
    
            // denies = 0
            // allows = 0
    
            // # Apply channel specific role permission overwrites
            // for overwrite in remaining_overwrites:
            //     if overwrite.is_role() and roles.has(overwrite.id):
            //         denies |= overwrite.deny
            //         allows |= overwrite.allow
    
            // base.handle_overwrite(allow=allows, deny=denies)
    
            // # Apply member specific permission overwrites
            // for overwrite in remaining_overwrites:
            //     if overwrite.is_member() and overwrite.id == obj.id:
            //         base.handle_overwrite(allow=overwrite.allow, deny=overwrite.deny)
            //         break

            if (_obj.is_timed_out())
                base.value &= Permissions._timeout_mask();
        }

        return base;
    }

    // function _clone_impl():Dynamic {

    // }

    /**
     * Deletes the channel.
     * 
     * You must have `discord.Permissions.manage_channels` to do this.
     * 
     * @param reason The reason for deleting this channel. Shows up on the audit log.
     */
    public function delete(reason:String = '') {
        this._state.http.delete_channel(this.id, reason);
    }

    /**
     * Clones this channel. This creates a channel with the same properties
     * as this channel.
     * 
     * You must have `Permissions.manage_channels` to do this.
     * @param name The name of the new channel. If not provided, defaults to `this` channel name.
     * @param reason The reason for cloning this channel. Shows up on the audit log.
     */
    public function clone(name:String, reason:String):Dynamic {
        throw new NotImplementedException();
    }
}

@:structInit
@:publicFields
class MessageParameters {
    var content:String = null;
    var tts:Bool = false;
    var embeds:Array<Dynamic> = null;
    var files:Array<Dynamic> = null;
    var stickers:Array<Dynamic> = null; //TBD: _StickerTag // ID property, inherits AssetMixin // TBD: AssetMixin
    var delete_after:Null<Float> = null; // why ?
    var nonce:String = null;
    // var allowed_mentions: // TBD: find what the hell this is for and how to use it
    // var reference // MessageReference
    var mention_author:Null<Bool> = null;
    // var view
    var suppress_embeds:Bool = false;
    var silent:Bool = false;
    // var poll:
}

/**
 * The common starting point for models that can be sent messages.
 */
class Messageable extends Snowflake {
    public var _state:ConnectionState;

    public function _get_channel():Messageable {
        throw new NotImplementedException();
    }

    /**
     * Sends a message to the destination with the content given.
     * 
     * @param params `MessageParameters`. This can be used as a struct and therefore is not need to be created with `new()`.
     * @return Message The message that was sent.
     */
    public function send(params:MessageParameters):Message {
        if (params.content == null && params.embeds == null) {
            throw new TypeError('Either content or embeds must be null, not both');
        }

        var channel = _get_channel();
        var state = _state;

        

        return null;
    }

    /**
     * Retrieves a single `Message` from the destination.
     * 
     * @param id The message ID to look for.
     * @return Message The message asked for.
     */
    public function fetch_message(id:String):Message {
        var channel = this._get_channel();
        var data = this._state.http.get_message(channel.id, id);
        return this._state.create_message(channel, data);
    }

    /**
     * Retrieves all messages that are currently pinned in the channel.
     * 
     * Due to a limitation with the Discord API, the `MessagePayload`
     * objects returned by this method do not contain complete
     * `reactions` data.
     * 
     * @return Array<Message> The messages that are currently pinned.
     */
    public function pins():Array<Message> {
        var channel = _get_channel();
        var state = this._state;
        var data = state.http.pins_from(channel.id); 
        return [for (m in data) state.create_message(channel, m)];
    }

    // this shit looks complicated!!
    public function history(limit:Int = 100, ?before:Date, ?after:Date, ?around:Date, ?oldest_first:Bool):Array<Message> {
        return [];
    }
}

class PartialMessageable extends Messageable {
    public var guild_id:String;
    public var type:Int;

    public function new(state:ConnectionState, id:String, guild_id:String = null, ?type:Int) {
        this._state = state;
        this.id = id;
        this.guild_id = guild_id;
        this.type = type;
    }

    public override function _get_channel():PartialMessageable {
        return this;
    }

    public var guild(get, never):Guild;
    function get_guild():Guild {
        return this._state._get_guild(this.guild_id);
    }

    /**
     * Returns a URL that allows the client to jump to the channel.
     */
    public var jump_url(get, never):String;
    function get_jump_url():String return 'https://discord.com/channels/${this.guild.id}/${this.id}';

    /**
     * Returns the channel's creation time in UTC.
     */
    public var created_at(get, never):Date;
    function get_created_at():Date return Utils.snowflake_time(this.id);

    /**
     * Handles permission resolution for a `User`.
     * 
     * This function is there for compatibility with other channel types.
     * 
     * Since partial messageables cannot reasonably have the concept of
     * permissions, this will always return `Permissions.none`.
     */
    public function permissions_for(obj:Dynamic) {
        return Permissions.none();
    }
}

class CategoryChannel extends GuildChannel {
    public var nsfw:Bool;

    /**
     * Returns the channels that are under this category.
     * 
     * These are sorted by the official Discord UI, which places voice channels below the text channels.
     */
    public var channels(get, never):Array<GuildChannel>;

    /**
     * Returns the text channels that are under this category.
     */
    public var text_channels(get, never):Array<TextChannel>;

    public function new(state:ConnectionState, guild:Guild, data:CategoryChannelPayload) {
        this._state = state;
        this.id = data.id;  
        this._update(guild, data); 
    }

    public override function _update(guild:Guild, data:CategoryChannelPayload) {
        this.guild = guild;
        this.name = data.name;
        this.category_id = data.parent_id;
        this.nsfw = data.nsfw ?? false;
        this.position = data.position;
        // this._fill_overwrites(data);
    }
    
    /**
     * Returns the voice channels that are under this category.
     */
    //public var voice_channels(get, never):Array<TextChannel>;
    
    /**
     * Returns the stage channels that are under this category.
     */
    //public var stage_channels(get, never):Array<StageChannel>;
    
    /**
     * A shortcut method to `Guild.create_text_channel` to create a `TextChannel` in the category.
     * 
     * TODO, voice and stage and forum as well
     */
    // public function create_text_channel()
     
    function get_channels():Array<GuildChannel> {
        var ret = [for (ch in this.guild.channels) if (ch.category_id == this.id) ch];
        // todo: sort
        return ret;
    }

    function get_text_channels():Array<TextChannel> {
        var ret:Array<TextChannel> = [for (ch in this.guild.channels) if (ch.category_id == this.id && ch is TextChannel) cast ch];
        // todo: sort
        return ret;
    }

    override function get__sorting_bucket():Int {
        return ChannelType.category;
    }

    public var _scheduled_event_entity_type(get, never):Null<Int>;
    function get__scheduled_event_entity_type():Null<Int> { // tbd: enum entity type
        return null;
    }

    override function get_type():ChannelType {
        return ChannelType.category;
    }

    /**
     * Checks if the category is NSFW.
     */
    public function is_nsfw():Bool {
        return this.nsfw;
    }

    // tbd
    // public override function clone(name:String, reason:String):TextChannel {
        
    // }

    //TBD
    public function edit() {

    }

    //TBD
    // public override function move() {
    //     super.move()
    // }
}

/**
 * Represents a Discord guild text channel.
 */
class TextChannel extends GuildChannel {
    private var _type:Int;
    
    public var topic:String;

    public var nsfw:Null<Bool>;

    public var slowmode_delay:Null<Float>;

    public var default_auto_archive_duration:Null<Int>;

    public var default_thread_slowmode_delay:Null<Int>;

    public var last_message_id:String;

    public function new(state:ConnectionState, guild:Guild, data:TextChannelUnion) {
        this._state = state;
        this.id = data.id;
        this._type = data.type;
        this._update(guild, data);
    }

    public override function _update(guild:Guild, data:TextChannelUnion) {
        this.guild = guild;
        this.name = data.name;
        this.category_id = data.parent_id;
        this.topic = data.topic;
        this.position = data.position;
        this.nsfw = data.nsfw;
        this.slowmode_delay = data.rate_limit_per_user;
        this.default_auto_archive_duration = data.default_auto_archive_duration ?? 1440;
        this.default_thread_slowmode_delay = data.default_thread_rate_limit_per_user ?? 0;
        this._type = data.type ?? this._type;
        this.last_message_id = data.last_message_id;
    }

    public override function _get_channel():Messageable {
        return this;
    }

    public override function get_type():ChannelType {
        if (this._type == 0)
            return text;
        return news;
    }

    public override function get__sorting_bucket():Int {
        return ChannelType.text;
    }

    // @property
    // def _scheduled_event_entity_type(self) -> Optional[EntityType]:
    //     return None

    /**
     * Handles permission resolution for the `Member` 
     * or `Role`.
     * 
     * This function takes into consideration the following cases:
     * 
     * - Guild owner
     * - Guild roles
     * - Channel overrides
     * - Member overrides
     * - Implicit permissions
     * - Member timeout
     * - User installed app
     * 
     * If a `Role` is passed, then it checks the permissions
     * someone with that role would have, which is essentially:
     * 
     * - The default role permissions
     * - The permissions of the role used as a parameter
     * - The default role permission overwrites
     * - The permission overwrites of the role used as a parameter
     * 
     * @param obj The object to resolve permissions for. This could be either
     * a member or a role. If it's a role then member overwrites
     * are not computed.
     * @return Permissions The resolved permissions for the member or role.
     */
    public override function permissions_for(obj:Dynamic):Permissions {
        var base = super.permissions_for(obj);
        this._apply_implicit_permissions(base);

        var denied = Permissions.voice();
        base.value &= ~denied.value;
        return base;
    }

    /**
     * Returns all members that can see this channel.
     */
    public var members(get, never):Array<Member>;
    function get_members():Array<Member> {
        return [for (m in this.guild.members) if (this.permissions_for(m).view_channel) m];
    }

    // public var threads(get, never):Array<Dynamic>;
    // function get_threads():Array<Dynamic> {
        // return [for (thread in this.guild._threads.values()) if (thread.parent_id == this.id) thread];
    // }

    /**
     * Checks if the channel is NSFW.
     */
    public function is_nsfw():Bool {
        return this.nsfw;
    }
    
    public function is_news():Bool {
        return this._type == ChannelType.news;
    }

    public var last_message(get, never):Message;
    function get_last_message():Message {
        if (this.last_message_id != null)
            return this._state._get_message(this.last_message_id);

        return null;
    }

    //TBD
    public function edit() {

    }

    // public override function clone(name:String, reason:String):TextChannel {
        
    // }

    /**
     * Deletes a list of messages. This is similar to `Message.delete` except it bulk deletes multiple messages.
     * 
     * You cannot bulk delete more than 100 messages or messages that
     * are older than 14 days old.
     * 
     * You must have `Permissions.manage_messages` to do this.
     * 
     * @param messages An array of messages denoting which ones to bulk delete.
     * @param reason The reason for deleting the messages. Shows up on the audit log.
     */
    public function delete_messages(messages:Array<Message>, reason:String) {
        if (messages.length == 0)
            return;

        if (messages.length == 1) {
            var message_id:String = messages[0].id;
            this._state.http.delete_message(this.id, message_id);
            return;
        }

        if (messages.length > 100) {
            throw "Can only bulk delete up to 100 messages.";
        }

        var message_ids = [for (m in messages) m.id];
        this._state.http.delete_messages(this.id, message_ids, reason);
    }

    // TBD
    // async def purge(
    // async def webhooks(
    // async def create_webhook(
    // async def follow(

    public function get_partial_message(message_id:String):PartialMessage {
        return new PartialMessage(this, message_id);
    }

    // def get_thread(
    // async def create_thread(
    // async def archived_threads(

    public static function guild_channel_factory(channel_type:ChannelType):Dynamic {
        switch (channel_type) {
            case category:
                return CategoryChannel;
            case text:
                return TextChannel;
            default:
                return null;
        }
    }
}