package discord;

import discord.User.UserPayload;

typedef BaseStickerPayload = {
    var id:String;
    var name:String;
    var description:String;
    var tags:String;
    var format_type:Int;
}

typedef GuildSticker = {
    >BaseStickerPayload,
    var type:Int;
    var guild_id:String;
    @:optional var available:Bool;
    var user:UserPayload;
}