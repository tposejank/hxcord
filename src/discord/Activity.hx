package discord;

import discord.User.UserPayload;

enum abstract StatusType(String) from String to String {
    var idle = 'idle';
    var dnd = 'dnd';
    var online = 'online';
    var offline = 'offline';
}

typedef ClientStatus = {
    var desktop: StatusType;
    var mobile: StatusType;
    var web: StatusType;
}

typedef PartialPresenceUpdate = {
    var user: UserPayload;
    var guild_id: String;
    var status: StatusType;
    // var activities: List[Activity];
    var client_status: ClientStatus;
}