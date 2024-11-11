package discord;

import haxe.exceptions.NotImplementedException;
import haxe.Int64;
import haxe.Exception;
import haxe.display.Display.Package;
import discord.Snowflake;
import discord.State.ConnectionState;

using discord.utils.MapUtils;
using discord.utils.StringUtils;

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
	@:optional var tags:RoleTagsPayload;
}

typedef RoleTagsPayload = {
	var bot_id:String;
	var integration_id:String;
	var subscription_listing_id:String;
	// Tags with type null represent booleans. They will be present and set to null if they are "true", and will be not present if they are "false".
	// https://discord.com/developers/docs/topics/permissions#role-object-role-tags-structure
	@:optional var premium_subscriber:Bool;
	@:optional var available_for_purchase:Bool;
	@:optional var guild_connections:Bool;
}

/**
 * Represents tags on a role.
 * 
 * A role tag is a piece of extra information attached to a managed role
 * that gives it context for the reason the role is managed.
 * 
 * While this can be accessed, a useful interface is also provided in the
 * `Role` and `Guild` classes as well.
 */
class RoleTags {
	public var bot_id:String;
	public var integration_id:String;
	public var subscription_listing_id:String;
	public var _premium_subscriber:Bool;
	public var _available_for_purchase:Bool;
	public var _guild_connections:Bool;

	public function new(data:RoleTagsPayload) {
		this.bot_id = data.bot_id;
		this.integration_id = data.integration_id;
		this.subscription_listing_id = data.subscription_listing_id;

		// discord you are not cool for this
		this._premium_subscriber = Reflect.hasField(data, 'premium_subscriber');
		this._available_for_purchase = Reflect.hasField(data, 'available_for_purchase');
		this._guild_connections = Reflect.hasField(data, 'guild_connections');
	}

	public function is_bot_managed() {
		return this.bot_id != null;
	}

	public function is_premium_subscriber() {
		return this._premium_subscriber;
	}

	public function is_integration() {
		return this.integration_id != null;
	}

	public function is_available_for_purchase() {
		return this._available_for_purchase;
	}

	public function is_guild_connection() {
		return this._guild_connections;
	}
}

/**
 * Represents a Discord role in a `Guild`.
 */
class Role extends Snowflake {
	/**
	 * The guild the role belongs to.
	 */
	public var guild:Guild;

	private var _state:ConnectionState;

	/**
	 * The name of the role.
	 */
	public var name:String;

	/**
	 * The position of the role. This number is usually positive. The bottom
	 * role has a position of 0.
	 * 
	 * Warning: Multiple roles can have the same position number. As a consequence
	 * of this, comparing via role position is prone to subtle bugs if
	 * checking for role hierarchy. The recommended and correct way to
	 * compare for roles in the hierarchy is using the comparison
	 * operators on the role objects themselves.
	 */
	public var position:Int;

	public var _permissions:Int64;
	/**
	 * Returns the role's permissions.
	 */
	public var permissions(get, never):Permissions;
	private var _colour:Int;
	/**
	 * Indicates if the role will be displayed separately from other members.
	 */
	public var hoist:Bool;
	private var _icon:String;
	/**
	 * The role's unicode emoji, if available.
	 * TBD: finish doc
	 */
	public var unicode_emoji:String;
	/**
	 * Indicates if the role is managed by the guild through some form of
	 * integrations such as Twitch.
	 */
	public var managed:Bool;
	/**
	 * Indicates if the role can be mentioned by users.
	 */
	public var mentionable:Bool;
	private var _flags:Int;

	/**
	 * Returns the role color.
	 */
	public var colour(get, never):Colour;

	/**
	 * Returns the role's icon asset, if available.
	 * 
	 * Note: If this is `null`, the role might instead have unicode emoji as its icon
	 * if `unicode_emoji` is not `null`.
	 * 
	 * If you want the icon that a role has displayed, consider using `display_icon`.
	 */
	public var icon(get, never):Asset;

	/**
	 * Returns the role's display icon, if available.
	 */
	public var display_icon(get, never):Dynamic;

	/**
	 * Returns the role's creation time in UTC.
	 */
	public var created_at(get, never):Date;

	/**
	 * Returns a string that allows you to mention a role.
	 */
	public var mention(get, never):String;

	/**
	 * Returns all the members with this role.
	 */
	public var members(get, never):Array<Member>;
	
	public var tags:RoleTags;

	public function new(guild:Guild, state:ConnectionState, data:RolePayload) {
		this.guild = guild;
		this._state = state;
		this.id = data.id;
		this._update(data);
	}

	public function toString():String {
		return this.name;
	}

	/**
	 * Checks if a role is lower than another in the hierarchy.
	 */
	public static function lower_than(which:Role, other:Role):Bool {
		if (other.guild != which.guild)
			throw new Exception('Cannot compare roles from two different guilds.'); // tbd exception

		var guild_id = which.guild.id;
		if (which.id == guild_id) {
			// everyone_role < everyone_role -> false
			return other.id != guild_id;
		}

		if (which.position < other.position) {
			return true;
		}

		if (which.position == other.position) {
			return which.id.i64() > other.id.i64();
		}

		return false;
	}

	/**
	 * Checks if a role is lower or equal to another in the hierarchy.
	 */
	public static function lower_or_equal_than(which:Role, other:Role):Bool {
		return !lower_than(other, which);
	}

	/**
	 * Checks if a role is higher than another in the hierarchy.
	 */
	public static function higher_than(which:Role, other:Role):Bool {
		return lower_than(other, which);
	}

	/**
	 * Checks if a role is higher or equal to another in the hierarchy.
	 */
	public static function higher_or_equal_than(which:Role, other:Role):Bool {
		return !lower_than(which, other);
	}

	public function _update(data:RolePayload) {
		this.name = data.name;
		this._permissions = Int64.parseString(data.permissions ?? '0');
		this.position = data.position ?? 0;
		this._colour = data.color ?? 0;
		this.hoist = data.hoist ?? false;
		this._icon = data.icon;
		this.unicode_emoji = data.unicode_emoji;
		this.managed = data.managed ?? false;
		this.mentionable = data.mentionable ?? false;
		this._flags = data.flags ?? 0;

		if (data.tags != null) {
			this.tags = new RoleTags(data.tags);
		} else {
			this.tags = null;
		}
    }

	/**
	 * Checks if the role is the default role.
	 */
	public function is_default():Bool {
		return this.id == this.guild.id;
	}

	public function is_bot_managed():Bool {
		return this.tags != null && this.tags.is_bot_managed();
	}

	public function is_premium_subscriber():Bool {
		return this.tags != null && this.tags.is_premium_subscriber();
	}

	public function is_integration():Bool {
		return this.tags != null && this.tags.is_integration();
	}

	public function is_assignable():Bool {
		var me = this.guild.me;
		return !this.is_default() && !this.managed && (Role.higher_than(null, this) || me.id == this.guild.owner_id); // TBD NULL: ME.TOP_ROLE
	}

	function get_permissions():Permissions {
		return Permissions.fromValue(this._permissions);
	}

	function get_colour():Colour {
		return new Colour(this._colour);
	}

	function get_icon():Asset {
		if (this._icon == null) return null;

		return Asset._from_icon(this._state, this.id, this._icon, 'role');
	}

	function get_display_icon():Dynamic {
		if (icon != null)
			return icon;
		
		return unicode_emoji;
	}

	function get_created_at():Date {
		return Utils.snowflake_time(this.id);
	}

	function get_mention():String {
		return '<@&${this.id}>';
	}

	function get_members():Array<Member> {
		var all_members:Array<Member> = this.guild.members;

		if (this.is_default()) return all_members;

		return all_members.filter((member:Member) -> {
			return member._roles.contains(this.id);
		});
	}
}
