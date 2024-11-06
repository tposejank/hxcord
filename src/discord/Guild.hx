package discord;

import discord.Sticker.GuildSticker;
import discord.Member;
import discord.Activity.PartialPresenceUpdate;
import discord.types.Snowflake;
import discord.Role.RolePayload;
import discord.State.ConnectionState;
import discord.Channel;

enum abstract VerificationLevel(Int) from Int to Int {
    var NONE = 0;
    var LOW = 1;
    var MEDIUM = 2;
    var HIGH = 3;
    var VERY_HIGH = 4;
}

enum abstract NSFWLevel(Int) from Int to Int {
    var DEFAULT = 0;
    var EXPLICIT = 1;
    var SAFE = 2;
    var AGE_RESTRICTED = 3;
}

enum abstract PremiumTier(Int) from Int to Int {
    var NONE = 0;
    var TIER_1 = 1;
    var TIER_2 = 2;
    var TIER_3 = 3;
}

enum abstract DefaultMessageNotificationLevel(Int) from Int to Int {
    var ALL_MESSAGES = 0;
    var ONLY_MENTIONS = 1;
}

enum abstract MFALevel(Int) from Int to Int {
    var NONE = 0;
    var ELEVATED = 1;
}

enum abstract ExplicitContentFilterLevel(Int) from Int to Int {
    var DISABLED = 0;
    var MEMBERS_WITHOUT_ROLES = 1;
    var ALL_MEMBERS = 2;
}

enum abstract GuildFeature(String) from String to String {
    var ANIMATED_BANNER = 'ANIMATED_BANNER';
    var ANIMATED_ICON = 'ANIMATED_ICON';
    var APPLICATION_COMMAND_PERMISSIONS_V2 = 'APPLICATION_COMMAND_PERMISSIONS_V2';
    var AUTO_MODERATION = 'AUTO_MODERATION';
    var BANNER = 'BANNER';
    var COMMUNITY = 'COMMUNITY';
    var CREATOR_MONETIZABLE_PROVISIONAL = 'CREATOR_MONETIZABLE_PROVISIONAL';
    var CREATOR_STORE_PAGE = 'CREATOR_STORE_PAGE';
    var DEVELOPER_SUPPORT_SERVER = 'DEVELOPER_SUPPORT_SERVER';
    var DISCOVERABLE = 'DISCOVERABLE';
    var FEATURABLE = 'FEATURABLE';
    var INVITE_SPLASH = 'INVITE_SPLASH';
    var INVITES_DISABLED = 'INVITES_DISABLED';
    var MEMBER_VERIFICATION_GATE_ENABLED = 'MEMBER_VERIFICATION_GATE_ENABLED';
    var MONETIZATION_ENABLED = 'MONETIZATION_ENABLED';
    var MORE_EMOJI = 'MORE_EMOJI';
    var MORE_STICKERS = 'MORE_STICKERS';
    var NEWS = 'NEWS';
    var PARTNERED = 'PARTNERED';
    var PREVIEW_ENABLED = 'PREVIEW_ENABLED';
    var ROLE_ICONS = 'ROLE_ICONS';
    var ROLE_SUBSCRIPTIONS_AVAILABLE_FOR_PURCHASE = 'ROLE_SUBSCRIPTIONS_AVAILABLE_FOR_PURCHASE';
    var ROLE_SUBSCRIPTIONS_ENABLED = 'ROLE_SUBSCRIPTIONS_ENABLED';
    var TICKETED_EVENTS_ENABLED = 'TICKETED_EVENTS_ENABLED';
    var VANITY_URL = 'VANITY_URL';
    var VERIFIED = 'VERIFIED';
    var VIP_REGIONS = 'VIP_REGIONS';
    var WELCOME_SCREEN_ENABLED = 'WELCOME_SCREEN_ENABLED';
    var RAID_ALERTS_DISABLED = 'RAID_ALERTS_DISABLED';
}
typedef IncidentData = {
    var invites_disabled_until:String;
    var dms_disabled_until:String;
}

typedef UnavailableGuildPayload = {
    var id:String;
    @:optional var unavailable:Bool;
}

typedef BaseGuildPreviewPayload = {
    >UnavailableGuildPayload,
    var name:String;
    var icon:String;
    @:optional var splash:String;
    @:optional var discovery_splash:String;
    // var emojis:List[Emoji]
    var stickers:Array<GuildSticker>;
    var features:Array<GuildFeature>;
    var description:String;
    @:optional var incidents_data:IncidentData;
}

typedef GuildPayload = {
    >BaseGuildPreviewPayload,
    var owner_id:String;
    var region:String;
    @:optional var afk_channel_id:String;
    var afk_timeout:Int;
    var verification_level:VerificationLevel;
    var default_message_notifications:DefaultMessageNotificationLevel;
    var explicit_content_filter:ExplicitContentFilterLevel;
    var roles:Array<RolePayload>;
    var mfa_level:MFALevel;
    var nsfw_level:NSFWLevel;
    @:optional var application_id:String;
    @:optional var system_channel_id:String;
    @:optional var system_channel_flags:Int;
    @:optional var rules_channel_id:String;
    @:optional var vanity_url_code:String;
    @:optional var banner:String;
    @:optional var premium_tier:PremiumTier;
    var preferred_locale:String;
    var public_updates_channel_id:String;
    // stage_instances:List[StageInstance]
    // guild_scheduled_events:List[GuildScheduledEvent]
    @:optional var icon_hash:String;
    @:optional var owner:Bool;
    @:optional var permissions:String;
    @:optional var widget_enabled:Bool;
    @:optional var widget_channel_id:String;
    @:optional var joined_at:String;
    @:optional var large:Bool;
    @:optional var member_count:Int;
    // @:optional var voice_states:NotRequired[List[GuildVoiceState]]
    @:optional var members:Array<MemberPayload>;
    @:optional var channels:Array<GuildChannelPayload>; // GuildChannel
    @:optional var presences:Array<PartialPresenceUpdate>;
    // @:optional var threads:NotRequired[List[Thread]]
    @:optional var max_presences:Int;
    @:optional var max_members:Int;
    @:optional var premium_subscription_count:Int;
    @:optional var max_video_channel_users:Int;

    @:optional var approximate_member_count:Int;
    @:optional var approximate_presence_count:Int;
    @:optional var premium_progress_bar_enabled:Bool;    
}

class Guild extends Snowflake {
    private var _channels:Map<String, GuildChannel> = new Map<String, GuildChannel>();
    public var _members:Map<String, Member> = new Map<String, Member>();
    private var _roles:Map<String, Role> = new Map<String, Role>(); // Role
    // self._voice_states:Dict[int, VoiceState] = {}
    // self._threads:Dict[int, Thread] = {}
    // self._stage_instances:Dict[int, StageInstance] = {}
    // self._scheduled_events:Dict[int, ScheduledEvent] = {}
    private var _member_count:Null<Int>;
    private var _state:ConnectionState;

    /**
     * Indicates if the guild is unavailable. If this is `true` then the
     * reliability of other attributes outside of `Guild.id` is slim and they might
     * all be `null`. It is best to not do anything with the guild if it is unavailable.
     */
    public var unavailable:Null<Bool>;
    /**
     * The guild name.
     */
    public var name:String;
    /**
     * The guild's verification level.
     */
    public var verification_level:Null<VerificationLevel>;
    /**
     *  The guild's explicit content filter.
     */
    public var explicit_content_filter:Null<ExplicitContentFilterLevel>;
    /**
     * The number of seconds until someone is moved to the AFK channel.
     */
    public var afk_timeout:Null<Int>;

    private var _icon:String;
    private var _banner:String;

    /**
     * A list of features that the guild has. The features that a guild can have are subject to arbitrary change by Discord. A list of guild features can be found in the Discord documentation.
     */
    public var features:Array<GuildFeature> = [];

    private var _splash:String;
    private var _system_channel_id:String;

    /**
     * The guild's description.
     */
    public var description:String;
    /**
     * The maximum amount of presences for the guild.
     */
    public var max_presences:Null<Int>;
    /**
     * The maximum amount of members for the guild.
     */
    public var max_members:Null<Int>;
    /**
     * The maximum amount of users in a video channel.
     */
    public var max_video_channel_users:Null<Int>;
    /**
     * The premium tier for this guild. Corresponds to "Nitro Server" in the official UI. The number goes from 0 to 3 inclusive.
     */
    public var premium_tier:Null<PremiumTier>;
    /**
     * The number of "boosts" this guild currently has.
     */
    public var premium_subscription_count:Null<Int>;
    /**
     * The guild's vanity url code, if any
     */
    public var vanity_url_code:String;
    /**
     * Indicates if the guild has widget enabled.
     */
    public var widget_enabled:Null<Bool>;

    private var _widget_channel_id:String;
    private var _system_channel_flags:Null<Int>;

    /**
     * The preferred locale for the guild. Used when filtering Server Discovery results to a specific language.
     */
    public var preferred_locale:String;

    private var _discovery_splash:String;
    private var _rules_channel_id:String;
    private var _public_updates_channel_id:String;

    /**
     * The guild's NSFW level.
     */
    public var nsfw_level:Null<NSFWLevel>;
    /**
     * The guild's Multi-Factor Authentication requirement level.
     */
    public var mfa_level:Null<MFALevel>;
    /**
     * The ID of the member that owns the guild.
     */
    public var owner_id:String;

    private var _large:Null<Bool>;
    private var _afk_channel_id:String;
    private var _incidents_data:Null<IncidentData>;
    /**
     * The approximate number of members currently active in the guild. Offline members are excluded.
     * This is `null` unless the guild is obtained using `Client.fetch_guild` or 
     * `Client.fetch_guilds` with `with_counts` set to `true`.
     */
    public var approximate_presence_count:Null<Int>;
    /**
     * The approximate number of members in the guild. This is `null` unless the guild is obtained
     * using `Client.fetch_guild` or `Client.fetch_guilds` with `with_counts` set to `true`.
     */
    public var approximate_member_count:Null<Int>;
    /**
     * Indicates if the guild has premium AKA server boost level progress bar enabled.
     */
    public var premium_progress_bar_enabled:Null<Bool>;

    public function new(data:GuildPayload, _state:ConnectionState) {
        this._state = _state;
        this._from_data(data);
    }

    public function _from_data(data:GuildPayload):Void {
        this.id = data.id;
        this._member_count = data.member_count;
        this.name = data.name;
        this.unavailable = data.unavailable;
        this.verification_level = data.verification_level;
        this.explicit_content_filter = data.explicit_content_filter;
        this.afk_timeout = data.afk_timeout;
        var state:ConnectionState = this._state;
        
        for (role in data.roles ?? []) {
            var role:Role = new Role(this, state, role);
            this._roles.set(role.id, role);
        }

        /**
         *  self.emojis: Tuple[Emoji, ...] = (
                tuple(map(lambda d: state.store_emoji(self, d), guild.get('emojis', [])))
                if state.cache_guild_expressions
                else ()
            )
            self.stickers: Tuple[GuildSticker, ...] = (
                tuple(map(lambda d: state.store_sticker(self, d), guild.get('stickers', [])))
                if state.cache_guild_expressions
                else ()
            )
        */

        this.features = data.features;
        this._system_channel_id = data.system_channel_id;
        this.description = data.description;
        this.max_presences = data.max_presences;
        this.max_members = data.max_members;
        this.max_video_channel_users = data.max_video_channel_users;
        this.premium_tier = data.premium_tier;
        this.premium_subscription_count = data.premium_subscription_count;
        this.vanity_url_code = data.vanity_url_code;
        this.widget_enabled = data.widget_enabled;
        this._widget_channel_id = data.widget_channel_id;
        this._system_channel_flags = data.system_channel_flags;
        this.preferred_locale = data.preferred_locale;
        this._discovery_splash = data.discovery_splash;
        this._rules_channel_id = data.rules_channel_id;
        this._public_updates_channel_id = data.public_updates_channel_id;
        // this._safety_alerts_channel_id = data.safety_alerts_;
        this.nsfw_level = data.nsfw_level;
        this.mfa_level = data.mfa_level;
        this.approximate_presence_count = data.approximate_presence_count;
        this.approximate_member_count = data.approximate_member_count;
        this.premium_progress_bar_enabled = data.premium_progress_bar_enabled;
        this.owner_id = data.owner_id;
        var count:Int = _member_count ?? 0;
        this._large = count >= 250;
        this._afk_channel_id = data.afk_channel_id;
        this._incidents_data = data.incidents_data;

        for (memberData in data.members ?? []) {
            var member:Member = new Member(memberData, this, state);
            _add_member(member);
        }

        for (presence in data.presences ?? []) {
            var user_id = presence.user.id;
            var member = get_member(user_id);
            if (member != null)
                member._presence_update(presence, null);
        }

        // for (channel in data.channels ?? []) {
        //     var channel:BaseChannel;
        //     // _add_channel()
        // }
    }

    /**
     * Returns a member with the given ID.
     * @param user_id The ID to search for.
     */
    public function get_member(user_id:String):Member {
        return this._members.get(user_id);
    }

    public function _add_member(member:Member):Void {
        this._members.set(member.id, member);
    }

    /**
     * Returns a channel with the given ID.
     * @param channel_id The ID to search for.
     */
    public function get_channel(channel_id:String) {
        return this._channels.get(channel_id);
    }

    /**
     * Returns a role with the given ID.
     * @param role_id The ID to search for.
     */
    public function get_role(role_id:String):Role {
        return this._roles.get(role_id);
    }

    /**
     * A list of channels that belongs to this guild.
     */
    public var channels(get, never):Array<GuildChannel>;
    function get_channels():Array<GuildChannel> {
        var values:Array<GuildChannel> = [];
        for (c in _channels.iterator()) {
            values.push(c);
        }
        return values;
    }
 
    /**
     * Similar to `Client.user` except an instance of `Member`.
     * This is essentially used to get the member version of yourself.
     */
    public var me(get, never):Member;
    function get_me():Member {
        return this.get_member(this._state.user.id);
    }

    /**
     * Gets the @everyone role that all members have by default.
     */
    public var default_role(get, never):Role;
    function get_default_role():Role  {
        return this._roles.get(this.id);
    }

    /**
     * Returns a boolean indicating if the guild is "chunked".
     * 
     * A chunked guild means that `member_count` is equal to the
     * number of members stored in the internal `members` cache.
     * 
     * If this value returns `false`, then you should request for
     * offline members.
     */
    public var chunked(get, never):Null<Bool>;
    // chunking is not a priority right now
    function get_chunked():Bool {
        var count = this._member_count;
        if (count == null) return false;

        return count == Lambda.count(this._members);
    }
}

// todo: permission overwrites