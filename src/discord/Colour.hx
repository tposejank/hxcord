package discord;

/**
 * Represents a Discord role colour.
 * 
 * This class is basically a hard copy of 
 * https://github.com/HaxeFlixel/flixel/blob/master/flixel/util/FlxColor.hx
 * 
 * Slightly modified with no references to `FlxMath`.
 * 
 * @author Joe Williamson (JoeCreates)/HaxeFlixel
 */
abstract Colour(Int) from Int from UInt to Int to UInt
{
	/**
	 * This is not a `discord.py` colour.
	 */
	public static inline var WHITE:Colour = 0xFFFFFFFF;
	/**
	 * This is not a `discord.py` colour.
	 */
    public static inline var BLACK:Colour = 0xFF000000;
    /**
	 * This is not a Discord colour. This is the standard Gray colour.
	 */
	public static inline var GRAY:Colour = 0xFF808080;

	/**
	 * This is not a Discord colour. This is the standard Green colour.
	 */
	public static inline var _GREEN:Colour = 0xFF008000;
	/**
	 * This is not a `discord.py` colour.
	 */
	public static inline var LIME:Colour = 0xFF00FF00;
    /**
	 * This is not a Discord colour. This is the standard Yellow colour.
	 */
	public static inline var _YELLOW:Colour = 0xFFFFFF00;
    /**
	 * This is not a Discord colour. This is the standard Orange colour.
	 */
	public static inline var _ORANGE:Colour = 0xFFFFA500;
    /**
	 * This is not a Discord colour. This is the standard Red colour.
	 */
	public static inline var _RED:Colour = 0xFFFF0000;
    /**
	 * This is not a Discord colour. This is the standard Purple colour.
	 */
	public static inline var _PURPLE:Colour = 0xFF800080;
    /**
	 * This is not a Discord colour. This is the standard Blue colour.
	 */
	public static inline var _BLUE:Colour = 0xFF0000FF;
	/**
	 * This is not a `discord.py` colour.
	 */
	public static inline var BROWN:Colour = 0xFF8B4513;
    /**
	 * This is not a Discord colour. This is the standard Pink colour.
	 */
	public static inline var _PINK:Colour = 0xFFFFC0CB;
    /**
	 * This is not a Discord colour. This is the standard Magenta colour.
	 */
	public static inline var _MAGENTA:Colour = 0xFFFF00FF;
	/**
	 * This is not a `discord.py` colour.
	 */
	public static inline var CYAN:Colour = 0xFF00FFFF;

    public static inline var TEAL:Colour = 0xFF1ABC9C;
    public static inline var DARK_TEAL:Colour = 0xFF11806A;
    public static inline var BRAND_GREEN:Colour = 0xFF57F287;
    public static inline var GREEN:Colour = 0xFF2ECC71;
    public static inline var DARK_GREEN:Colour = 0xFF1F8B4C;
    public static inline var BLUE:Colour = 0xFF3498DB;
    public static inline var DARK_BLUE:Colour = 0xFF206694;
    public static inline var PURPLE:Colour = 0xFF9B59B6;
    public static inline var DARK_PURPLE:Colour = 0xFF71368A;
    public static inline var MAGENTA:Colour = 0xFFE91E63;
    public static inline var DARK_MAGENTA:Colour = 0xFFAD1457;
    public static inline var GOLD:Colour = 0xFFF1C40F;
    public static inline var DARK_GOLD:Colour = 0xFFC27C0E;
    public static inline var ORANGE:Colour = 0xFFE67E22;
    public static inline var DARK_ORANGE:Colour = 0xFFA84300;
    public static inline var BRAND_RED:Colour = 0xFFED4245;
    public static inline var RED:Colour = 0xFFE74C3C;
    public static inline var DARK_RED:Colour = 0xFF992D22;
    public static inline var LIGHTER_GRAY:Colour = 0xFF95A5A6;
    public static inline var DARK_GRAY:Colour = 0xFF607D8B;
    public static inline var LIGHT_GRAY:Colour = 0xFF979C9F;
    public static inline var DARKER_GRAY:Colour = 0xFF546E7A;
    public static inline var OG_BLURPLE:Colour = 0xFF7289DA;
    public static inline var BLURPLE:Colour = 0xFF5865F2;
    public static inline var GREYPLE:Colour = 0xFF99AAB5;
    public static inline var DARK_THEME:Colour = 0xFF313338;
    public static inline var FUCHSIA:Colour = 0xFFEB459E;
    public static inline var YELLOW:Colour = 0xFFFEE75C;
    public static inline var DARK_EMBED:Colour = 0xFF2B2D31;
    public static inline var LIGHT_EMBED:Colour = 0xFFEEEFF1;
    public static inline var PINK:Colour = 0xFFEB459F;

	public var red(get, set):Int;
	public var blue(get, set):Int;
	public var green(get, set):Int;
	public var alpha(get, set):Int;

	public var redFloat(get, set):Float;
	public var blueFloat(get, set):Float;
	public var greenFloat(get, set):Float;
	public var alphaFloat(get, set):Float;

	public var cyan(get, set):Float;
	public var magenta(get, set):Float;
	public var yellow(get, set):Float;
	public var black(get, set):Float;

	/**
	 * The red, green and blue channels of this color as a 24 bit integer (from 0 to 0xFFFFFF)
	 */
	public var rgb(get, set):Colour;

	/** 
	 * The hue of the color in degrees (from 0 to 359)
	 */
	public var hue(get, set):Float;

	/**
	 * The saturation of the color (from 0 to 1)
	 */
	public var saturation(get, set):Float;

	/**
	 * The brightness (aka value) of the color (from 0 to 1)
	 */
	public var brightness(get, set):Float;

	/**
	 * The lightness of the color (from 0 to 1)
	 */
	public var lightness(get, set):Float;

	static var COLOR_REGEX = ~/^(0x|#)(([A-F0-9]{2}){3,4})$/i;

	/**
	 * Create a color from the least significant four bytes of an Int
	 *
	 * @param	Value And Int with bytes in the format 0xAARRGGBB
	 * @return	The color as a Colour
	 */
	public static inline function fromInt(Value:Int):Colour
	{
		return new Colour(Value);
	}

	/**
	 * Generate a color from integer RGB values (0 to 255)
	 *
	 * @param Red	The red value of the color from 0 to 255
	 * @param Green	The green value of the color from 0 to 255
	 * @param Blue	The green value of the color from 0 to 255
	 * @param Alpha	How opaque the color should be, from 0 to 255
	 * @return The color as a Colour
	 */
	public static inline function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Colour
	{
		var color = new Colour();
		return color.setRGB(Red, Green, Blue, Alpha);
	}

	/**
	 * Generate a color from float RGB values (0 to 1)
	 *
	 * @param Red	The red value of the color from 0 to 1
	 * @param Green	The green value of the color from 0 to 1
	 * @param Blue	The green value of the color from 0 to 1
	 * @param Alpha	How opaque the color should be, from 0 to 1
	 * @return The color as a Colour
	 */
	public static inline function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Colour
	{
		var color = new Colour();
		return color.setRGBFloat(Red, Green, Blue, Alpha);
	}

	/**
	 * Generate a color from CMYK values (0 to 1)
	 *
	 * @param Cyan		The cyan value of the color from 0 to 1
	 * @param Magenta	The magenta value of the color from 0 to 1
	 * @param Yellow	The yellow value of the color from 0 to 1
	 * @param Black		The black value of the color from 0 to 1
	 * @param Alpha		How opaque the color should be, from 0 to 1
	 * @return The color as a Colour
	 */
	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Colour
	{
		var color = new Colour();
		return color.setCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}

	/**
	 * Generate a color from HSB (aka HSV) components.
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	(aka Value) A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a Colour
	 */
	public static function fromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1):Colour
	{
		var color = new Colour();
		return color.setHSB(Hue, Saturation, Brightness, Alpha);
	}

	/**
	 * Generate a color from HSL components.
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Lightness	A number between 0 and 1, indicating the lightness of the color
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a Colour
	 */
	public static inline function fromHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float = 1):Colour
	{
		var color = new Colour();
		return color.setHSL(Hue, Saturation, Lightness, Alpha);
	}

	/**
	 * Multiply the RGB channels of two Colours
	 */
	@:op(A * B)
	public static inline function multiply(lhs:Colour, rhs:Colour):Colour
	{
		return Colour.fromRGBFloat(lhs.redFloat * rhs.redFloat, lhs.greenFloat * rhs.greenFloat, lhs.blueFloat * rhs.blueFloat);
	}

	/**
	 * Add the RGB channels of two Colours
	 */
	@:op(A + B)
	public static inline function add(lhs:Colour, rhs:Colour):Colour
	{
		return Colour.fromRGB(lhs.red + rhs.red, lhs.green + rhs.green, lhs.blue + rhs.blue);
	}

	/**
	 * Subtract the RGB channels of one Colour from another
	 */
	@:op(A - B)
	public static inline function subtract(lhs:Colour, rhs:Colour):Colour
	{
		return Colour.fromRGB(lhs.red - rhs.red, lhs.green - rhs.green, lhs.blue - rhs.blue);
	}

	/**
	 * Return a 24 bit version of this color (i.e. without an alpha value)
	 *
	 * @return A 24 bit version of this color
	 */
	public inline function to24Bit():Colour
	{
		return this & 0xffffff;
	}

	/**
	 * Return a String representation of the color in the format
	 *
	 * @param Alpha Whether to include the alpha value in the hex string
	 * @param Prefix Whether to include "0x" prefix at start of string
	 * @return	A string of length 10 in the format 0xAARRGGBB
	 */
	public inline function toHexString(Alpha:Bool = true, Prefix:Bool = true):String
	{
		return (Prefix ? "0x" : "") + (Alpha ? StringTools.hex(alpha,
			2) : "") + StringTools.hex(red, 2) + StringTools.hex(green, 2) + StringTools.hex(blue, 2);
	}

	/**
	 * Return a String representation of the color in the format #RRGGBB
	 *
	 * @return	A string of length 7 in the format #RRGGBB
	 */
	public inline function toWebString():String
	{
		return "#" + toHexString(false, false);
	}

	/**
	 * Get the inversion of this color
	 *
	 * @return The inversion of this color
	 */
	public inline function getInverted():Colour
	{
		var oldAlpha = alpha;
		var output:Colour = Colour.WHITE - this;
		output.alpha = oldAlpha;
		return output;
	}

	/**
	 * Set RGB values as integers (0 to 255)
	 *
	 * @param Red	The red value of the color from 0 to 255
	 * @param Green	The green value of the color from 0 to 255
	 * @param Blue	The green value of the color from 0 to 255
	 * @param Alpha	How opaque the color should be, from 0 to 255
	 * @return This color
	 */
	public inline function setRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Colour
	{
		red = Red;
		green = Green;
		blue = Blue;
		alpha = Alpha;
		return this;
	}

	/**
	 * Set RGB values as floats (0 to 1)
	 *
	 * @param Red	The red value of the color from 0 to 1
	 * @param Green	The green value of the color from 0 to 1
	 * @param Blue	The green value of the color from 0 to 1
	 * @param Alpha	How opaque the color should be, from 0 to 1
	 * @return This color
	 */
	public inline function setRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Colour
	{
		redFloat = Red;
		greenFloat = Green;
		blueFloat = Blue;
		alphaFloat = Alpha;
		return this;
	}

	/**
	 * Set CMYK values as floats (0 to 1)
	 *
	 * @param Cyan		The cyan value of the color from 0 to 1
	 * @param Magenta	The magenta value of the color from 0 to 1
	 * @param Yellow	The yellow value of the color from 0 to 1
	 * @param Black		The black value of the color from 0 to 1
	 * @param Alpha		How opaque the color should be, from 0 to 1
	 * @return This color
	 */
	public inline function setCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Colour
	{
		redFloat = (1 - Cyan) * (1 - Black);
		greenFloat = (1 - Magenta) * (1 - Black);
		blueFloat = (1 - Yellow) * (1 - Black);
		alphaFloat = Alpha;
		return this;
	}

	/**
	 * Set HSB (aka HSV) components
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	(aka Value) A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	This color
	 */
	public inline function setHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float):Colour
	{
		var chroma = Brightness * Saturation;
		var match = Brightness - chroma;
		return setHueChromaMatch(Hue, chroma, match, Alpha);
	}

	/**
	 * Set HSL components.
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Lightness	A number between 0 and 1, indicating the lightness of the color
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255
	 * @return	This color
	 */
	public inline function setHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float):Colour
	{
		var chroma = (1 - Math.abs(2 * Lightness - 1)) * Saturation;
		var match = Lightness - chroma / 2;
		return setHueChromaMatch(Hue, chroma, match, Alpha);
	}

	/**
	 * Private utility function to perform common operations between setHSB and setHSL
	 */
	inline function setHueChromaMatch(Hue:Float, Chroma:Float, Match:Float, Alpha:Float):Colour
	{
		Hue %= 360;
		var hueD = Hue / 60;
		var mid = Chroma * (1 - Math.abs(hueD % 2 - 1)) + Match;
		Chroma += Match;

		switch (Std.int(hueD))
		{
			case 0:
				setRGBFloat(Chroma, mid, Match, Alpha);
			case 1:
				setRGBFloat(mid, Chroma, Match, Alpha);
			case 2:
				setRGBFloat(Match, Chroma, mid, Alpha);
			case 3:
				setRGBFloat(Match, mid, Chroma, Alpha);
			case 4:
				setRGBFloat(mid, Match, Chroma, Alpha);
			case 5:
				setRGBFloat(Chroma, Match, mid, Alpha);
		}

		return this;
	}

	public function new(Value:Int = 0)
	{
		this = Value;
	}

	inline function getThis():Int
	{
		#if neko
		return Std.int(this);
		#else
		return this;
		#end
	}

	inline function validate():Void
	{
		#if neko
		this = Std.int(this);
		#end
	}

	inline function get_red():Int
	{
		return (getThis() >> 16) & 0xff;
	}

	inline function get_green():Int
	{
		return (getThis() >> 8) & 0xff;
	}

	inline function get_blue():Int
	{
		return getThis() & 0xff;
	}

	inline function get_alpha():Int
	{
		return (getThis() >> 24) & 0xff;
	}

	inline function get_redFloat():Float
	{
		return red / 255;
	}

	inline function get_greenFloat():Float
	{
		return green / 255;
	}

	inline function get_blueFloat():Float
	{
		return blue / 255;
	}

	inline function get_alphaFloat():Float
	{
		return alpha / 255;
	}

	inline function set_red(Value:Int):Int
	{
		validate();
		this &= 0xff00ffff;
		this |= boundChannel(Value) << 16;
		return Value;
	}

	inline function set_green(Value:Int):Int
	{
		validate();
		this &= 0xffff00ff;
		this |= boundChannel(Value) << 8;
		return Value;
	}

	inline function set_blue(Value:Int):Int
	{
		validate();
		this &= 0xffffff00;
		this |= boundChannel(Value);
		return Value;
	}

	inline function set_alpha(Value:Int):Int
	{
		validate();
		this &= 0x00ffffff;
		this |= boundChannel(Value) << 24;
		return Value;
	}

	inline function set_redFloat(Value:Float):Float
	{
		red = Math.round(Value * 255);
		return Value;
	}

	inline function set_greenFloat(Value:Float):Float
	{
		green = Math.round(Value * 255);
		return Value;
	}

	inline function set_blueFloat(Value:Float):Float
	{
		blue = Math.round(Value * 255);
		return Value;
	}

	inline function set_alphaFloat(Value:Float):Float
	{
		alpha = Math.round(Value * 255);
		return Value;
	}

	inline function get_cyan():Float
	{
		return (1 - redFloat - black) / brightness;
	}

	inline function get_magenta():Float
	{
		return (1 - greenFloat - black) / brightness;
	}

	inline function get_yellow():Float
	{
		return (1 - blueFloat - black) / brightness;
	}

	inline function get_black():Float
	{
		return 1 - brightness;
	}

	inline function set_cyan(Value:Float):Float
	{
		setCMYK(Value, magenta, yellow, black, alphaFloat);
		return Value;
	}

	inline function set_magenta(Value:Float):Float
	{
		setCMYK(cyan, Value, yellow, black, alphaFloat);
		return Value;
	}

	inline function set_yellow(Value:Float):Float
	{
		setCMYK(cyan, magenta, Value, black, alphaFloat);
		return Value;
	}

	inline function set_black(Value:Float):Float
	{
		setCMYK(cyan, magenta, yellow, Value, alphaFloat);
		return Value;
	}

	function get_hue():Float
	{
		var hueRad = Math.atan2(Math.sqrt(3) * (greenFloat - blueFloat), 2 * redFloat - greenFloat - blueFloat);
		var hue:Float = 0;
		if (hueRad != 0)
		{
			hue = 180 / Math.PI * hueRad;
		}

		return hue < 0 ? hue + 360 : hue;
	}

	inline function get_brightness():Float
	{
		return maxColor();
	}

	inline function get_saturation():Float
	{
		return (maxColor() - minColor()) / brightness;
	}

	inline function get_lightness():Float
	{
		return (maxColor() + minColor()) / 2;
	}

	inline function set_hue(Value:Float):Float
	{
		setHSB(Value, saturation, brightness, alphaFloat);
		return Value;
	}

	inline function set_saturation(Value:Float):Float
	{
		setHSB(hue, Value, brightness, alphaFloat);
		return Value;
	}

	inline function set_brightness(Value:Float):Float
	{
		setHSB(hue, saturation, Value, alphaFloat);
		return Value;
	}

	inline function set_lightness(Value:Float):Float
	{
		setHSL(hue, saturation, Value, alphaFloat);
		return Value;
	}

	inline function set_rgb(value:Colour):Colour
	{
		validate();
		this = (this & 0xff000000) | (value & 0x00ffffff);
		return value;
	}

	inline function get_rgb():Colour
	{
		return this & 0x00ffffff;
	}

	inline function maxColor():Float
	{
		return Math.max(redFloat, Math.max(greenFloat, blueFloat));
	}

	inline function minColor():Float
	{
		return Math.min(redFloat, Math.min(greenFloat, blueFloat));
	}

	inline function boundChannel(Value:Int):Int
	{
		return Value > 0xff ? 0xff : Value < 0 ? 0 : Value;
	}
}