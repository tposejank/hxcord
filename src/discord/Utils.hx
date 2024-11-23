package discord;

import haxe.ValueException;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.crypto.Base64;

using StringTools;
using discord.utils.StringUtils;

/**
 * Utility class for various operations.
 */
class Utils {
    public static var DISCORD_EPOCH:Int64 = "1420070400000".i64();

    public static function _bytesStartsWith(data:Bytes, prefix:Bytes):Bool {
        if (data.length < prefix.length) return false;
        return data.sub(0, prefix.length).compare(prefix) == 0;
    }

    public static function getMimeTypeForImage(data:Bytes):String {
        if (_bytesStartsWith(data, Bytes.ofString("\u0089\u0050\u004E\u0047\u000D\u000A\u001A\u000A"))) {
            return "image/png";
        } else if (data.sub(0, 3).compare(Bytes.ofString("\u00ff\u00d8\u00ff")) == 0 || 
                  (data.length > 10 && (data.sub(6, 4).toString() == "JFIF" || data.sub(6, 4).toString() == "Exif"))) {
            return "image/jpeg";
        } else if (_bytesStartsWith(data, Bytes.ofString("\u0047\u0049\u0046\u0038\u0037\u0061")) || 
                    _bytesStartsWith(data, Bytes.ofString("\u0047\u0049\u0046\u0038\u0039\u0061"))) {
            return "image/gif";
        } else if (_bytesStartsWith(data, Bytes.ofString("RIFF")) && data.length > 12 && data.sub(8, 4).toString() == "WEBP") {
            return "image/webp";
        } else {
            throw 'Unsupported image type given';
        }
        return '';
    }

    public static function bytesToBase64Data(data:Bytes):String {
        var mime = getMimeTypeForImage(data);
        var b64 = Base64.encode(data); // Already returns an ASCII-safe string
        return 'data:' + mime + ';base64,' + b64;
    }

    /**
     * Icons must be power of 2 within [16, 4096].
     * @param size The size to check
     * @return Bool Is the size a power of 2 and within [16, 4096]?
     */
    public static function valid_icon_size(size:Int):Bool {
        return (size & (size - 1)) == 0 && size <= 4096 && size >= 16;
    }

    /**
     * Returns the creation time of the given snowflake.
     * @param id The snowflake ID.
     * @return Date: An aware datetime in UTC representing the creation time of the snowflake.
     */
    public static function snowflake_time(id:String):Date {
        // First, convert the Snowflake into an Int64
        var id_int64:Int64 = id.i64();
        // then right shift the snowflake 22 bits to get the timestamp part
        var timestamp = ((id_int64 >> 22) + DISCORD_EPOCH);
        // then Int64.toStr it then parse it into a float
        var timestamp_float = Std.parseFloat(Int64.toStr(timestamp));
        // feed it to Date
        return Date.fromTime(timestamp_float);
    }

    /**
     * Returns a `Date` from an ISO8601 `String`.
     * 
     * Throws a `ValueException` if the provided `isoDateString` is not valid.
     * 
     * @param isoDateString The date string.
     * @return Date
     */
    public static function iso8601_to_date(isoDateString:String): Date {
        var isoRegex = ~/^(\d{4})-?(\d{2})-?(\d{2})T(\d{2}):?(\d{2}):?(\d{2})\.?(\d+)?(?:([+-]\d{2}):?(\d{2})|Z)$/;
        
        if (!isoRegex.match(isoDateString)) {
            throw new ValueException("Invalid ISO8601 date format");
        }

        var year = Std.parseInt(isoRegex.matched(1));
        var month = Std.parseInt(isoRegex.matched(2)) - 1; // Haxe months are 0-based
        var day = Std.parseInt(isoRegex.matched(3));
        var hour = Std.parseInt(isoRegex.matched(4));
        var minute = Std.parseInt(isoRegex.matched(5));
        var second = Std.parseInt(isoRegex.matched(6));
        
        var millisecond = 0;
        if (isoRegex.matched(7) != null) {
            millisecond = Std.parseInt(isoRegex.matched(7).substr(0, 3));
        }

        var offsetMinutes = 0;
        if (isoRegex.matched(8) != null) {
            var offsetHours = Std.parseInt(isoRegex.matched(8));
            var offsetMins = Std.parseInt(isoRegex.matched(9));
            offsetMinutes = offsetHours * 60 + (offsetHours < 0 ? -offsetMins : offsetMins);
        }
        var utcDate = new Date(year, month, day, hour, minute, second);
        // timezone offset!!
        var offsetMillis = offsetMinutes * 60 * 1000;
        var __time = utcDate.getTime() - offsetMillis;
        return Date.fromTime(__time);
    }

    /**
     * Returns the first element for which in `Array` `array` the predicate `f` returns `true` for.
     * 
     * ```haxe
     * var member:Member = Utils.find(guild.members, (member:Member) -> member.id == '012345');
     * ```
     * 
     * If no result yields from this search, `null` is returned instead.
     * 
     * This is different from `Array.filter`, which returns a new `Array` and it may be empty.
     * 
     * @param array The array to find the element in.
     * @param f The predicate that needs to meet the requirement.
     */
    public static function find<T>(array:Array<T>, f:T->Bool) {
        for (i in array)
            if (f(i)) 
                return i;
        
        return null;
    }
}