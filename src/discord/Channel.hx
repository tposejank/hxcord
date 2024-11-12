package discord;

import discord.utils.errors.Errors.TypeError;
import discord.Permissions.Permission;
import haxe.ValueException;
import haxe.exceptions.NotImplementedException;
import discord.State.ConnectionState;
import discord.Snowflake;

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

    public var type:Int; // ENUM!!!

    public var category_id:String;

    public var _overwrites:Array<Dynamic>;

    public var _sorting_bucket(get, never):Int;

    public function _update(guild:Guild, data:Dynamic) {
        throw new NotImplementedException();
    }

    function get__sorting_bucket():Int {
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
    public var category(get, never):GuildChannel; // categorychannel
    function get_category() {
        return guild.get_channel(category_id);
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

    public function clone(name:String, reason:String) {
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

    public function send(params:MessageParameters):Message {
        if (params.content == null && params.embeds == null) {
            throw new TypeError('Either content or embeds must be null, not both');
        }

        var channel = _get_channel();
        var state = _state;

        

        return null;
    }
}