package discord;

import discord.Activity.ClientStatus;
import discord.Activity.PartialPresenceUpdate;
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

class _ClientStatus {
    public var _status:String = 'offline';
    public var desktop:String;
    public var mobile:String;
    public var web:String;

    public function new() {
        
    }

    public function _update(status:String, data:ClientStatus) {
        _status = status;
        desktop = data.desktop;
        mobile = data.mobile;
        web = data.web;
    }
}

class Member extends Snowflake implements IMessageable {
    private var _user:User;

    /**
     * The member's username.
     */
    public var name(get, set):String;
    public function get_name() return _user.name;
    public function set_name(n) return _user.name = n;

    /**
     * The member's discriminator. This is a legacy concept that is no longer used.
     */
    public var discriminator(get, set):String;
    public function get_discriminator() return _user.discriminator;
    public function set_discriminator(n) return _user.discriminator = n;

    /**
     * The member's global nickname, taking precedence over the username in display.
     */
    public var global_name(get, set):String;
    public function get_global_name() return _user.global_name;
    public function set_global_name(n) return _user.global_name = n;

    /**
     * Specifies if the user is a bot account.
     */
    public var bot(get, set):Null<Bool>;
    public function get_bot() return _user.bot;
    public function set_bot(n) return _user.bot = n;

    /**
     * Specifies if the user is a system user (i.e. represents Discord officially).
     */
    public var system(get, set):Null<Bool>;
    public function get_system() return _user.system;
    public function set_system(n) return _user.system = n;

    /**
     * Returns a string that allows you to mention the member.
     */
    public var mention(get, never):String;
    public function get_mention() return _user.mention;

    /**
     * `PublicFlags`: The publicly available flags the member has.
     */
    public var public_flags(get, never):Dynamic;
    public function get_public_flags() return _user.public_flags;

    /**
     * `Asset`: Returns an `Asset` for the global avatar the member has.
     * 
     * If the user has not uploaded a global avatar, `null` is returned.
     * 
     * If you want the avatar that a member has displayed, consider `display_avatar`.
     */
    public var avatar(get, never):Asset;
    public function get_avatar() return _user.avatar;

    /**
     * `Asset`: Returns the default avatar for a given user.
     */
    public var default_avatar(get, never):Asset;
    public function get_default_avatar() return _user.default_avatar;

    /**
     * `Asset`: Returns the avatar decoration the member has.
     * 
     * If the member has not set an avatar decoration, `null` is returned.
     */
    public var avatar_decoration(get, never):Asset;
    public function get_avatar_decoration() return _user.avatar_decoration;
    
    /**
     * Returns the SKU ID of the avatar decoration the user has.
     * 
     * If the user has not set an avatar decoration, `null` is returned.
     */
    public var avatar_decoration_sku_id(get, never):Dynamic;
    public function get_avatar_decoration_sku_id() return _user.avatar_decoration_sku_id;

    /**
     * `Asset`: Returns the user's banner asset, if available.
     * 
     * This information is only available via `Client.fetch_user`.
     */
    public var banner(get, never):Asset;
    public function get_banner() return _user.banner;

    /**
     * A user's accent color is only shown if they do not have a banner.
     * This will only be available if the user explicitly sets a color.
     */
    public var accent_colour(get, never):Colour;
    public function get_accent_colour() return _user.accent_colour;

    /**
     * A property that returns a colour denoting the rendered colour
     * for the user. This always returns 0xFF000000.
     */
    public var colour(get, never):Colour;
    public function get_colour() return _user.colour;

    /**
     * Returns the user's creation time in UTC.
     * This is when the user's Discord account was created.
     */
    public var created_at(get, never):Date;
    public function get_created_at() return _user.created_at;

    /**
     * Returns the user's display name.
     * 
     * For regular users this is just their global name or their username, 
     * but if they have a guild specific nickname then
     * that is returned instead.
     */
    public var display_name(get, never):String;
    public function get_display_name() {
        return nick ?? (global_name ?? name);
    }

    /**
     * Returns the member's display avatar.
     * 
     * For regular members this is just their avatar, but
     * if they have a guild specific avatar then that
     * is returned instead.
     */
    public var display_avatar(get, never):Asset; // ASSET
    public function get_display_avatar() {
        return guild_avatar ?? (_user.avatar ?? _user.default_avatar);
    }

    /**
     * Returns the member's display avatar.
     * 
     * For regular members this is just their avatar, but
     * if they have a guild specific avatar then that
     * is returned instead.
     */
    public var guild_avatar(get, never):Dynamic; // ASSET
    public function get_guild_avatar() {
        return null;
        /**
         *  if self._avatar is None:
                return None
            return Asset._from_guild_avatar(self._state, self.guild.id, self.id, self._avatar)
        */
    }

    // Member variables

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

    /**
     * The activities that the user is currently doing.
     * Due to a Discord API limitation, a user's Spotify activity may not appear if they are listening to a song with a title longer than 128 characters.
     */
    public var activities:Array<Dynamic> = []; //tuple of ActivityTypes

    /**
     * The guild specific nickname of the user. Takes precedence over the global name.
     */
    public var nick:String;

    /**
     * Whether the member is pending member verification.
     */
    public var pending:Bool;

    /**
     * A `Date` that specifies the date and time in UTC that the member's time out will expire. This will be set to `null` if the user is not timed out.
     */
    public var timed_out_until:Date;

    private var _avatar:String;

    public var _avatar_decoration_data(get, set):AvatarDecorationData;
    public function get__avatar_decoration_data() return _user._avatar_decoration_data;
    public function set__avatar_decoration_data(n) return _user._avatar_decoration_data = n;
    
    private var _roles:Array<String> = [];
    private var _client_status:_ClientStatus;
    private var _permissions:String;
    private var _flags:Int;

    private var _state:ConnectionState;

    public function new(data:MemberWithUserPayload, guild:Guild, _state:ConnectionState) {
        this._state = _state;
        
        this._user = _state.store_user(data.user);
        this.guild = guild;

        this.id = _user.id;

        this.joined_at = Utils.iso8601_to_date(data.joined_at);
        if (data.premium_since != null)
            this.premium_since = Utils.iso8601_to_date(data.premium_since);

        this._roles = data.roles;
        this._client_status = null;

        this.nick = data.nick;
        this.pending = data.pending;

        this._permissions = data.permissions;
        this._flags = data.flags;

        this._avatar = data.avatar; // Member.avatar is not related to User.avatar
        this._avatar_decoration_data = data.avatar_decoration_data;

        this.timed_out_until = null; //Date.fromString(data.communication_disabled_until);
    }

    public function _presence_update(data:PartialPresenceUpdate, user:UserPayload):Bool {
        this.activities = []; //activity.py
        for (activity in data.activities) {
            this.activities.push(activity);
        }

        // Technically, user is already available in data.user
        // But discord.py does this!
        if (user != null)
            return _update_inner_user(user);

        return false;
    }

    public function _update_inner_user(data:UserPayload):Bool {
        var u = this._user;
        var original:Array<Dynamic> = [
            u.name, 
            u.discriminator, 
            u._avatar, 
            u.global_name, 
            u._public_flags, 
            u._avatar_decoration_data?.sku_id
        ];
        var modified:Array<Dynamic> = [
            data.username ?? u.name,
            data.discriminator ?? u.discriminator, 
            data.avatar ?? u._avatar, 
            data.global_name ?? u.global_name, 
            data.public_flags ?? u._public_flags, 
            (data.avatar_decoration_data?.sku_id) ?? (u._avatar_decoration_data?.sku_id)
        ];

        var notDiff = 
           original[0] == modified[0] 
        && original[1] == modified[1]
        && original[2] == modified[2]
        && original[3] == modified[3]
        && original[4] == modified[4]
        && original[5] == modified[5];

        // Array comparing is kinda fd up
        if (!notDiff) {
            _user.name = data.username;
            _user.discriminator = data.discriminator;
            _user._avatar = data.avatar;
            _user.global_name = data.global_name;
            _user._public_flags = data.public_flags;
            _user._avatar_decoration_data = data.avatar_decoration_data;
            return true;
        }

        return false;
    }

    public function send(message:String):Dynamic {
        return null;
    }
}