package discord;

import haxe.Int64;

using discord.utils.StringUtils;

/**
 * The bit-wise `Int64` integers which represent each permission.
 */
class Permission {
    public static var CREATE_INSTANT_INVITE = pshl(1, 0);
    public static var KICK_MEMBERS = pshl(1, 1);
    public static var BAN_MEMBERS = pshl(1, 2);
    public static var ADMINISTRATOR = pshl(1, 3);
    public static var MANAGE_CHANNELS = pshl(1, 4);
    public static var MANAGE_GUILD = pshl(1, 5);
    public static var ADD_REACTIONS = pshl(1, 6);
    public static var VIEW_AUDIT_LOG = pshl(1, 7);
    public static var PRIORITY_SPEAKER = pshl(1, 8);
    public static var STREAM = pshl(1, 9);
    public static var VIEW_CHANNEL = pshl(1, 10);
    public static var SEND_MESSAGES = pshl(1, 11);
    public static var SEND_TTS_MESSAGES = pshl(1, 12);
    public static var MANAGE_MESSAGES = pshl(1, 13);
    public static var EMBED_LINKS = pshl(1, 14);
    public static var ATTACH_FILES = pshl(1, 15);
    public static var READ_MESSAGE_HISTORY = pshl(1, 16);
    public static var MENTION_EVERYONE = pshl(1, 17);
    public static var USE_EXTERNAL_EMOJIS = pshl(1, 18);
    public static var VIEW_GUILD_INSIGHTS = pshl(1, 19);
    public static var CONNECT = pshl(1, 20);
    public static var SPEAK = pshl(1, 21);
    public static var MUTE_MEMBERS = pshl(1, 22);
    public static var DEAFEN_MEMBERS = pshl(1, 23);
    public static var MOVE_MEMBERS = pshl(1, 24);
    public static var USE_VOICE_ACTIVATION = pshl(1, 25);
    public static var CHANGE_NICKNAME = pshl(1, 26);
    public static var MANAGE_NICKNAMES = pshl(1, 27);
    public static var MANAGE_PERMISSIONS = pshl(1, 28);
    public static var MANAGE_WEBHOOKS = pshl(1, 29);
    public static var MANAGE_EXPRESSIONS = pshl(1, 30);
    public static var USE_APPLICATION_COMMANDS = pshl(1, 31);
    public static var REQUEST_TO_SPEAK = pshl(1, 32);
    public static var MANAGE_EVENTS = pshl(1, 33);
    public static var MANAGE_THREADS = pshl(1, 34);
    public static var CREATE_PUBLIC_THREADS = pshl(1, 35);
    public static var CREATE_PRIVATE_THREADS = pshl(1, 36);
    public static var USE_EXTERNAL_STICKERS = pshl(1, 37);
    public static var SEND_MESSAGES_IN_THREADS = pshl(1, 38);
    public static var USE_EMBEDDED_ACTIVITIES = pshl(1, 39);
    public static var MODERATE_MEMBERS = pshl(1, 40);
    public static var VIEW_CREATOR_MONETIZATION_ANALYTICS = pshl(1, 41);
    public static var USE_SOUNDBOARD = pshl(1, 42);
    public static var CREATE_EXPRESSIONS = pshl(1, 43);
    public static var CREATE_EVENTS = pshl(1, 44);
    public static var USE_EXTERNAL_SOUNDS = pshl(1, 45);
    public static var SEND_VOICE_MESSAGES = pshl(1, 46);
    public static var CREATE_POLLS = pshl(1, 49);
    public static var USE_EXTERNAL_APPS = pshl(1, 50);

    /**
     * Get a `haxe.Int64` of a shifted b bits to the left.
     */
    public static function pshl(a:Int, b:Int) {
        return Std.string(a).i64() << b;
    }
}

/**
 * Wraps up the Discord permission value.
 */
class Permissions {
    /**
     * If the user can create instant invites.
     */
    public var create_instant_invite:Bool = false;

    /**
     * If the user can kick users from the guild.
     */
    public var kick_members:Bool = false;

    /**
     * If a user can ban users from the guild.
     */
    public var ban_members:Bool = false;

    /**
     * If a user is an administrator. This role overrides all other permissions.
     * 
     * This also bypasses all channel-specific overrides.
     */
    public var administrator:Bool = false;

    /**
     * If a user can edit, delete, or create channels in the guild.
     * 
     * This also corresponds to the "Manage Channel" channel-specific override.
     */
    public var manage_channels:Bool = false;

    /**
     * If a user can edit guild properties.
     */
    public var manage_guild:Bool = false;

    /**
     * If a user can add reactions to messages.
     */
    public var add_reactions:Bool = false;

    /**
     * If a user can view the guild's audit log.
     */
    public var view_audit_log:Bool = false;

    /**
     * If a user can be more easily heard while talking.
     */
    public var priority_speaker:Bool = false;

    /**
     * If a user can stream in a voice channel.
     */
    public var stream:Bool = false;

    /**
     * If a user can read messages from all or specific text channels.
     */
    public var view_channel:Bool = false;

    /**
     * If a user can send messages from all or specific text channels.
     */
    public var send_messages:Bool = false;

    /**
     * If a user can send TTS messages from all or specific text channels.
     */
    public var send_tts_messages:Bool = false;

    /**
     * If a user can delete or pin messages in a text channel.
     */
    public var manage_messages:Bool = false;

    /**
     * If a user's messages will automatically be embedded by Discord.
     */
    public var embed_links:Bool = false;

    /**
     * If a user can send files in their messages.
     */
    public var attach_files:Bool = false;

    /**
     * If a user can read a text channel's previous messages.
     */
    public var read_message_history:Bool = false;

    /**
     * If a user's @everyone or @here will mention everyone in the text channel.
     */
    public var mention_everyone:Bool = false;

    /**
     * If a user can use emojis from other guilds.
     */
    public var use_external_emojis:Bool = false;

    /**
     * If a user can view the guild's insights.
     */
    public var view_guild_insights:Bool = false;

    /**
     * If a user can connect to a voice channel.
     */
    public var connect:Bool = false;

    /**
     * If a user can speak in a voice channel.
     */
    public var speak:Bool = false;

    /**
     * If a user can mute other users.
     */
    public var mute_members:Bool = false;

    /**
     * If a user can deafen other users.
     */
    public var deafen_members:Bool = false;

    /**
     * If a user can move users between other voice channels.
     */
    public var move_members:Bool = false;

    /**
     *  If a user can use voice activation in voice channels.
     */
    public var use_voice_activation:Bool = false;

    /**
     * If a user can change their nickname in the guild.
     */
    public var change_nickname:Bool = false;

    /**
     * If a user can change other user's nickname in the guild.
     */
    public var manage_nicknames:Bool = false;

    /**
     * If a user can create or edit roles less than their role's position.
     * 
     * This also corresponds to the "Manage Permissions" channel-specific override.
     */
    public var manage_permissions:Bool = false;

    /**
     * If a user can create, edit, or delete webhooks.
     */
    public var manage_webhooks:Bool = false;

    /**
     * If a user can edit or delete emojis, stickers, and soundboard sounds.
     */
    public var manage_expressions:Bool = false;

    /**
     * If a user can use slash commands.
     */
    public var use_application_commands:Bool = false;

    /**
     * If a user can request to speak in a stage channel.
     */
    public var request_to_speak:Bool = false;

    /**
     * If a user can manage guild events.
     */
    public var manage_events:Bool = false;

    /**
     * If a user can manage threads.
     */
    public var manage_threads:Bool = false;

    /**
     * If a user can create public threads.
     */
    public var create_public_threads:Bool = false;

    /**
     * If a user can create private threads.
     */
    public var create_private_threads:Bool = false;

    /**
     * If a user can use stickers from other guilds.
     */
    public var use_external_stickers:Bool = false;

    /**
     * If a user can send messages in threads.
     */
    public var send_messages_in_threads:Bool = false;

    /**
     * If a user can launch an embedded application in a Voice channel.
     */
    public var use_embedded_activities:Bool = false;

    /**
     * If a user can time out other members.
     */
    public var moderate_members:Bool = false;

    /**
     * If a user can view role subscription insights.
     */
    public var view_creator_monetization_analytics:Bool = false;

    /**
     * If a user can use the soundboard.
     */
    public var use_soundboard:Bool = false;

    /**
     * If a user can create emojis, stickers, and soundboard sounds.
     */
    public var create_expressions:Bool = false;

    /**
     * If a user can create guild events.
     */
    public var create_events:Bool = false;

    /**
     * If a user can use sounds from other guilds.
     */
    public var use_external_sounds:Bool = false;

    /**
     * If a user can send voice messages.
     */
    public var send_voice_messages:Bool = false;

    /**
     * If a user can send poll messages.
     */
    public var create_polls:Bool = false;

    /**
     * If a user can use external apps.
     */
    public var use_external_apps:Bool = false;

    /**
     * The real Discord Permission integer of these `Permissions`.
     * 
     * ```haxe
     * permissions = new Permissions();
     * permissions.send_messages = false;
     * trace(permissions.value); // TBD
     * ```
     * 
     * If you wish to create a `Permissions` from a Discord Permission integer,
     * use `Permissions.fromValue` instead.
     * 
     * This value is a bit array field of a 53-bit integer (`Int64`) representing the currently available permissions. You should query permissions via the properties rather than using this raw value.
     */
    public var value(get, set):Int64;

    function get_value():Int64 {
        var v:Int64 = 0;
        if (create_instant_invite) v |= Permission.CREATE_INSTANT_INVITE;
        if (kick_members) v |= Permission.KICK_MEMBERS;
        if (ban_members) v |= Permission.BAN_MEMBERS;
        if (administrator) v |= Permission.ADMINISTRATOR;
        if (manage_channels) v |= Permission.MANAGE_CHANNELS;
        if (manage_guild) v |= Permission.MANAGE_GUILD;
        if (add_reactions) v |= Permission.ADD_REACTIONS;
        if (view_audit_log) v |= Permission.VIEW_AUDIT_LOG;
        if (priority_speaker) v |= Permission.PRIORITY_SPEAKER;
        if (stream) v |= Permission.STREAM;
        if (view_channel) v |= Permission.VIEW_CHANNEL;
        if (send_messages) v |= Permission.SEND_MESSAGES;
        if (send_tts_messages) v |= Permission.SEND_TTS_MESSAGES;
        if (manage_messages) v |= Permission.MANAGE_MESSAGES;
        if (embed_links) v |= Permission.EMBED_LINKS;
        if (attach_files) v |= Permission.ATTACH_FILES;
        if (read_message_history) v |= Permission.READ_MESSAGE_HISTORY;
        if (mention_everyone) v |= Permission.MENTION_EVERYONE;
        if (use_external_emojis) v |= Permission.USE_EXTERNAL_EMOJIS;
        if (view_guild_insights) v |= Permission.VIEW_GUILD_INSIGHTS;
        if (connect) v |= Permission.CONNECT;
        if (speak) v |= Permission.SPEAK;
        if (mute_members) v |= Permission.MUTE_MEMBERS;
        if (deafen_members) v |= Permission.DEAFEN_MEMBERS;
        if (move_members) v |= Permission.MOVE_MEMBERS;
        if (use_voice_activation) v |= Permission.USE_VOICE_ACTIVATION;
        if (change_nickname) v |= Permission.CHANGE_NICKNAME;
        if (manage_nicknames) v |= Permission.MANAGE_NICKNAMES;
        if (manage_permissions) v |= Permission.MANAGE_PERMISSIONS;
        if (manage_webhooks) v |= Permission.MANAGE_WEBHOOKS;
        if (manage_expressions) v |= Permission.MANAGE_EXPRESSIONS;
        if (use_application_commands) v |= Permission.USE_APPLICATION_COMMANDS;
        if (request_to_speak) v |= Permission.REQUEST_TO_SPEAK;
        if (manage_events) v |= Permission.MANAGE_EVENTS;
        if (manage_threads) v |= Permission.MANAGE_THREADS;
        if (create_public_threads) v |= Permission.CREATE_PUBLIC_THREADS;
        if (create_private_threads) v |= Permission.CREATE_PRIVATE_THREADS;
        if (use_external_stickers) v |= Permission.USE_EXTERNAL_STICKERS;
        if (send_messages_in_threads) v |= Permission.SEND_MESSAGES_IN_THREADS;
        if (use_embedded_activities) v |= Permission.USE_EMBEDDED_ACTIVITIES;
        if (moderate_members) v |= Permission.MODERATE_MEMBERS;
        if (view_creator_monetization_analytics) v |= Permission.VIEW_CREATOR_MONETIZATION_ANALYTICS;
        if (use_soundboard) v |= Permission.USE_SOUNDBOARD;
        if (create_expressions) v |= Permission.CREATE_EXPRESSIONS;
        if (create_events) v |= Permission.CREATE_EVENTS;
        if (use_external_sounds) v |= Permission.USE_EXTERNAL_SOUNDS;
        if (send_voice_messages) v |= Permission.SEND_VOICE_MESSAGES;
        if (create_polls) v |= Permission.CREATE_POLLS;
        if (use_external_apps) v |= Permission.USE_EXTERNAL_APPS;
            
        return v;
    }

    public function set_value(new_value:Int64):Int64 {
        Permissions.refresh(this, new_value);
        return new_value;
    }

    public function new() {}

    public static function refresh(which:Permissions, value:Int64) {
        which.create_instant_invite = (value & Permission.CREATE_INSTANT_INVITE) != 0;
        which.kick_members = (value & Permission.KICK_MEMBERS) != 0;
        which.ban_members = (value & Permission.BAN_MEMBERS) != 0;
        which.administrator = (value & Permission.ADMINISTRATOR) != 0;
        which.manage_channels = (value & Permission.MANAGE_CHANNELS) != 0;
        which.manage_guild = (value & Permission.MANAGE_GUILD) != 0;
        which.add_reactions = (value & Permission.ADD_REACTIONS) != 0;
        which.view_audit_log = (value & Permission.VIEW_AUDIT_LOG) != 0;
        which.priority_speaker = (value & Permission.PRIORITY_SPEAKER) != 0;
        which.stream = (value & Permission.STREAM) != 0;
        which.view_channel = (value & Permission.VIEW_CHANNEL) != 0;
        which.send_messages = (value & Permission.SEND_MESSAGES) != 0;
        which.send_tts_messages = (value & Permission.SEND_TTS_MESSAGES) != 0;
        which.manage_messages = (value & Permission.MANAGE_MESSAGES) != 0;
        which.embed_links = (value & Permission.EMBED_LINKS) != 0;
        which.attach_files = (value & Permission.ATTACH_FILES) != 0;
        which.read_message_history = (value & Permission.READ_MESSAGE_HISTORY) != 0;
        which.mention_everyone = (value & Permission.MENTION_EVERYONE) != 0;
        which.use_external_emojis = (value & Permission.USE_EXTERNAL_EMOJIS) != 0;
        which.view_guild_insights = (value & Permission.VIEW_GUILD_INSIGHTS) != 0;
        which.connect = (value & Permission.CONNECT) != 0;
        which.speak = (value & Permission.SPEAK) != 0;
        which.mute_members = (value & Permission.MUTE_MEMBERS) != 0;
        which.deafen_members = (value & Permission.DEAFEN_MEMBERS) != 0;
        which.move_members = (value & Permission.MOVE_MEMBERS) != 0;
        which.use_voice_activation = (value & Permission.USE_VOICE_ACTIVATION) != 0;
        which.change_nickname = (value & Permission.CHANGE_NICKNAME) != 0;
        which.manage_nicknames = (value & Permission.MANAGE_NICKNAMES) != 0;
        which.manage_permissions = (value & Permission.MANAGE_PERMISSIONS) != 0;
        which.manage_webhooks = (value & Permission.MANAGE_WEBHOOKS) != 0;
        which.manage_expressions = (value & Permission.MANAGE_EXPRESSIONS) != 0;
        which.use_application_commands = (value & Permission.USE_APPLICATION_COMMANDS) != 0;
        which.request_to_speak = (value & Permission.REQUEST_TO_SPEAK) != 0;
        which.manage_events = (value & Permission.MANAGE_EVENTS) != 0;
        which.manage_threads = (value & Permission.MANAGE_THREADS) != 0;
        which.create_public_threads = (value & Permission.CREATE_PUBLIC_THREADS) != 0;
        which.create_private_threads = (value & Permission.CREATE_PRIVATE_THREADS) != 0;
        which.use_external_stickers = (value & Permission.USE_EXTERNAL_STICKERS) != 0;
        which.send_messages_in_threads = (value & Permission.SEND_MESSAGES_IN_THREADS) != 0;
        which.use_embedded_activities = (value & Permission.USE_EMBEDDED_ACTIVITIES) != 0;
        which.moderate_members = (value & Permission.MODERATE_MEMBERS) != 0;
        which.view_creator_monetization_analytics = (value & Permission.VIEW_CREATOR_MONETIZATION_ANALYTICS) != 0;
        which.use_soundboard = (value & Permission.USE_SOUNDBOARD) != 0;
        which.create_expressions = (value & Permission.CREATE_EXPRESSIONS) != 0;
        which.create_events = (value & Permission.CREATE_EVENTS) != 0;
        which.use_external_sounds = (value & Permission.USE_EXTERNAL_SOUNDS) != 0;
        which.send_voice_messages = (value & Permission.SEND_VOICE_MESSAGES) != 0;
        which.create_polls = (value & Permission.CREATE_POLLS) != 0;
        which.use_external_apps = (value & Permission.USE_EXTERNAL_APPS) != 0;
    }

    /**
     * Returns `true` if `this` has the same or fewer permissions as the other.
     * 
     * Equivalent to `a <= b`.
     */
    public function is_subset(of:Permissions) {
        return (this.value & of.value) == this.value;
    }

    /**
     * Returns `True` if `this` has the same or more permissions as other.
     * 
     * Equivalent to `a >= b`.
     */
    public function is_superset(of:Permissions) {
        return (this.value | of.value) == this.value;
    }

    /**
     * Returns `true` if the permissions on the other are a strict subset of those on `this`.
     * 
     * Equivalent to `a < b`.
     */
    public function is_strict_subset(of:Permissions) {
        return is_subset(of) && this != of;
    }

    /**
     * Returns `true` if the permissions on the other are a strict superset of those on `this`.
     * 
     * Equivalent to `a > b`.
     */
    public function is_strict_superset(of:Permissions) {
        return is_superset(of) && this != of;
    }

    /**
     * To invert the flags, use this, instead of the `~x` operator.
     * @param permissions The permissions to invert.
     * @return Permissions
     */
    public static function invert(permissions:Permissions):Permissions {
        var max_flag:Int64 = 1;
        var max_bits = 0;
        var compiler_kys:Int64 = max_flag;
        var temp = compiler_kys;
        while (temp > 0) {
            temp >>= 1;
            max_bits++;
        }

        var max_value = Int64.fromFloat(-1 + Math.pow(2, max_bits));
        return Permissions.fromValue(permissions.value ^ max_value);
    }

    /**
     * Create an `Permissions` instance from a Discord Permissions integer.
     * @param value Permissions integer
     * @return Permissions
     */
    public static function fromValue(value:Int64):Permissions {
        var permissions:Permissions = new Permissions();
        Permissions.refresh(permissions, value);
        return permissions;
    }

    public function toString():String {
        var finalStr = '';
        var classFields = Reflect.fields(this);
        var varLengths = [];
        for (f in classFields) varLengths.push(f.length);
        var maxLength = Lambda.fold(varLengths, Math.max, varLengths[0]);
        maxLength += 1;
        finalStr = '\n' + Type.getClassName(Permissions) + '\n';
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
     * A factory method that creates a `Permissions` with all permissions set to false.
     */
    public static function none():Permissions {
        return fromValue("0".i64());
    }

    /**
     * A factory method that creates a `Permissions` with all permissions set to `true`.
     */
    public static function all():Permissions {
        // bug which is fixed in dpy 2.5
        // 0b0000_0000_0000_0110_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111
        return fromValue("1829587348619263".i64());
    }

    /**
     * A `Permissions` with all channel-specific permissions set to `true` and the guild-specific ones set to `false`.
     */
    public static function all_channel():Permissions {
        // 0b0000_0000_0000_0110_0110_0100_1111_1101_1011_0011_1111_0111_1111_1111_0101_0001
        return fromValue("1799890669141841".i64());
    }

    /**
     * "A factory method that creates a `Permissions` with all "General" permissions from the official Discord UI set to `true`.
     */
    public static function general():Permissions {
        // 0b0000_0000_0000_0000_0000_1010_0000_0000_0111_0000_0000_1000_0000_0100_1011_0000
        return fromValue("10996995851440".i64());
    }

    /**
     * A factory method that creates a `Permissions` with all "Membership" permissions from the official Discord UI set to `true`.
     */
    public static function membership():Permissions {
        // 0b0000_0000_0000_0000_0000_0001_0000_0000_0000_1100_0000_0000_0000_0000_0000_0111
        return fromValue("1099712954375".i64());
    }
    
    /**
     * A factory method that creates a `Permissions` with all "Text" permissions from the official Discord UI set to `true`.
     */
    public static function text():Permissions {
        // 0b0000_0000_0000_0110_0100_0000_0111_1100_1000_0000_0000_0111_1111_1000_0100_0000
        return fromValue("1759753328392256".i64());
    }

    /**
     * A factory method that creates a `Permissions` with all "Voice" permissions from the official Discord UI set to `true`.
     */
    public static function voice():Permissions {
        // 0b0000_0000_0000_0000_0010_0100_1000_0000_0000_0011_1111_0000_0000_0011_0000_0000
        return fromValue("40132240474880".i64());
    }

    /**
     * A factory method that creates a `Permissions` with all "Stage Channel" permissions from the official Discord UI set to `true`.
     */
    public static function stage():Permissions {
        // 4294967296 is well over the integer limit
        return fromValue("1".i64() << 32);
    }

    /**
     * A factory method that creates a `Permissions` with all permissions for stage moderators set to `true`.
     */
    public static function stage_moderator():Permissions {
        // 0b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0100_0000_0000_0000_0001_0000
        return fromValue("20971536".i64());
    }

    /**
     * A factory method that creates a `Permissions` with all permissions that require 2FA set to `true`.
     */
    public static function elevated():Permissions {
        // 0b0000_0000_0000_0000_0000_0001_0000_0100_0111_0000_0000_0000_0010_0000_0011_1110
        return fromValue("1118570553406".i64());
    }

    /**
     * A factory method that creates a `Permissions` with all "Events" permissions from the official Discord UI set to `true`.
     */
    public static function events():Permissions {
        // 0b0000_0000_0000_0000_0001_0000_0000_0010_0000_0000_0000_0000_0000_0000_0000_0000
        return fromValue("17600775979008".i64());
    }

    /**
     * A factory method that creates a `Permissions` with all "Events" permissions from the official Discord UI set to `true`.
     */
    public static function advanced():Permissions {
        return fromValue("1".i64() << 3);
    }

    public static function _timeout_mask():Int64 {
        var all = Permissions.all();
        all.view_channel = false;
        all.read_message_history = false;
        return ~all.value;
    }

    public static function _dm_permissions():Permissions {
        var base = Permissions.text();
        base.view_channel = true;
        base.send_tts_messages = false;
        base.manage_messages = false;
        base.create_private_threads = false;
        base.create_public_threads = false;
        base.manage_threads = false;
        base.send_messages_in_threads = false;
        return base;
    }

    public static function _user_installed_permissions(in_guild:Bool = false):Permissions {
        var base = Permissions.none();
        base.send_messages = true;
        base.attach_files = true;
        base.embed_links = true;
        base.use_external_emojis = true;
        base.send_voice_messages = true;
        if (in_guild) {
            base.view_channel = true;
            base.send_tts_messages = true;
            base.send_messages_in_threads = true;
        }
        return base;
    }

    public function handle_overwrite(allow:Int64, deny:Int64) {
        // Basically this is what's happening here.
        // We have an original bit array, e.g. 1010
        // Then we have another bit array that is 'denied', e.g. 1111
        // And then we have the last one which is 'allowed', e.g. 0101
        // We want original OP denied to end up resulting in
        // whatever is in denied to be set to 0.
        // So 1010 OP 1111 -> 0000
        // Then we take this value and look at the allowed values.
        // And whatever is allowed is set to 1.
        // So 0000 OP2 0101 -> 0101
        // The OP is base  & ~denied.
        // The OP2 is base | allowed.
        this.value = (this.value & ~deny) | allow;
    }
}