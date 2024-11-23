package discord.utils;

import haxe.ds.Vector;

/**
 * Utility class to handle Arrays as a Python style deque.
 * 
 * Not to be confused for Utilities for `sys.thread.Deque`.
 */
class DequeUtils {
    /**
     * Adds an `item` to `Array` `array` at the start of it, and removes any elements past index `max`.
     * @param item The item to add
     */
    public static function add<T>(array:Array<T>, item:T, max:Int) {
        array.insert(0, item);
        array = array.slice(0, max);
    }
}

// ONLY use this if youre evil!!!
abstract CustomVector<T>(Vector<T>) {
    public function push(item:T) {
        var arr = this.toArray();
        var spl = arr.slice(1, this.length);
        this.fill(item);
        for (i => val in spl) {
            this.set(i+1, val);
        }
    }

    public function remove(item:T) {
        var arr = this.toArray();
        arr.remove(item);
        this.fill(null);
        for (i => val in arr) {
            this.set(i, val);
        }
    }
}