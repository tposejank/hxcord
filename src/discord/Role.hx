package discord;

typedef RolePayload = {
    var id: String;
    var name: String;
    var color: Int;
    var hoist: Bool;
    var position: Int;
    var permissions: String;
    var managed: Bool;
    var mentionable: Bool;
    var flags: Int;
    @:optional var icon: String;
    @:optional var unicode_emoji: String;
    @:optional var tags: RoleTags;
}

typedef RoleTags = {
    var bot_id:String;
    var integration_id:String;
    var subscription_listing_id:String;
    // var premium_subscriber:Null;
    // available_for_purchase: None
    // guild_connections: None
}