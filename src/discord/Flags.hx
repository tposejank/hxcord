package discord;

/**
 * The bit-wise integers which represent each intent.
 */
enum abstract Intent(Int) from Int to Int {
    var GUILDS = 1 << 0;
    var GUILD_MEMBERS = 1 << 1;
    var GUILD_MODERATION = 1 << 2;
    var GUILD_EXPRESSIONS = 1 << 3;
    var GUILD_INTEGRATIONS = 1 << 4;
    var GUILD_WEBHOOKS = 1 << 5;
    var GUILD_INVITES = 1 << 6;
    var GUILD_VOICE_STATES = 1 << 7;
    var GUILD_PRESENCES = 1 << 8;
    var GUILD_MESSAGES = 1 << 9;
    var GUILD_MESSAGE_REACTIONS = 1 << 10;
    var GUILD_MESSAGE_TYPING = 1 << 11;
    var DIRECT_MESSAGES = 1 << 12;
    var DIRECT_MESSAGE_REACTIONS = 1 << 13;
    var DIRECT_MESSAGE_TYPING = 1 << 14;
    var MESSAGE_CONTENT = 1 << 15;
    var GUILD_SCHEDULED_EVENTS = 1 << 16;
    var AUTO_MODERATION_CONFIGURATION = 1 << 20;
    var AUTO_MODERATION_EXECUTION = 1 << 21;
    var GUILD_MESSAGE_POLLS = 1 << 24;
    var DIRECT_MESSAGE_POLLS = 1 << 25;
}

class Intents {
    /**
     * Corresponds to the following:
     * - GUILD_CREATE
     * - GUILD_UPDATE
     * - GUILD_DELETE
     * - GUILD_ROLE_CREATE
     * - GUILD_ROLE_UPDATE
     * - GUILD_ROLE_DELETE
     * - CHANNEL_CREATE
     * - CHANNEL_UPDATE
     * - CHANNEL_DELETE
     * - CHANNEL_PINS_UPDATE
     * - THREAD_CREATE
     * - THREAD_UPDATE
     * - THREAD_DELETE
     * - THREAD_LIST_SYNC
     * - THREAD_MEMBER_UPDATE
     * - THREAD_MEMBERS_UPDATE *
     * - STAGE_INSTANCE_CREATE
     * - STAGE_INSTANCE_UPDATE
     * - STAGE_INSTANCE_DELETE
     * 
     * `*` Thread Members Update contains different data depending on which intents are used.
     */
    public var guilds:Bool = false;

    /**
     * Corresponds to the following: **
     * - GUILD_MEMBER_ADD
     * - GUILD_MEMBER_UPDATE
     * - GUILD_MEMBER_REMOVE
     * - THREAD_MEMBERS_UPDATE *
     * 
     * `*` Thread Members Update contains different data depending on which intents are used.
     * 
     * `**` Events under the `GUILD_PRESENCES` and `GUILD_MEMBERS` intents are turned **off by default on all API versions.** If you are using **API v6**, you will receive those events if you are authorized to receive them and have enabled the intents in the Developer Portal. You do not need to use intents on API v6 to receive these events; you just need to enable the flags. If you are using **API v8** or above, intents are mandatory and must be specified when identifying.
     */
    public var guildMembers:Bool = false;

    /**
     * Corresponds to the following:
     * - GUILD_AUDIT_LOG_ENTRY_CREATE
     * - GUILD_BAN_ADD
     * - GUILD_BAN_REMOVE
     */
    public var guildModeration:Bool = false;

    /**
     * Corresponds to the following:
     * - GUILD_EMOJIS_UPDATE
     * - GUILD_STICKERS_UPDATE
     * - GUILD_SOUNDBOARD_SOUND_CREATE
     * - GUILD_SOUNDBOARD_SOUND_UPDATE
     * - GUILD_SOUNDBOARD_SOUND_DELETE
     * - GUILD_SOUNDBOARD_SOUNDS_UPDATE
     */
    public var guildExpressions:Bool = false;

    /**
     * Corresponds to the following:
     * - GUILD_INTEGRATIONS_UPDATE
     * - INTEGRATION_CREATE
     * - INTEGRATION_UPDATE
     * - INTEGRATION_DELETE
     */
    public var guildIntegrations:Bool = false;

    /**
     * Corresponds to the following:
     * - WEBHOOKS_UPDATE
     */
    public var guildWebhooks:Bool = false;

    /**
     * Corresponds to the following:
     * - INVITE_CREATE
     * - INVITE_DELETE
     */
    public var guildInvites:Bool = false;

    /**
     * Corresponds to the following:
     * - VOICE_CHANNEL_EFFECT_SEND
     * - VOICE_STATE_UPDATE
     */
    public var guildVoiceStates:Bool = false;

    /**
     * Corresponds to the following: **
     * - PRESENCE_UPDATE
     * 
     * `**` Events under the `GUILD_PRESENCES` and `GUILD_MEMBERS` intents are turned **off by default on all API versions.** If you are using **API v6**, you will receive those events if you are authorized to receive them and have enabled the intents in the Developer Portal. You do not need to use intents on API v6 to receive these events; you just need to enable the flags. If you are using **API v8** or above, intents are mandatory and must be specified when identifying.
     */
    public var guildPresences:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_CREATE
     * - MESSAGE_UPDATE
     * - MESSAGE_DELETE
     * - MESSAGE_DELETE_BULK
     */
    public var guildMessages:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_REACTION_ADD
     * - MESSAGE_REACTION_REMOVE
     * - MESSAGE_REACTION_REMOVE_ALL
     * - MESSAGE_REACTION_REMOVE_EMOJI
     */
    public var guildMessageReactions:Bool = false;

    /**
     * Corresponds to the following:
     * - TYPING_START
     */
    public var guildMessageTyping:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_CREATE
     * - MESSAGE_UPDATE
     * - MESSAGE_DELETE
     * - CHANNEL_PINS_UPDATE
     */
    public var directMessages:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_REACTION_ADD
     * - MESSAGE_REACTION_REMOVE
     * - MESSAGE_REACTION_REMOVE_ALL
     * - MESSAGE_REACTION_REMOVE_EMOJI
     */
    public var directMessageReactions:Bool = false;

    /**
     * Corresponds to the following:
     * - TYPING_START
     */
    public var directMessageTyping:Bool = false;

    /**
     * *Directly defined by itelf* ***
     * 
     * `***` `MESSAGE_CONTENT` does not represent individual events, but rather affects what data is present for events that could contain message content fields. More information is in the [message content intent](https://discord.com/developers/docs/topics/gateway#message-content-intent) section.
     */
    public var messageContent:Bool = false;

    /**
     * Corresponds to the following:
     * - GUILD_SCHEDULED_EVENT_CREATE
     * - GUILD_SCHEDULED_EVENT_UPDATE
     * - GUILD_SCHEDULED_EVENT_DELETE
     * - GUILD_SCHEDULED_EVENT_USER_ADD
     * - GUILD_SCHEDULED_EVENT_USER_REMOVE
     */
    public var guildScheduledEvents:Bool = false;

    /**
     * Corresponds to the following:
     * - AUTO_MODERATION_RULE_CREATE
     * - AUTO_MODERATION_RULE_UPDATE
     * - AUTO_MODERATION_RULE_DELETE
     */
    public var autoModerationConfiguration:Bool = false;

    /**
     * Corresponds to the following:
     * - AUTO_MODERATION_ACTION_EXECUTION
     */
    public var autoModerationExecution:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_POLL_VOTE_ADD
     * - MESSAGE_POLL_VOTE_REMOVE
     */
    public var guildMessagePolls:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_POLL_VOTE_ADD
     * - MESSAGE_POLL_VOTE_REMOVE
     */
    public var directMessagePolls:Bool = false;

    /**
     * The real Discord Intent integer of this `Intents`.
     * 
     * You must use this after setting your properties:
     * 
     * ```haxe
     * intents = new Intents();
     * intents.directMessagePolls = true;
     * trace(intents.value); // 33554432
     * ```
     * 
     * If you wish to create an `Intents` from a Discord Intent integer,
     * use `Intents.fromValue` instead.
     */
    public var value(get, never):Int;

    public function new() {}

    public function get_value():Int {
        var v:Int = 0;
        if (guilds) v |= Intent.GUILDS;
        if (guildMembers) v |= Intent.GUILD_MEMBERS;
        if (guildModeration) v |= Intent.GUILD_MODERATION;
        if (guildExpressions) v |= Intent.GUILD_EXPRESSIONS;
        if (guildIntegrations) v |= Intent.GUILD_INTEGRATIONS;
        if (guildWebhooks) v |= Intent.GUILD_WEBHOOKS;
        if (guildInvites) v |= Intent.GUILD_INVITES;
        if (guildVoiceStates) v |= Intent.GUILD_VOICE_STATES;
        if (guildPresences) v |= Intent.GUILD_PRESENCES;
        if (guildMessages) v |= Intent.GUILD_MESSAGES;
        if (guildMessageReactions) v |= Intent.GUILD_MESSAGE_REACTIONS;
        if (guildMessageTyping) v |= Intent.GUILD_MESSAGE_TYPING;
        if (directMessages) v |= Intent.DIRECT_MESSAGES;
        if (directMessageReactions) v |= Intent.DIRECT_MESSAGE_REACTIONS;
        if (directMessageTyping) v |= Intent.DIRECT_MESSAGE_TYPING;
        if (messageContent) v |= Intent.MESSAGE_CONTENT;
        if (guildScheduledEvents) v |= Intent.GUILD_SCHEDULED_EVENTS;
        if (autoModerationConfiguration) v |= Intent.AUTO_MODERATION_CONFIGURATION;
        if (autoModerationExecution) v |= Intent.AUTO_MODERATION_EXECUTION;
        if (guildMessagePolls) v |= Intent.GUILD_MESSAGE_POLLS;
        if (directMessagePolls) v |= Intent.DIRECT_MESSAGE_POLLS;
        return v;
    }

    /**
     * Create an `Intents` instance from a Discord Intent integer.
     * @param value Intent integer
     * @return Intents
     */
    public static function fromValue(value:Int):Intents {
        var intents:Intents = new Intents();
        intents.guilds = (value & Intent.GUILDS) != 0;
        intents.guildMembers = (value & Intent.GUILD_MEMBERS) != 0;
        intents.guildModeration = (value & Intent.GUILD_MODERATION) != 0;
        intents.guildExpressions = (value & Intent.GUILD_EXPRESSIONS) != 0;
        intents.guildIntegrations = (value & Intent.GUILD_INTEGRATIONS) != 0;
        intents.guildWebhooks = (value & Intent.GUILD_WEBHOOKS) != 0;
        intents.guildInvites = (value & Intent.GUILD_INVITES) != 0;
        intents.guildVoiceStates = (value & Intent.GUILD_VOICE_STATES) != 0;
        intents.guildPresences = (value & Intent.GUILD_PRESENCES) != 0;
        intents.guildMessages = (value & Intent.GUILD_MESSAGES) != 0;
        intents.guildMessageReactions = (value & Intent.GUILD_MESSAGE_REACTIONS) != 0;
        intents.guildMessageTyping = (value & Intent.GUILD_MESSAGE_TYPING) != 0;
        intents.directMessages = (value & Intent.DIRECT_MESSAGES) != 0;
        intents.directMessageReactions = (value & Intent.DIRECT_MESSAGE_REACTIONS) != 0;
        intents.directMessageTyping = (value & Intent.DIRECT_MESSAGE_TYPING) != 0;
        intents.messageContent = (value & Intent.MESSAGE_CONTENT) != 0;
        intents.guildScheduledEvents = (value & Intent.GUILD_SCHEDULED_EVENTS) != 0;
        intents.autoModerationConfiguration = (value & Intent.AUTO_MODERATION_CONFIGURATION) != 0;
        intents.autoModerationExecution = (value & Intent.AUTO_MODERATION_EXECUTION) != 0;
        intents.guildMessagePolls = (value & Intent.GUILD_MESSAGE_POLLS) != 0;
        intents.directMessagePolls = (value & Intent.DIRECT_MESSAGE_POLLS) != 0;
        return intents;
    }

    /**
     * A factory method that creates an `Intents` with everything enabled.
     * @return Intents
     */
    public static function all():Intents {
        var intents:Intents = new Intents();
        intents.guilds = true;
        intents.guildMembers = true;
        intents.guildModeration = true;
        intents.guildExpressions = true;
        intents.guildIntegrations = true;
        intents.guildWebhooks = true;
        intents.guildInvites = true;
        intents.guildVoiceStates = true;
        intents.guildPresences = true;
        intents.guildMessages = true;
        intents.guildMessageReactions = true;
        intents.guildMessageTyping = true;
        intents.directMessages = true;
        intents.directMessageReactions = true;
        intents.directMessageTyping = true;
        intents.messageContent = true;
        intents.guildScheduledEvents = true;
        intents.autoModerationConfiguration = true;
        intents.autoModerationExecution = true;
        intents.guildMessagePolls = true;
        intents.directMessagePolls = true;
        return intents;
    }

    /**
     * A factory method that creates an `Intents` with everything disabled.
     * @return Intents
     */
    public static function none():Intents {
        return fromValue(0);
    }

    /**
     * A factory method that creates an `Intents` instance with everything enabled except:
     * - `guildPresences`
     * - `guildMembers`
     * - `messageContent`
     * @return Intents
     */
    public static function default_intents():Intents {
        var intents:Intents = all();
        intents.guildPresences = false;
        intents.guildMembers = false;
        intents.messageContent = false;
        return intents;
    }
}