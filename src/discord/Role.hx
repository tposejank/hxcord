package discord;

typedef RolePayload = {
    var id:String;
    var name:String;
    var color:Int;
    var hoist:Bool;
    var position:Int;
    var permissions:String;
    var managed:Bool;
    var mentionable:Bool;
    var flags:Int;
    @:optional var icon:String;
    @:optional var unicode_emoji:String;
    @:optional var tags:RoleTags;
}

typedef RoleTags = {
    var bot_id:String;
    var integration_id:String;
    var subscription_listing_id:String;
    // Tags with type null represent booleans. They will be present and set to null if they are "true", and will be not present if they are "false".
    // https://discord.com/developers/docs/topics/permissions#role-object-role-tags-structure
    @:optional var premium_subscriber:Bool;
    @:optional var available_for_purchase:Bool;
    @:optional var guild_connections:Bool;
}