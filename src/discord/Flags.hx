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
    public var guild_members:Bool = false;

    /**
     * Corresponds to the following:
     * - GUILD_AUDIT_LOG_ENTRY_CREATE
     * - GUILD_BAN_ADD
     * - GUILD_BAN_REMOVE
     */
    public var guild_moderation:Bool = false;

    /**
     * Corresponds to the following:
     * - GUILD_EMOJIS_UPDATE
     * - GUILD_STICKERS_UPDATE
     * - GUILD_SOUNDBOARD_SOUND_CREATE
     * - GUILD_SOUNDBOARD_SOUND_UPDATE
     * - GUILD_SOUNDBOARD_SOUND_DELETE
     * - GUILD_SOUNDBOARD_SOUNDS_UPDATE
     */
    public var guild_expressions:Bool = false;

    /**
     * Corresponds to the following:
     * - GUILD_INTEGRATIONS_UPDATE
     * - INTEGRATION_CREATE
     * - INTEGRATION_UPDATE
     * - INTEGRATION_DELETE
     */
    public var guild_integrations:Bool = false;

    /**
     * Corresponds to the following:
     * - WEBHOOKS_UPDATE
     */
    public var guild_webhooks:Bool = false;

    /**
     * Corresponds to the following:
     * - INVITE_CREATE
     * - INVITE_DELETE
     */
    public var guild_invites:Bool = false;

    /**
     * Corresponds to the following:
     * - VOICE_CHANNEL_EFFECT_SEND
     * - VOICE_STATE_UPDATE
     */
    public var guild_voice_states:Bool = false;

    /**
     * Corresponds to the following: **
     * - PRESENCE_UPDATE
     * 
     * `**` Events under the `GUILD_PRESENCES` and `GUILD_MEMBERS` intents are turned **off by default on all API versions.** If you are using **API v6**, you will receive those events if you are authorized to receive them and have enabled the intents in the Developer Portal. You do not need to use intents on API v6 to receive these events; you just need to enable the flags. If you are using **API v8** or above, intents are mandatory and must be specified when identifying.
     */
    public var guild_presences:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_CREATE
     * - MESSAGE_UPDATE
     * - MESSAGE_DELETE
     * - MESSAGE_DELETE_BULK
     */
    public var guild_messages:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_REACTION_ADD
     * - MESSAGE_REACTION_REMOVE
     * - MESSAGE_REACTION_REMOVE_ALL
     * - MESSAGE_REACTION_REMOVE_EMOJI
     */
    public var guild_message_reactions:Bool = false;

    /**
     * Corresponds to the following:
     * - TYPING_START
     */
    public var guild_message_typing:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_CREATE
     * - MESSAGE_UPDATE
     * - MESSAGE_DELETE
     * - CHANNEL_PINS_UPDATE
     */
    public var direct_messages:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_REACTION_ADD
     * - MESSAGE_REACTION_REMOVE
     * - MESSAGE_REACTION_REMOVE_ALL
     * - MESSAGE_REACTION_REMOVE_EMOJI
     */
    public var direct_message_reactions:Bool = false;

    /**
     * Corresponds to the following:
     * - TYPING_START
     */
    public var direct_message_typing:Bool = false;

    /**
     * *Directly defined by itelf* ***
     * 
     * `***` `MESSAGE_CONTENT` does not represent individual events, but rather affects what data is present for events that could contain message content fields. More information is in the [message content intent](https://discord.com/developers/docs/topics/gateway#message-content-intent) section.
     */
    public var message_content:Bool = false;

    /**
     * Corresponds to the following:
     * - GUILD_SCHEDULED_EVENT_CREATE
     * - GUILD_SCHEDULED_EVENT_UPDATE
     * - GUILD_SCHEDULED_EVENT_DELETE
     * - GUILD_SCHEDULED_EVENT_USER_ADD
     * - GUILD_SCHEDULED_EVENT_USER_REMOVE
     */
    public var guild_scheduled_events:Bool = false;

    /**
     * Corresponds to the following:
     * - AUTO_MODERATION_RULE_CREATE
     * - AUTO_MODERATION_RULE_UPDATE
     * - AUTO_MODERATION_RULE_DELETE
     */
    public var auto_moderation_configuration:Bool = false;

    /**
     * Corresponds to the following:
     * - AUTO_MODERATION_ACTION_EXECUTION
     */
    public var auto_moderation_execution:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_POLL_VOTE_ADD
     * - MESSAGE_POLL_VOTE_REMOVE
     */
    public var guild_message_polls:Bool = false;

    /**
     * Corresponds to the following:
     * - MESSAGE_POLL_VOTE_ADD
     * - MESSAGE_POLL_VOTE_REMOVE
     */
    public var direct_message_polls:Bool = false;

    /**
     * The real Discord Intent integer of this `Intents`.
     * 
     * You must use this after setting your properties:
     * 
     * ```haxe
     * intents = new Intents();
     * intents.direct_message_polls = true;
     * trace(intents.value); // 33554432
     * ```
     * 
     * If you wish to create an `Intents` from a Discord Intent integer,
     * use `Intents.fromValue` instead.
     */
    public var value(get, set):Int;

    public function new() {}

    function get_value():Int {
        var v:Int = 0;
        if (guilds) v |= Intent.GUILDS;
        if (guild_members) v |= Intent.GUILD_MEMBERS;
        if (guild_moderation) v |= Intent.GUILD_MODERATION;
        if (guild_expressions) v |= Intent.GUILD_EXPRESSIONS;
        if (guild_integrations) v |= Intent.GUILD_INTEGRATIONS;
        if (guild_webhooks) v |= Intent.GUILD_WEBHOOKS;
        if (guild_invites) v |= Intent.GUILD_INVITES;
        if (guild_voice_states) v |= Intent.GUILD_VOICE_STATES;
        if (guild_presences) v |= Intent.GUILD_PRESENCES;
        if (guild_messages) v |= Intent.GUILD_MESSAGES;
        if (guild_message_reactions) v |= Intent.GUILD_MESSAGE_REACTIONS;
        if (guild_message_typing) v |= Intent.GUILD_MESSAGE_TYPING;
        if (direct_messages) v |= Intent.DIRECT_MESSAGES;
        if (direct_message_reactions) v |= Intent.DIRECT_MESSAGE_REACTIONS;
        if (direct_message_typing) v |= Intent.DIRECT_MESSAGE_TYPING;
        if (message_content) v |= Intent.MESSAGE_CONTENT;
        if (guild_scheduled_events) v |= Intent.GUILD_SCHEDULED_EVENTS;
        if (auto_moderation_configuration) v |= Intent.AUTO_MODERATION_CONFIGURATION;
        if (auto_moderation_execution) v |= Intent.AUTO_MODERATION_EXECUTION;
        if (guild_message_polls) v |= Intent.GUILD_MESSAGE_POLLS;
        if (direct_message_polls) v |= Intent.DIRECT_MESSAGE_POLLS;
        return v;
    }

    public function set_value(new_value:Int):Int {
        Intents.refresh(this, new_value);
        return new_value;
    }

    /**
     * Create an `Intents` instance from a Discord Intent integer.
     * @param value Intent integer
     * @return Intents
     */
    public static function fromValue(value:Int):Intents {
        var intents:Intents = new Intents();
        Intents.refresh(intents, value);
        return intents;
    }

    public static function refresh(which:Intents, value:Int) {
        // dont use which.value, code will not do anything
        which.guilds = (value & Intent.GUILDS) != 0;
        which.guild_members = (value & Intent.GUILD_MEMBERS) != 0;
        which.guild_moderation = (value & Intent.GUILD_MODERATION) != 0;
        which.guild_expressions = (value & Intent.GUILD_EXPRESSIONS) != 0;
        which.guild_integrations = (value & Intent.GUILD_INTEGRATIONS) != 0;
        which.guild_webhooks = (value & Intent.GUILD_WEBHOOKS) != 0;
        which.guild_invites = (value & Intent.GUILD_INVITES) != 0;
        which.guild_voice_states = (value & Intent.GUILD_VOICE_STATES) != 0;
        which.guild_presences = (value & Intent.GUILD_PRESENCES) != 0;
        which.guild_messages = (value & Intent.GUILD_MESSAGES) != 0;
        which.guild_message_reactions = (value & Intent.GUILD_MESSAGE_REACTIONS) != 0;
        which.guild_message_typing = (value & Intent.GUILD_MESSAGE_TYPING) != 0;
        which.direct_messages = (value & Intent.DIRECT_MESSAGES) != 0;
        which.direct_message_reactions = (value & Intent.DIRECT_MESSAGE_REACTIONS) != 0;
        which.direct_message_typing = (value & Intent.DIRECT_MESSAGE_TYPING) != 0;
        which.message_content = (value & Intent.MESSAGE_CONTENT) != 0;
        which.guild_scheduled_events = (value & Intent.GUILD_SCHEDULED_EVENTS) != 0;
        which.auto_moderation_configuration = (value & Intent.AUTO_MODERATION_CONFIGURATION) != 0;
        which.auto_moderation_execution = (value & Intent.AUTO_MODERATION_EXECUTION) != 0;
        which.guild_message_polls = (value & Intent.GUILD_MESSAGE_POLLS) != 0;
        which.direct_message_polls = (value & Intent.DIRECT_MESSAGE_POLLS) != 0;
    }

    /**
     * A factory method that creates an `Intents` with everything enabled.
     * @return Intents
     */
    public static function all():Intents {
        var intents:Intents = new Intents();
        intents.guilds = true;
        intents.guild_members = true;
        intents.guild_moderation = true;
        intents.guild_expressions = true;
        intents.guild_integrations = true;
        intents.guild_webhooks = true;
        intents.guild_invites = true;
        intents.guild_voice_states = true;
        intents.guild_presences = true;
        intents.guild_messages = true;
        intents.guild_message_reactions = true;
        intents.guild_message_typing = true;
        intents.direct_messages = true;
        intents.direct_message_reactions = true;
        intents.direct_message_typing = true;
        intents.message_content = true;
        intents.guild_scheduled_events = true;
        intents.auto_moderation_configuration = true;
        intents.auto_moderation_execution = true;
        intents.guild_message_polls = true;
        intents.direct_message_polls = true;
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
     * - `guild_presences`
     * - `guild_members`
     * - `message_content`
     * @return Intents
     */
    public static function default_intents():Intents {
        var intents:Intents = Intents.all();
        intents.guild_presences = false;
        intents.guild_members = false;
        intents.message_content = false;
        return intents;
    }

    public function toString():String {
        var finalStr = '';
        var classFields = Reflect.fields(this);
        var varLengths = [];
        for (f in classFields) varLengths.push(f.length);
        var maxLength = Lambda.fold(varLengths, Math.max, varLengths[0]);
        maxLength += 1;
        finalStr = '\n' + Type.getClassName(Intents) + '\n';
        for (cf in classFields) {
            var spaces = Std.int(maxLength - (cf.length + 1));
            finalStr += cf + ' ';
            for (s in 0...spaces) finalStr += ' ';
            finalStr += Reflect.getProperty(this, cf);
            finalStr += '\n';
        }
        finalStr += value;
        return finalStr;
    }

    /**
     * To invert the flags, use this, instead of the `~x` operator.
     * @param intents The intents to invert.
     * @return Intents
     */
    public static function invert(intents:Intents):Intents {
        var max_flag = Intent.DIRECT_MESSAGE_POLLS;
        var max_bits = 0;
        var compiler_kys:Int = max_flag;
        var temp = compiler_kys;
        while (temp > 0) {
            temp >>= 1;
            max_bits++;
        }

        var max_value = Std.int(-1 + Math.pow(2, max_bits));
        return Intents.fromValue(intents.value ^ max_value);
    }
}