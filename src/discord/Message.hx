package discord;

import discord.State.ConnectionState;
import discord.types.Snowflake;
import discord.Member.MemberPayload;
import discord.Member.UserWithMemberPayload;
import discord.User.UserPayload;
import discord.Member.PartialMemberPayload;

/**
 * Value from 0 to 39.
 */
enum abstract MessageType(Int) from Int to Int {}

typedef PartialMessagePayload = {
    var channel_id:String;
    @:optional var guild_id:String;
}

typedef ChannelMentionPayload = {
    var id:String;
    var guild_id:String;
    var type:Int; // 0, 1, 2, 3, 4, 5, 6, 13, 15, 16 and 10, 11, 12
    var name:String;
}

typedef ReactionCountDetails = {
    var burst:Int;
    var normal:Int;
}

typedef ReactionPayload = {
    var count:Int;
    var me:Bool;
    var emoji:Dynamic; // PartialEmoji
    var me_burst:Bool;
    var count_details:ReactionCountDetails;
    var burst_colors:Array<String>;
}

typedef AttachmentPayload = {
    var id:String;
    var filename:String;
    var size:Int;
    var url:String;
    var proxy_url:String;
    @:optional var height:Int;
    @:optional var width:Int;
    @:optional var description:String;
    @:optional var content_type:String;
    @:optional var spoiler:Bool;
    @:optional var ephemeral:Bool;
    @:optional var duration_secs:Float;
    @:optional var waveform:String;
    @:optional var flags:Int;
}

typedef MessageActivity = {
    var type:Int; // 1, 2, 3, 5
    var party_id:String;
}

typedef MessageApplication = {
    var id:String;
    var description:String;
    @:optional var icon:String;
    var name:String;
    @:optional var cover_image:String;
}

typedef MessageReference = {
    var message_id:String;
    var channel_id:String;
    var guild_id:String;
    var fail_if_not_exists:Bool;
}

typedef RoleSubscriptionData = {
    var role_subscription_listing_id:String;
    var tier_name:String;
    var total_months_subscribed:Int;
    var is_renewal:Bool;
}

typedef MessagePayload = {
    >PartialMemberPayload,
    var id:String;
    var author:UserPayload;
    var content:String;
    var timestamp:String;
    @:optional var edited_timestamp:String;
    var tts:Bool;
    var mention_everyone:Bool;
    var mentions:Array<UserWithMemberPayload>;
    var mention_roles:Array<String>;
    var attachments:Array<AttachmentPayload>;
    var embeds:Array<Dynamic>; //EMBED
    var pinned:Bool;
    @:optional var poll:Dynamic; // Poll
    var type:MessageType;
    @:optional var member:MemberPayload;
    @:optional var mention_channels:Array<ChannelMentionPayload>;
    @:optional var reactions:Array<ReactionPayload>;
    @:optional var nonce:String;
    @:optional var webhook_id:String;
    @:optional var activity:MessageActivity;
    @:optional var application:MessageApplication;
    @:optional var application_id:String;
    @:optional var message_reference:MessageReference;
    @:optional var flags:Int;
    @:optional var sticker_items:Array<Dynamic>; //StickerItem
    @:optional var referenced_message:MessagePayload;
    // @:optional var interaction:Interaction
    @:optional var interaction_metadata:Dynamic;
    // @:optional var components:Component
    @:optional var position:Int;
    @:optional var role_subscription_data:RoleSubscriptionData;
    @:optional var thread:Dynamic; // Thread
}

/**
 * Represents a partial message to aid with working messages when only
 * a message and channel ID are present.
 * 
 * There are two ways to construct this class. The first one is through
 * the constructor itself, and the second is via the following:
 * 
 * // TBD
 * 
 * Note that this class is trimmed down and has no rich attributes.
 */
class PartialMessage extends Snowflake {
    /**
     * The channel associated with this partial message.
     */
    public var channel:Dynamic;
    public var _state:ConnectionState;

    /**
     * The guild that the partial message belongs to, if applicable.
     */
    public var guild:Guild;

    /**
     * `Date`: The partial message's creation time in UTC.
     */
    public var created_at(get, never):Date;

    /**
     * Returns a URL that allows the client to jump to this message.
     */
    public var jump_url(get, never):String;

    /**
     * The public thread created from this message, if it exists.
     * 
     * This does not retrieve archived threads, as they are not retained in the internal
     * cache. Use `fetch_thread` instead.
     */
    public var thread(get, never):Dynamic;

    public function new(channel:Dynamic, id:String) { // CHANNEL!!
        // check here if channel is valid

        this._state = null; // supposed to be channel._state;
        this.id = id;
        this.guild = channel?.guild ?? null;
    }

    public function _update(data:Dynamic):Void {}

    // WHAT THE HELL IS DUCK TYPING BRO :sob:

    function get_created_at():Date {
        return Utils.snowflake_time(this.id);
    }

    function get_jump_url():String {
        var guild_id:String = this.guild?.id ?? '@me';
        return 'https://discord.com/channels/${guild_id}/${this.channel?.id ?? null}/${this.id}';
    }

    function get_thread():Dynamic {
        return null;
    }

    /**
     * Fetches the partial message to a full `Message`.
     * 
     * Raises:
     * - `NotFound`: The message was not found.
     * - `Forbidden`: You do not have the permissions required to get a message.
     * - `HTTPException`: Retrieving the message failed.
     * 
     * @return `Message`: The full message.
     */
    public function fetch():Message { // TBD I NEED AN ENDPOINT CLASS
        var data = null;
        return null;
    }
}

class Message extends PartialMessage {}