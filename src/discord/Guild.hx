package discord;

import discord.types.Snowflake;
import discord.Role.RolePayload;
import discord.State.ConnectionState;

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

typedef UnavailableGuildPayload = {
    var id: String;
    @:optional var unavailable: Bool;
}

typedef BaseGuildPreviewPayload = {
    >UnavailableGuildPayload,
    var name: String;
    var icon: String;
    @:optional var splash: String;
    @:optional var discovery_splash: String;
    // var emojis: List[Emoji]
    // var stickers: List[GuildSticker]
    // var features: List[GuildFeature]
    // var description: Optional[str]
    // var incidents_data: Optional[IncidentData]
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
    var roles: Array<RolePayload>;
    var mfa_level: MFALevel;
    var nsfw_level: NSFWLevel;
    @:optional var application_id: String;
    @:optional var system_channel_id: String;
    @:optional var system_channel_flags: Int;
    @:optional var rules_channel_id: String;
    @:optional var vanity_url_code: String;
    @:optional var banner: String;
    @:optional var premium_tier: PremiumTier;
    var preferred_locale: String;
    var public_updates_channel_id: String;
    // var stickers: List[GuildSticker]
    // stage_instances: List[StageInstance]
    // guild_scheduled_events: List[GuildScheduledEvent]
    // icon_hash: NotRequired[Optional[str]]
    // owner: NotRequired[bool]
    // permissions: NotRequired[str]
    // widget_enabled: NotRequired[bool]
    // widget_channel_id: NotRequired[Optional[Snowflake]]
    // joined_at: NotRequired[Optional[str]]
    // large: NotRequired[bool]
    // member_count: NotRequired[int]
    // voice_states: NotRequired[List[GuildVoiceState]]
    // members: NotRequired[List[Member]]
    // channels: NotRequired[List[GuildChannel]]
    // presences: NotRequired[List[PartialPresenceUpdate]]
    // threads: NotRequired[List[Thread]]
    // max_presences: NotRequired[Optional[int]]
    // max_members: NotRequired[int]
    // premium_subscription_count: NotRequired[int]
    // max_video_channel_users: NotRequired[int]
} 

class Guild extends Snowflake {
    public var unavailable:Bool;

    public function new(data:GuildPayload, _state:ConnectionState) {
        trace(data);

        this.id = data.id;
    }
}