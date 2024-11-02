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
            //set post data
        }

        if (reason != null) {
            headers.set('X-Audit-Log-Reason', reason); // TBD: Url string safety
        }

        var target = #if cpp "CPP" #elseif neko "Neko" #elseif hl "HashLink" #else "Unknown Haxe Target" #end ;
        var device = "Haxe - " + #if windows "Windows" #elseif macos "MacOS" #elseif linux "Linux" #else "Unknown Device" #end ;
        // rate limiting for later
        headers.set('User-Agent', 'Bot (discord.hx) ${device} (${target})');

        // set headers
        for (header in headers.keys()) {
            request.setHeader(header, headers.get(header));
        }

        // set data
        if (data != null) {
            request.setPostData(data);
        }

        // handle errors
        request.onError = (error:String) -> {
            throw new Exception("HTTPError: " + error);
        }

        // define the output
        var __response = new haxe.io.BytesOutput();

        // send the request
        request.customRequest(false, __response, null, route.method);

        var response = __response.getBytes();
        return response.toString(); // TODO handle ratelimits and json responses
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