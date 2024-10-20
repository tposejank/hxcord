package discord.ws.tools;

/**
 * This class is from
 * https://github.com/SanicBTW/HxDiscordGateway/blob/master/source/discord/gateway/Opcodes.hx
 * 
 * https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
 */
enum abstract Opcodes(Int) to Int
{
    /**
     * An event was dispatched.
     *
     * Client action: *Receive*
     */
    var DISPATCH = 0;

    /**
     * Fired periodically by the client to keep the connection alive.
     *
     * Client action: *Send* / *Receive*
     */
    var HEARTBEAT = 1;

    /**
     * Starts a new session during the initial handshake.
     *
     * Client action: *Send*
     */
    var IDENTIFY = 2;

    /**
     * Update the client's presence.
     *
     * Client action: *Send*
     */
    var PRESENCE_UPDATE = 3;

    /**
     * Used to join/leave or move between voice channels.
     *
     * Client action: *Send*
     */
    var VOICE_STATE_UPDATE = 4;

    /**
     * Resume a previous session that was disconnected.
     *
     * Client action: *Send*
     */
    var RESUME = 6;

    /**
     * You should attempt to reconnect and resume immediately.
     *
     * Client action: *Receive*
     */
    var RECONNECT = 7;

    /**
     * Request information about offline guild members in a large guild.
     *
     * Client action: *Send*
     */
    var REQUEST_GUILD_MEMBERS = 8;

    /**
     * The session has been invalidated. 
     *
     * You should reconnect and identify/resume accordingly.
     *
     * Client action: *Receive*
     */
    var INVALID_SESSION = 9;

    /**
     * Sent immediately after connecting, contains the `heartbeat_interval` to use.
     *
     * Client action: *Receive*
     */
    var HELLO = 10;

    /**
     * Sent in response to receiving a heartbeat to acknowledge that it has been received.
     *
     * Client action: *Receive*
     */
    var HEARTBEAT_ACK = 11;
    
    /**
     * Request information about soundboard sounds in a set of guilds.
     * 
     * Client action: *Send*
     */
    var REQUEST_SOUNDBOARD_SOUNDS = 31;
}