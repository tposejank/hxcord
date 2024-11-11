package discord;

/**
 * An ABC that details the common operations on a Discord model.
 * 
 * Almost all `Discord models <discord_api_models>` meet this
 * base class
 */
class Snowflake {
    /**
     * The model's unique ID.
     * 
     * Warning: hxcord uses IDs in `String`.
     * This is because Haxe cannot process Discord Snowflakes,
     * as they reach the Integer limit: 2147483647
     */
    public var id:String;
}