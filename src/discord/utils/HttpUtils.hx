package discord.utils;

/**
 * Utility extension to handle `haxe.Http` requests more quickly.
 */
class HttpUtils {
    public static function get_header_safe(http:haxe.Http, key:String):String {
        if (http.responseHeaders.exists(key.toUpperCase()))
            return http.responseHeaders.get(key.toUpperCase());
        else if (http.responseHeaders.exists(key))
            return http.responseHeaders.get(key);
        else if (http.responseHeaders.exists(key.toLowerCase()))
            return http.responseHeaders.get(key.toLowerCase());
        else
            return null;
    }

    public static function header_exists_safe(http:haxe.Http, key:String):Bool {
        return http.responseHeaders.exists(key.toLowerCase()) || http.responseHeaders.exists(key) || http.responseHeaders.exists(key.toUpperCase());
    }
}