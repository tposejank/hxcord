package discord.utils.errors;

import haxe.Exception;

/**
 * Thrown when an HTTP error is encountered.
 */
class HTTPException extends Exception {
    public var data:String;
    public var status:Null<Int>;
    public var should_parse:Bool;
    public function new(data:String, msg:String = 'HTTPException', status:Null<Int>, try_parse:Bool = true) {
        super(msg + ' (${status}) ${data}');
        this.data = data;
        this.status = status;
        this.should_parse = try_parse;
    }
}

/**
 * Thrown upon receiving an error code of 403.
 */
class Forbidden extends HTTPException {
    public function new(data:String, status:Null<Int>, try_parse:Bool = true) {
        super(data, "Forbidden", status, try_parse);
    }
}

/**
 * Thrown upon receiving an error code of 404.
 */
class NotFound extends HTTPException {
    public function new(data:String, status:Null<Int>, try_parse:Bool = true) {
        super(data, "NotFound", status, try_parse);
    }
}

/**
 * Thrown upon receiving an error code of 500 or over, or no response.
 */
class DiscordServerError extends HTTPException {
    public function new(data:String, status:Null<Int>, try_parse:Bool = true) {
        super(data, "DiscordServerError", status, try_parse);
    }
}

/**
 * Thrown upon receiving an error code of 401.
 */
class Unauthorized extends HTTPException {
    public function new(data:String, status:Null<Int>, try_parse:Bool = true) {
        super(data, "Unauthorized", status, try_parse);
    }
}

/**
 * Thrown when the client can't login.
 */
class HTTPCantLogin extends Exception {
    public function new(msg:String) {
        super(msg);
    }
}