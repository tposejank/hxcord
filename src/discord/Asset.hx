package discord;

import haxe.ValueException;
import discord.State.ConnectionState;

using StringTools;

/**
 * Represents a CDN asset on Discord.
 */
class Asset {
    /**
     * Returns the underlying URL of the asset.
     */
    public var url(get, never):String;
    /**
     * Returns the identifying key of the asset.
     */
    public var key(get, never):String;
    /**
     * Returns whether the asset is animated.
     */
    public var is_animated(get, never):Null<Bool>;

    private var _state:ConnectionState;
    private var _animated:Null<Bool>;
    private var _key:String;
    private var _url:String;

    public static var BASE:String = 'https://cdn.discordapp.com';

    public function new(state:ConnectionState, url:String, key:String, animated:Bool) {
        this._state = state;
        this._url = url;
        this._animated = animated;
        this._key = key;
    }

    public static function _from_default_avatar(state:ConnectionState, index:Int):Asset {
        return new Asset(state, '${Asset.BASE}/embed/avatars/${index}.png', Std.string(index), false);
    }

    public static function _from_avatar(state:ConnectionState, user_id:String, avatar:String):Asset {
        var animated = avatar.startsWith('a_');
        var format = (animated ? 'gif' : 'png');
        return new Asset(state, '${Asset.BASE}/avatars/${user_id}/${avatar}.${format}?size=1024', avatar, animated);
    }

    public static function _from_guild_avatar(state:ConnectionState, guild_id:String, member_id:String, avatar:String):Asset {
        var animated = avatar.startsWith('a_');
        var format = (animated ? 'gif' : 'png');
        return new Asset(state, '${Asset.BASE}/guilds/${guild_id}/users/${member_id}/avatars/${avatar}.${format}?size=1024', avatar, animated);
    }

    public static function _from_avatar_decoration(state:ConnectionState, avatar_decoration:String):Asset {
        return new Asset(state, '${Asset.BASE}/avatar-decoration-presets/${avatar_decoration}.png?size=96', avatar_decoration, true);
    }

    public static function _from_icon(state:ConnectionState, object_id:String, icon_hash:String, path:String):Asset {
        return new Asset(state, '${Asset.BASE}/${path}-icons/${object_id}/${icon_hash}.png?size=1024', icon_hash, false);
    }

    public static function _from_app_icon(state:ConnectionState, object_id:String, icon_hash:String, asset_type:String):Asset {
        return new Asset(state, '${Asset.BASE}/app-icons/${object_id}/${asset_type}.png?size=1024', icon_hash, false);
    }

    public static function _from_cover_image(state:ConnectionState, object_id:String, cover_image_hash:String):Asset {
        return new Asset(state, '${Asset.BASE}/app-assets/${object_id}/store/${cover_image_hash}.png?size=1024', cover_image_hash, false);
    }

    public static function _from_scheduled_event_cover_image(state:ConnectionState, scheduled_event_id:String, cover_image_hash:String):Asset {
        return new Asset(state, '${Asset.BASE}/guild-events/${scheduled_event_id}/${cover_image_hash}.png?size=1024', cover_image_hash, false);
    }

    public static function _from_guild_image(state:ConnectionState, guild_id:String, image:String, path:String):Asset {
        var animated = image.startsWith('a_');
        var format = (animated ? 'gif' : 'png');
        return new Asset(state, '${Asset.BASE}/${path}/${guild_id}/${image}.${format}?size=1024', image, animated);
    }

    public static function _from_guild_icon(state:ConnectionState, guild_id:String, icon_hash:String):Asset {
        var animated = icon_hash.startsWith('a_');
        var format = (animated ? 'gif' : 'png');
        return new Asset(state, '${Asset.BASE}/icons/${guild_id}/${icon_hash}.${format}?size=1024', icon_hash, animated);
    }

    public static function _from_sticker_banner(state:ConnectionState, banner:String):Asset {
        return new Asset(state, '${Asset.BASE}/app-assets/710982414301790216/store/${banner}.png', banner, false);
    }

    public static function _from_user_banner(state:ConnectionState, user_id:String, banner_hash:String):Asset {
        var animated = banner_hash.startsWith('a_');
        var format = (animated ? 'gif' : 'png');
        return new Asset(state, '${Asset.BASE}/banners/${user_id}/${banner_hash}.${format}?size=512', banner_hash, animated);
    }

    public function toString():String {
        return this._url;
    }

    public function get_url():String {
        return this._url;
    }

    public function get_key():String {
        return this._key;
    }

    public function get_is_animated():Null<Bool> {
        return this._animated;
    }

    public function with_size(size:Int):Asset {
        if (!Utils.valid_icon_size(size)) {
            throw new ValueException('size must be a power of 2 between 16 and 4096');
        }

        // the hell is a url library
        var url = this._url.split('?size=')[0] + '?size=${size}';
        return new Asset(this._state, url, this._key, this._animated);
    }
}