package discord;

import discord.types.IMessageable;
import discord.types.Snowflake;
import discord.State.ConnectionState;
import discord.User.AvatarDecorationData;
import discord.User.UserPayload;

typedef Nickname = {
    var nick:String;
}

typedef PartialMemberPayload = {
    var roles:Array<String>; // Array<Snowflake>
    var joined_at:String;
    var deaf:Bool;
    var mute:Bool;
    var flags:Int;
}

typedef MemberPayload = {
    >PartialMemberPayload,
    var avatar:String;
    var user:UserPayload;
    var nick:String;
    @:optional var premium_since:String;
    var pending:Bool;
    var permissions:String;
    var communication_disabled_until:String;
    @:optional var avatar_decoration_data:AvatarDecorationData;
}

private typedef _OptionalMemberWithUserPayload = {
    >PartialMemberPayload,
    var avatar:String;
    var nick:String;
    @:optional var premium_since:String;
    var pending:Bool;
    var permissions:String;
    var communication_disabled_until:String;
    @:optional var avatar_decoration_data:AvatarDecorationData;
}

typedef MemberWithUserPayload = {
    >_OptionalMemberWithUserPayload,
    var user:UserPayload;
}

typedef UserWithMemberPayload = {
    >UserPayload,
    var member:_OptionalMemberWithUserPayload;
}

class Member extends User implements IMessageable {
    private var _user:User;
    
    /**
     * The `Guild` this member is in.
     */
    public var guild:Dynamic; // GUILD

    /**
     * `Date` when the `User` joined the `Guild`.
     * If the member left and rejoined the guild, this will be the latest date. In certain cases, this can be `null`.
     */
    public var joined_at:Date;

    /**
     * `Date` when the `User` used their "Nitro boost" on the guild, if available. This could be `null`.
     */
    public var premium_since:Date;

    private var _roles:Array<String>;

    private var _client_status:Dynamic; //_ClientStatus()

    /**
     * The activities that the user is currently doing.
     * Due to a Discord API limitation, a user's Spotify activity may not appear if they are listening to a song with a title longer than 128 characters.
     */
    public var activities:Dynamic; //tuple of ActivityTypes

    /**
     * The guild specific nickname of the user. Takes precedence over the global name.
     */
    public var nick:String;

    /**
     * Whether the member is pending member verification.
     */
    public var pending:Bool;

    private var _permissions:String;

    private var _flags:Int;

    /**
     * A `Date` that specifies the date and time in UTC that the member's time out will expire. This will be set to `null` if the user is not timed out.
     */
    public var timed_out_until:Date;

    public function new(data:MemberWithUserPayload, guild:Dynamic, _state:ConnectionState) {
        super(_state, data.user);

        this._user = _state.store_user(data.user);
        this.guild = guild;
        
        this.joined_at = Date.fromString(data.joined_at);
        this.premium_since = Date.fromString(data.premium_since);

        this._roles = data.roles;
        this._client_status = null;

        this.nick = data.nick;
        this.pending = data.pending;

        this._permissions = data.permissions;
        this._avatar = data.avatar;
        this._flags = data.flags;
        this._avatar_decoration_data = data.avatar_decoration_data;

        this.timed_out_until = Date.fromString(data.communication_disabled_until);
    }

    override public function send(message:String) {

    }
}