package discord;

import discord.log.Log;
import haxe.Exception;

class Route {
    public var BASE = 'https://discord.com/api/v10'; // no v9 support!

    public var method:String = 'GET';
    public var path:String;

    public var url:String;

    public function new(method:String, path:String) {
        this.method = method;
        this.path = path;
        this.url = BASE + path;
    }
}

class HTTPException extends Exception {
    public var data:String;
    public var status:Null<Int>;
    public var should_parse:Bool;
    public function new(data:String, msg:String = 'HTTPException', status:Null<Int>, try_parse:Bool = true) {
        super(msg + ' (${status})');
        this.data = data;
        this.status = status;
        this.should_parse = try_parse;
    }
}

class Forbidden extends HTTPException {
    public function new(data:String, status:Null<Int>, try_parse:Bool = true) {
        super(data, "Forbidden", status, try_parse);
    }
}

class NotFound extends HTTPException {
    public function new(data:String, status:Null<Int>, try_parse:Bool = true) {
        super(data, "NotFound", status, try_parse);
    }
}

class DiscordServerError extends HTTPException {
    public function new(data:String, status:Null<Int>, try_parse:Bool = true) {
        super(data, "DiscordServerError", status, try_parse);
    }
}

class Unauthorized extends HTTPException {
    public function new(data:String, status:Null<Int>, try_parse:Bool = true) {
        super(data, "Unauthorized", status, try_parse);
    }
}

class HTTPClient {
    public var token:String;

    public function new(token:String) {
        this.token = token;
    }

    private function _setup_request(route:Route, headers:Map<String, String>, ?data:String):haxe.Http {
        var req = new haxe.Http(route.url);

        for (key => header in headers) {
            req.setHeader(key, header);
        }

        if (data != null) req.setPostData(data);

        return req;
    }

    private function _request_api(route:Route, ?data:String, ?reason:String, ?callback:String->Void) {
        var tries:Int = 0;
        var max_tries:Int = 5;
        
        // setup request headers
        var headers:Map<String, String> = new Map<String, String>();
        if (this.token != null) headers.set('Authorization', 'Bot ' + this.token);
        if (data != null) headers.set('Content-Type', 'application/json');
        // TBD: Url string safety // I think StringTools has that
        if (reason != null) headers.set('X-Audit-Log-Reason', reason);

        var target = #if cpp "CPP" #elseif neko "Neko" #elseif hl "HashLink" #else "Unknown Haxe Target" #end ;
        var device = "Haxe - " + #if windows "Windows" #elseif macos "MacOS" #elseif linux "Linux" #else "Unknown Device" #end ;
        // rate limiting for later
        headers.set('User-Agent', 'Bot (hxcord) ${device} (${target})');

        // define the output
        // null because compiler doesnt like it
        var __response:haxe.io.BytesOutput = null;
        var response:haxe.io.Bytes;
        var responseCode:Int;

        // wait for status code
        var on_status:Int->Void = (code:Int) -> {
            // trace('status ${code}');
            responseCode = 500;
        }

        // when an error occurs 
        // haxe.Http will call this when the
        // status is less than 200 or over 399
        var on_err:String->Void = (error:String) -> {
            // response is available at this moment
            trace('${error}');
            response = __response.getBytes();
        }

        // TBD: ratelimit handling

        // send the request in a loop retrying if a fail occurs
        for (i in 0...max_tries) {
            tries = i;
            // reset the output
            __response = new haxe.io.BytesOutput();

            // create a new request
            var http_request = _setup_request(route, headers, data);
            http_request.onError = on_err;
            http_request.onStatus = on_status;
            // investigate
            // does not finish requesting when its the 3rd time???
            http_request.customRequest(false, __response, null, route.method);

            // request is finalized
            response = __response.getBytes();
            // get the response data as string
            var response_str = response.toString();
            // request successful, return the data
            if ((300 > responseCode) && (responseCode >= 200)) {
                if (callback != null) callback(response_str);
                return;
            }
            
            // retry the request because of server error
            if ([500, 502, 504, 524].contains(responseCode) && i != (max_tries-1)) {
                Sys.sleep(1 + tries * 2);
                continue;
            }

            // handle other codes
            if (responseCode == 401)
                throw new Unauthorized(response_str, responseCode);
            else if (responseCode == 403)
                throw new Forbidden(response_str, responseCode);
            else if (responseCode == 404)
                throw new NotFound(response_str, responseCode);
            else if (responseCode >= 500)
                throw new DiscordServerError(response_str, responseCode);
            else 
                throw new HTTPException(response_str, responseCode);
        }

        // TODO handle ratelimits and json responses
        // ratelimiting will be a nightmare

        // the for loop was escaped, we ran out of attempts
        if (responseCode == 500)
            throw new DiscordServerError('Ran out of attempts', responseCode, false);

        if (response != null)
            throw new HTTPException(null, 'HTTPException', responseCode, false);

        throw new DiscordServerError("Could not handle the response", null, false);
    }

    public function request(route:Route, ?data:String, ?reason:String):String {
        var is_request_complete:Bool = false;
        var request_response:String = null;

        try {
            this._request_api(route, data, reason, (_response) -> {
                is_request_complete = true;
                request_response = _response;
            });
        } catch (e:Exception) {
            Log.error('Error on ${route.method} ${route.url}: ${e}');
            throw e;
        }

        return request_response;
    }

    public function delete_message(channel_id:String, message_id:String, reason:String = '') {
        return this.request(new Route('DELETE', '/channels/${channel_id}/messages/${message_id}'), null, reason);
    }

    public function bulk_channel_update(guild_id:String, data:String, reason:String = '') {
        return this.request(new Route('PATCH', '/guilds/${guild_id}/channels'), data, reason);
    }

    public function delete_channel(channel_id:String, reason:String = '') {
        return this.request(new Route('DELETE', '/channels/${channel_id}'), null, reason);
    }
}