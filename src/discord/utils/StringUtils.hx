package discord.utils;

import haxe.Int64;

/**
 * Utility extension to handle ID `String`s more quickly.
 */
class StringUtils {
    public static function i64(string:String):Int64 {
        return Int64.parseString(string);
    }
}