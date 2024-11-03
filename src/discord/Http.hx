package discord;

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
    public function new(data:String, msg:String = 'HTTPException') {
        this.data = data;
        super(msg);
    }
}

class Forbidden extends HTTPException {
    public function new(data:String) {
        super(data, "Forbidden");
    }
}

class NotFound extends HTTPException {
    public function new(data:String) {
        super(data, "NotFound");
    }
}

class DiscordServerError extends HTTPException {
    public function new(data:String) {
        super(data, "DiscordServerError");
    }
}

class HTTPClient {
    public var token:String;

    public function new(token:String) {
        this.token = token;
    }

    public function request(route:Route, ?data:String, ?reason:String) {
        var request = new haxe.Http(route.url);
        
        var headers:Map<String, String> = new Map<String, String>();
        // Header creation
        if (this.token != null) headers.set('Authorization', 'Bot ' + this.token);
        if (data != null) {
            headers.set('Content-Type', 'application/json');
        }

        if (reason != null) {
            headers.set('X-Audit-Log-Reason', reason); // TBD: Url string safety
        }

        var target = #if cpp "CPP" #elseif neko "Neko" #elseif hl "HashLink" #else "Unknown Haxe Target" #end ;
        var device = "Haxe - " + #if windows "Windows" #elseif macos "MacOS" #elseif linux "Linux" #else "Unknown Device" #end ;
        // rate limiting for later
        headers.set('User-Agent', 'Bot (hxcord) ${device} (${target})');

        // set headers
        for (header in headers.keys()) {
            request.setHeader(header, headers.get(header));
        }

        // set data
        if (data != null) {
            request.setPostData(data);
        }

        // define the output
        var __response = new haxe.io.BytesOutput();
        var response:haxe.io.Bytes;
        var responseCode:Int;

        // wait for status code
        request.onStatus = (code:Int) -> {
            responseCode = code;
        }

        // handle errors
        request.onError = (error:String) -> {
            // response is available at this moment
            response = __response.getBytes();
            var response_str = response.toString();

            if (responseCode == 403) {
                throw new Forbidden(response_str);
            } else if (responseCode == 404) {
                throw new NotFound(response_str);
            } else if (responseCode >= 500) {
                throw new DiscordServerError(response_str);
            } else {
                throw new HTTPException(response_str);
            }
        }

        // send the request
        request.customRequest(false, __response, null, route.method);
        // the next code will execute when the request is finalized

        // request is finalized
        response = __response.getBytes();

        // request successful, return the data
        if ((300 > responseCode) && (responseCode >= 200)) {
            return response.toString();
        }
        // TODO handle ratelimits and json responses
        // TODO retrying requests
        // ratelimiting will be a nightmare

        throw new DiscordServerError("Could not handle the response");
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