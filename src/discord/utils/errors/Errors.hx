package discord.utils.errors;

import haxe.Exception;

/**
 * A base exception.
 */
class BaseHxcordException extends Exception {
    public function new(msg:String) {
        super(msg);
    }
}

/**
 * Thrown when there are argument errors or type errors.
 */
class TypeError extends BaseHxcordException {
    public function new(msg:String) {
        super(msg);
    }
}