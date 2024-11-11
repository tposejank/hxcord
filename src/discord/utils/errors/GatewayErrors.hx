package discord.utils.errors;

import haxe.Exception;

class GatewayException extends Exception {
    public function new(msg:String) {
        super(msg);
    }
}

/**
 * Thrown when the Gateway cannot be reconnected.
 */
class GatewayCantReconnect extends GatewayException {
    public function new(msg:String) {
        super(msg);
    }
}

/**
 * Thrown when the Gateway cannot identify.
 */
class GatewayUnauthorized extends GatewayException {
    public function new(msg:String) {
        super(msg);
    }
}

/**
 * Thrown when the Gateway must be sharded to connect.
 */
class GatewayShardRequired extends GatewayException {
    public function new(msg:String) {
        super(msg);
    }
}

/**
 * Thrown when the Gateway receives an invalid API version or intents.
 */
class GatewayInvalidParameters extends GatewayException {
    public function new(msg:String) {
        super(msg);
    }
}