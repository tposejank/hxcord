package discord;

import sys.thread.Deque;
import haxe.EntryPoint;
import haxe.MainLoop;
import sys.thread.Thread;
import discord.utils.DateTimeDelta;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import discord.utils.errors.HTTPErrors;
import discord.log.Log;
import haxe.Exception;

using discord.utils.MultipartUtils;
using discord.utils.HttpUtils;
using discord.utils.MapUtils;

class MultipartData {
    /**
     * The JSON data to be sent
     */
    public var payload:Dynamic;

    /**
     * Files?
     */
    public var files:Array<Bytes>;

    public function new(payload:Dynamic, files:Array<Bytes>) {
        this.payload = payload;
        this.files = files;
    }

    public function get_form_data():BytesOutput {
        var output:BytesOutput = new BytesOutput();
        output.boundary();
        output.newline();
        output.add('Content-Disposition: form-data; name="payload_json"');
        output.newline();
        output.add('Content-Type: application/json');
        output.newline();
        output.newline();
        output.add(haxe.Json.stringify(payload));
        if (this.files.length < 1)
            output.end();
        else { // create attachments
            for (idx => file in this.files) {
                // lets assume for now each file is bytes
                output.newline();
                output.boundary();
                output.newline();
                output.add('Content-Disposition: form-data; name="files[${idx}]"; filename="file_test_${idx}.jpg"');
                output.newline();
                output.add('Content-Type: ${Utils.getMimeTypeForImage(file)}');
                output.newline();
                output.newline();
                output.write(file);
            }
            output.newline();
            output.end();
        }
        return output;
    }
}

typedef RouteMajorParameters = {
    var ?channel_id:String;
    var ?guild_id:String;
    var ?webhook_id:String;
    var ?webhook_token:String;
}

/**
 * Represents a path to Discord's REST API.
 */
class Route {
    public var BASE = 'https://discord.com/api/v10'; // no v9 support!

    public var method:String = 'GET';
    public var path:String;
    public var metadata:String;
    public var url:String;

    public var channel_id:String;
    public var guild_id:String;
    public var webhook_id:String;
    public var webhook_token:String;

    public function new(method:String, path:String, ?metadata:String, ?parameters:RouteMajorParameters) {
        this.method = method;
        this.path = path;
        this.metadata = metadata;
        this.url = BASE + path;

        this.channel_id = parameters?.channel_id;
        this.guild_id = parameters?.guild_id;
        this.webhook_id = parameters?.webhook_id;
        this.webhook_token = parameters?.webhook_token;
    }

    public var key(get, never):String;
    function get_key():String {
        if (metadata != null)
            return '${method} ${path}:${metadata}';
        return '${method} ${path}';
    }

    public var major_parameters(get, never):String;
    function get_major_parameters():String {
        var param_arr = [];
        for (p in [this.channel_id, this.guild_id, this.webhook_id, this.webhook_token]) {
            if (p != null) param_arr.push(p);
        }
        return param_arr.join('+');
    }
}

/**
 * Utility class to handle Ratelimits.
 * 
 * When 
 */
class Ratelimit {
    /**
     * How many requests are possible to create made before the ratelimit is hit.
     */
    public var limit:Int;
    /**
     * How many requests are left until the ratelimit is hit.
     */
    public var remaining:Int;
    /**
     * How many requests have been made.
     */
    public var outgoing:Int;
    /**
     * How much time to wait between rate limit resets
     */
    public var reset_after:Float;

    public var deque:Deque<Void->Void>;

    public var key:String;

    /**
     * Key is for internal representation. Not needed.
     */
    public function new(key:String) {
        this.limit = 1;
        this.remaining = this.limit;
        this.outgoing = 0;
        this.key = key;

        this.deque = new Deque<Void->Void>();
    }

    public function update(request:haxe.Http) {
        this.limit = Std.parseInt(request.get_header_safe('X-Ratelimit-Limit'));
        this.remaining = Std.int(Math.min(Std.parseInt(request.get_header_safe('X-Ratelimit-Remaining')), this.limit - this.outgoing));
        // this.remaining = Std.parseInt(request.get_header_safe('X-Ratelimit-Remaining'));
        
        var r_after = request.get_header_safe('X-Ratelimit-Reset-After');
        if (r_after == null) {
            var now = Sys.time();
            var reset = Std.parseFloat(request.get_header_safe('X-Ratelimit-Reset'));
            this.reset_after = reset - now;
        } else {
            this.reset_after = Std.parseFloat(r_after);
        }
    }

    public function request_spot() {
        this.remaining -= 1;
        this.outgoing += 1;

        if (this.remaining <= 0) {
            Sys.sleep(this.reset_after);
        }

        // __aexit__
        this.deque.add(() -> {
            // trace('Outgoing has been decreased');
            this.outgoing -= 1;
            this.remaining = this.limit - this.outgoing;
        });
    }
}

class HTTPClient {
    public var token:String;

    public var globalRatelimit:Ratelimit;

    private var _bucket_hashes:Map<String, String> = new Map<String, String>();
    private var _buckets:Map<String, Ratelimit> = new Map<String, Ratelimit>();

    public function new(token:String) {
        this.token = token;
        // globalRatelimit = new Ratelimit();
    }

    private function _setup_request(route:Route, headers:Map<String, String>, ?data:String, ?form:MultipartData):haxe.Http {
        var req = new haxe.Http(route.url);

        for (key => header in headers) {
            req.setHeader(key, header);
        }

        if (data != null) req.setPostData(data);

        if (form != null) {
            var form_bytes = form.get_form_data().getBytes();
            req.setPostBytes(form_bytes);
        }

        return req;
    }

    private function get_bucket(key:String):Ratelimit {
        var bucket:Ratelimit = _buckets.get(key);
        if (bucket == null) {
            bucket = new Ratelimit(key);
            _buckets.set(key, bucket);
        }
        return bucket;
    }

    private function _request_api(route:Route, ?data:String, ?reason:String, ?form:MultipartData, ?callback:String->Void) {
        var tries:Int = 0;
        var max_tries:Int = 5;
        
        var route_key = route.key;
        var bucket_hash:String = null;
        var key:String = null;
        if (this._bucket_hashes.exists(route_key)) {
            bucket_hash = this._bucket_hashes.get(route_key);
            key = '${bucket_hash}:${route.major_parameters}';
        } else {
            key = '${route_key}:${route.major_parameters}';
        }

        var ratelimit = get_bucket(key);
        
        // setup request headers
        var headers:Map<String, String> = new Map<String, String>();
        if (this.token != null) headers.set('Authorization', 'Bot ' + this.token);
        if (data != null) headers.set('Content-Type', 'application/json');
        if (form != null) headers.set('Content-Type', 'multipart/form-data; boundary=hxcordboundary');
        // TBD: Url string safety // I think StringTools has that
        if (reason != null) headers.set('X-Audit-Log-Reason', StringTools.urlEncode(reason));

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
            responseCode = code;
        }

        // when an error occurs 
        // haxe.Http will call this when the
        // status is less than 200 or over 399
        var on_err:String->Void = (error:String) -> {
            // response is available at this moment
            Log.error('Got Error: ${error}');
            response = __response.getBytes();
        }

        // TBD: ratelimit handling

        // send the request in a loop retrying if a fail occurs
        for (i in 0...max_tries) {
            ratelimit.request_spot();
            var call = ratelimit.deque.pop(true);

            try {
                tries = i;
                // reset the output
                __response = new haxe.io.BytesOutput();

                // create a new request
                var http_request = _setup_request(route, headers, data, form);
                http_request.onError = on_err;
                http_request.onStatus = on_status;
                // investigate
                // does not finish requesting when its the 3rd time???
                http_request.customRequest(false, __response, null, route.method);

                // request is finalized
                response = __response.getBytes();
                // get the response data as string
                var response_str = response.toString();

                var discord_hash:String = http_request.get_header_safe('X-Ratelimit-Bucket');
                var has_ratelimit_headers = http_request.header_exists_safe('X-Ratelimit-Remaining');
                if (discord_hash != null) {
                    if (bucket_hash != discord_hash) {
                        if (bucket_hash != null) {
                            Log.debug('The route ${route_key} has changed hashes: ${bucket_hash} -> ${discord_hash}');
                            this._bucket_hashes.set(route_key, discord_hash);
                            var recalculated_key = discord_hash + route.major_parameters;
                            this._buckets.set(recalculated_key, ratelimit);
                            this._buckets.pop(key);
                        } else if (!_bucket_hashes.exists(route_key)) {
                            Log.debug('${route.key} has found its initial rate limit bucket hash (${discord_hash})');
                            this._bucket_hashes.set(route_key, discord_hash);
                            this._buckets.set(discord_hash + route.major_parameters, ratelimit);
                        }
                    }   
                }

                if (has_ratelimit_headers) {
                    if (responseCode != 429) {
                        ratelimit.update(http_request);
                    }
                }

                // request successful, return the data
                if ((300 > responseCode) && (responseCode >= 200)) {
                    call();
                    if (callback != null) callback(response_str);
                    return;
                }

                if (responseCode == 429) {
                    if (!http_request.header_exists_safe('Via')) {
                        throw new HTTPException(response_str, "Blocked by Cloudflare", responseCode);
                    }

                    if (ratelimit.remaining > 0) {
                        // Log.info('Subratelimit hit?');
                    }

                    var ratelimit_data = haxe.Json.parse(response_str);
                    var retry_after:Float = ratelimit_data.retry_after;
                    Log.error(ratelimit_data.message + ' Sleeping for ${retry_after}s.');
                    Sys.sleep(retry_after);

                    Log.info('Ratelimit sleep is complete. Retrying this request.');
                    call();
                    continue;
                }
                
                // retry the request because of server error
                if ([500, 502, 504, 524].contains(responseCode) && i != (max_tries-1)) {
                    Sys.sleep(1 + tries * 2);
                    call();
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
            } catch(e) {
                call();
                throw e;
            }
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

    public function request(route:Route, ?data:String, ?reason:String, ?form:MultipartData):Dynamic {
        var is_request_complete:Bool = false;
        var request_response:String = null;

        try {
            this._request_api(route, data, reason, form, (_response) -> {
                is_request_complete = true;
                request_response = _response;
            });
        } catch (e:Exception) {
            Log.error('Error on ${route.method} ${route.url}: ${e}');
            throw e;
        }

        if (request_response != null) {
            try {
                return haxe.Json.parse(request_response);
            } catch(e) {
                return request_response;
            }
        }

        return null;
    }

    public function login():Dynamic {
        var data:Dynamic = null;
        try {
            data = request(new Route('GET', '/users/@me'));
        } catch (e:HTTPException) {
            if (e.status == 401) {
                Log.error('Invalid token was passed.');
                throw new HTTPCantLogin('Invalid token was passed.');
            }
        }

        return data;
    }

    public function delete_message(channel_id:String, message_id:String, reason:String = '') {
        var difference = Sys.time() - (Utils.snowflake_time(message_id).getTime() / 1000);
        var meta = null;
        if (difference <= new DateTimeDelta(0, 0, 0, 10).toSeconds())
            meta = 'sub-10-seconds';
        if (difference >= new DateTimeDelta(14).toSeconds())
            meta = 'older-than-two-weeks';

        return this.request(new Route('DELETE', '/channels/${channel_id}/messages/${message_id}', meta, {
            channel_id: channel_id
        }), null, reason);
    }

    public function bulk_channel_update(guild_id:String, data:String, reason:String = '') {
        return this.request(new Route('PATCH', '/guilds/${guild_id}/channels'), data, reason);
    }

    public function delete_channel(channel_id:String, reason:String = '') {
        return this.request(new Route('DELETE', '/channels/${channel_id}'), null, reason);
    }

    public function send_message(channel_id:String, params:MultipartData) {
        var route = new Route('POST', '/channels/${channel_id}/messages');
        if (params.files.length > 0)
            return this.request(route, null, null, params);
        else 
            return this.request(route, haxe.Json.stringify(params.payload));
    }
}