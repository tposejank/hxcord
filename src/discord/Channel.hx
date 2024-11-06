package discord;

import discord.types.OneOfTwo;
import haxe.ValueException;
import haxe.exceptions.NotImplementedException;
import discord.State.ConnectionState;
import discord.types.Snowflake;
import discord.types.IMessageable;

typedef BaseChannel = {
    var id:String;
    var name:String;
}

typedef BaseGuildChannel = {
    >BaseChannel,
    var guild_id:String;
    var position:Int;
    // var permission_overw  permissions later
    var nsfw:Bool;
    @:optional var parent_id:String;
}

typedef BaseTextChannel = {
    >BaseGuildChannel,
    var topic:String;
    @:optional var last_message_id:String;
    var last_pin_timestamp:String;
    var rate_limit_per_user:Int;
    var default_thread_rate_limit_per_user:Int;
    var default_auto_archive_duration:Int; // seconds (??)
    var type:Int; // make enum ChannelType or smth
}

typedef TextChannelPayload = {
    >BaseTextChannel,
    var type:Int;
}

typedef NewsChannelPayload = {
    >BaseTextChannel,
    var type:Int;
}

typedef VoiceChannelPayload = {
    >BaseTextChannel,
    var type:Int;
    var bitrate:Int;
    var user_limit:Int;
    @:optional var rtc_region:String;
    var video_quality_mode:Int; // 1, 2
}

typedef CategoryChannel = {
    >BaseGuildChannel,
    var type:Int;
}

typedef StageChannel = {
    >BaseGuildChannel,
    var type:Int;
    var bitrate:Int;
    var user_limit:Int;
    @:optional var rtc_region:String;
}

// typedef Thread  i hate threads

typedef ForumTag = {
    var id:String;
    var name:String;
    var moderated:Bool;
    @:optional var emoji_id:String;
    @:optional var emoji_name:String;
}

typedef DefaultReaction = {
    var emoji_id:String;
    var emoji_name:String;
}

typedef BaseForumChannel = {
    >BaseTextChannel,
    var available_tags:Array<ForumTag>;
    @:optional var default_reaction_emoji:DefaultReaction;
    @:optional var default_sort_order:Int; // 0, 1
    @:optional var default_forum_layout:Int; // 0, 1, 2
    @:optional var flags:Int;
}

typedef ForumChannel = {
    >BaseForumChannel,
    var type:Int;
}

typedef MediaChannel = {
    >BaseForumChannel,
    var type:Int;
}

typedef GuildChannelPayload = {
    >TextChannelPayload,
    >NewsChannelPayload,
    >VoiceChannelPayload,
    >CategoryChannel,
    >StageChannel,
    // thread
    >ForumChannel,
    >MediaChannel,
}

class GuildChannel extends Snowflake implements IMessageable { // abc
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

    public var _state:ConnectionState;

    public var _overwrites:Array<Dynamic>;

    public var _sorting_bucket(get, never):Int;

    public function _update(guild:Guild, data:Dynamic) {
        throw new NotImplementedException();
    }

    function get__sorting_bucket():Int {
        throw new NotImplementedException();
    }

    public function toString():String return this.name;

    public function send(message:String):Message {
        return null;
    }

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
        for (_index in 0...channels.length) {
            var c = channels[_index];
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
    public function get_mention():String return '<#${this.id}>';

    /**
     * Returns a URL that allows the client to jump to the channel.
     */
    public var jump_url(get, never):String;
    public function get_jump_url():String return 'https://discord.com/channels/${this.guild.id}/${this.id}';
    
    /**
     * Returns the channel's creation time in UTC.
     */
    public var created_at(get, never):Date;
    public function get_created_at():Date return Utils.snowflake_time(this.id);

    /**
     * The category this channel belongs to.
     * 
     * If there is no category then this is `null`.
     */
    public var category(get, never):GuildChannel; // categorychannel
    public function get_category() {
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
        if (guild.owner_id == obj.id) {
            return Permissions.all();
        }
        
        // bro wheres unions
        // var default_role 

        return null;
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