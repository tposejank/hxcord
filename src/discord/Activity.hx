package discord;

import discord.User.UserPayload;

enum abstract StatusType(String) from String to String {
    var idle = 'idle';
    var dnd = 'dnd';
    var online = 'online';
    var offline = 'offline';
}

typedef ClientStatus = {
    var desktop:StatusType;
    var mobile:StatusType;
    var web:StatusType;
}

typedef ActivityTimestamps = {
    var start:Int;
    var end:Int;
}

typedef ActivityParty = {
    var id:String;
    var size:Array<Int>;
}

typedef SendableActivityPayload = {
    var name:String;
    var type:Int;
    @:optional var url:String;
}

typedef BaseActivityPayload = {
    >SendableActivityPayload,
    var created_at:Int;
}

typedef ActivitySecrets = {
    var join:String;
    var spectate:String;
    var match:String;
}

typedef ActivityEmoji = {
    var name:String;
    var id:String;
    var animated:Bool;
}

typedef ActivityAssets = {
    var large_image:String;
    var large_text:String;
    var small_image:String;
    var small_text:String;
}

typedef ActivityPayload = {
    >BaseActivityPayload,
    @:optional var state:String;
    @:optional var details:String;
    @:optional var timestamps:ActivityTimestamps;
    @:optional var platform:String;
    var assets:ActivityAssets;
    var party:ActivityParty;
    var application_id:String;
    var flags:Int;
    @:optional var emoji:ActivityEmoji;
    var secrets:ActivitySecrets;
    var session_id:String;
    var instance:Bool;
    var buttons:Array<String>;
    var sync_id:String;
}

typedef PartialPresenceUpdate = {
    var user:UserPayload;
    var guild_id:String;
    var status:StatusType;
    var activities:Array<ActivityPayload>;
    var client_status:ClientStatus;
}