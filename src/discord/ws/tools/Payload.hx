package discord.ws.tools;

import discord.types.Intents;
import haxe.Json;

// https://discord.com/developers/docs/topics/gateway-events#payload-structure
// Made a class so it can be extended
@:structInit
@:publicFields
class Payload
{
    var op:Opcodes; // Gateway opcode, which indicates the payload type
    var d:Dynamic; // Event data
    var s:Null<Int> = null; // Sequence number of event used for resuming sessions and heartbeating
    var t:Null<String> = null; // Event name

    public function new(op:Opcodes, d:Dynamic, ?s:Null<Int>, ?t:Null<String>)
    {
        this.op = op;
        this.d = d;
        this.s = s;
        this.t = t;
    }

    // Formats the current class into a JSON object string
    public function toString()
    {
        return Json.stringify({
            op: this.op,
            d: this.d,
            s: this.s,
            t: this.t
        });
    }
}

class HeartbeatPayload extends Payload
{
    override public function new(lastSequence:Null<Int> = null)
        super(HEARTBEAT, null, lastSequence, null);
}

class IdentifyPayload extends Payload
{
    override public function new(token:String, intents:Intents, platform:String = "discord.hx (Bot)")
    {
        // We expect the user to give the full token or atleast make the code prevent any null content or invalid length

        // TODO, device detection n stuff for html5
        super(IDENTIFY, {
            token: token, // token
            intents: intents.value,
            properties: 
            {
                os: platform,
                browser: platform,
                device: platform
            }
        });
    }
}

class ResumePayload extends Payload
{
    override public function new(token:String, session:String, lastSequence:Int)
    {
        // Last sequence mustn't be null
        super(RESUME, {
            token: token,
            session_id: session,
            seq: lastSequence
        });
    }
}