package discord.utils;

/**
 * Utility extension to handle `Map` instances more quickly.
 */
class MapUtils {
    /**
     * Return an array of only the values in `this` `Map`.
     */
    public static function values<K, V>(map:Map<K, V>):Array<V> {
        var values:Array<V> = [];
        for (value in map.iterator()) {
            values.push(value);
        }
        return values;
    }

    /**
     * Remove a key from `this` `Map` and return the corresponding value.
     */
    public static function pop<K, V>(map:Map<K, V>, key:K):V {
        var value:V = map.get(key);
        map.remove(key);
        return value;
    }

    public static function length<K, V>(map:Map<K, V>):Int {
        return values(map).length;
    }
}