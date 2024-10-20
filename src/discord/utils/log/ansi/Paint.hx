package discord.utils.log.ansi;

import discord.utils.log.ansi.colors.Color;
import discord.utils.log.ansi.colors.Style;

class Paint {

	// INTERNAL HELPER FUNCTIONS ////////////////////////////////////

	inline private static function command(com:String) : String {
		if (discord.utils.log.ansi.Mode.mode == Bare) return "";
		else return discord.utils.log.ansi.Command.make(com + "m");
}

	inline private static function _RGB(mode : String, r:Int, g:Int, b:Int) : String
		return command('${mode}8;2;$r;$g;$b');

	inline private static function _CM256(mode:String, index : Int) : String
		return command('${mode}8;5;$index');

	inline private static function _CM8(mode:String, color: Color, bright : Bool) : String {
		return if (bright && mode == FG) command(BFG + color);
		else if (bright && mode == BG) command(BBG + color);
		else command(mode + color);
	}

	inline private static function _CM256Helper(mode : String, index : Int) : String {
		switch(discord.utils.log.ansi.colors.ColorMode.mode) {
			case CM16:
				var newColor = discord.utils.log.ansi.colors.ColorTools.cm256ToCM8(index);
				var bright = discord.utils.log.ansi.colors.ColorTools.cm256IsBright(index);
				return _CM8(mode, newColor, bright);

			default:
				return _CM256(mode,index);
		}
	}

	inline private static function _trueColorHelper(mode : String, r : Int, g : Int, b : Int)  : String {
		switch(discord.utils.log.ansi.colors.ColorMode.mode) {

			case CM16:
				var newColor = discord.utils.log.ansi.colors.ColorTools.rgbToCM8(r,g,b);
				var bright = discord.utils.log.ansi.colors.ColorTools.rgbIsBright(r,g,b);
				return _CM8(mode, newColor, bright);

			case CM256:
				var index = discord.utils.log.ansi.colors.ColorTools.rgbToCM256(r,g,b);
				return _CM256(mode,index);

			case TRUE_COLOR:
				return _RGB(mode,r,g,b);
		}
	}

	// PIECEMEAL PAINTING - COLORS //////////////////////////////////

	/**
	 * Sets the foreground color, will set the color to "default" if not set
	 */
	public static function color(?color:Color = Default, ?bright : Bool = false) : String {
		return if (bright) command(BFG + color);
		else command(FG + color);
	}

	/**
	 * Sets the foreground color using a 256 color palette. Valid range is 0 - 255.
	 *
	 * No runtime checks to ensure `index` is within range. Behavior is unspecified outside of
	 * this range and can change depending on the terminal used.
	 */
	public static function color256(index : Int) : String
		return _CM256Helper(FG,index);

	/**
	 * Sets the foreground color using RGBint.
	 * Supported by terminals that support "Truecolor" (24-bit color)
	 */
	public static function colorRGB(r:Int, g:Int, b:Int) : String
		return _trueColorHelper(FG,r,g,b);

	/**
	 * Sets the background color with **truecolor** using a hex-int.
	 */
	public static function colorHex(hex : Int) : String {
		return colorRGB(
			(hex >> 16) & 0xff,
			(hex >> 8) & 0xff,
			hex & 0xff
		);
	}

	/*** Sets the background color, will set the color to "default" if not set */
	public static function background(?color:Color = Default, ?bright : Bool = false) : String {
		return if (bright) command(BBG + color);
		else command(BG + color);
	}

	/**
	 * Sets the background color using a 256 color palette. Valid range is 0 - 255.
	 *
	 * No runtime checks to ensure `index` is within range. Behavior is unspecified outside of
	 * this range and can change depending on the terminal used.
	 */
	public static function background256(index : Int) : String
		return _CM256Helper(BG,index);

	/**
	 * Sets the background color using RGBint.
	 * Supported by terminals that support "Truecolor" (24-bit color)
	 */
	public static function backgroundRGB(r:Int, g:Int, b:Int) : String
		return _trueColorHelper(BG,r,g,b);

	/**
	 * Sets the background color with **truecolor** using a hex-int.
	 */
	public static function backgroundHex(hex : Int) : String {
		return backgroundRGB(
			(hex >> 16) & 0xff,
			(hex >> 8) & 0xff,
			hex & 0xff
		);
	}

	/*** Sets the underline color, will set the color to "default" if not set */
	public static function underlineColor(?color:Color = Default, ?bright : Bool = false) : String {
		var b = if (bright) ";1" else "";
		return command(BG + color + b);
	}

	/**
	 * Sets the underline color using a 256 color palette. Valid range is 0 - 255.
	 *
	 * No runtime checks to ensure `index` is within range. Behavior is unspecified outside of
	 * this range and can change depending on the terminal used.
	 */
	public static function underlineColor256(index : Int) : String
		return _CM256Helper(UL,index);

	/**
	 * Sets the underline color using RGBint.
	 * Supported by terminals that support "Truecolor" (24-bit color)
	 */
	public static function underlineColorRGB(r:Int, g:Int, b:Int) : String
		return _trueColorHelper(UL,r,g,b);

	/**
	 * Sets the underline color with **truecolor** using a hex-int.
	 */
	public static function underlineColorHex(hex : Int) : String {
		return underlineColorRGB(
			(hex >> 16) & 0xff,
			(hex >> 8) & 0xff,
			hex & 0xff
		);
	}

	// PIECEMEAL PAINTING - STYLES ////////////////////////////////

	/*** Resets all color and styles */
	public static function reset() : String return command(RESET);

	/*** Sets the bold style */
	public static function bold(?state : Bool = true) : String {
		if (state) return command(BOLD);
		else return command(BOLD_RESET);
	}

	/*** Sets the dim style */
	public static function dim(?state : Bool = true) : String {
		if (state) return command(DIM);
		else return command(DIM_RESET);
	}

	/*** Sets the italic style */
	public static function italic(?state : Bool = true) : String {
		if (state) return command(STANDOUT);
		else return command(STANDOUT_RESET);
	}

	/*** Sets the underline style */
	public static function underline(?state : Bool = true) : String {
		if (state) return command(UNDERSCORE);
		else return command(UNDERSCORE_RESET);
	}

	/*** Sets the blink style */
	public static function blink(?state : Bool = true) : String {
		if (state) return command(BLINK);
		else return command(BLINK_RESET);
	}

	/*** Sets the rapid blink style */
	public static function rapidBlink(?state : Bool = true) : String {
		if (state) return command(RAPIDBLINK);
		else return command(BLINK_RESET);
	}

	/*** Sets the reverse style */
	public static function reverse(?state : Bool = true) : String {
		if (state) return command(REVERSE);
		else return command(REVERSE_RESET);
	}

	/*** Sets the hidden style */
	public static function hidden(?state : Bool = true) : String {
		if (state) return command(HIDDEN);
		else return command(HIDDEN_RESET);
	}

	/*** Sets the strikethrough style */
	public static function strike(?state : Bool = true) : String {
		if (state) return command(STRIKETHROUGH);
		else return command(STRIKETHROUGH_RESET);
	}

	/*** Sets the double underline style */
	public static function doubleUnderline(?state : Bool = true) : String {
		if (state) return command(DOUBLEUNDERSCORE);
		else return command(DOUBLEUNDERSCORE_RESET);
	}

	// ALL IN ONE PAINTING /////////////////////////////////////////

	public static function paint(text : Dynamic, ?fg : Color, ?bg : Color, ?flags : Int = 0) : String {
		var line = "";

		if (bg != null) line += background(bg, flags & Style.BGBright != 0);
		if (fg != null) line += color(fg, flags & Style.FGBright != 0);

		if (flags & Style.Bold != 0) line += bold();
		if (flags & Style.Dim != 0) line += dim();
		if (flags & Style.Standout != 0) line += italic();
		if (flags & Style.Underline != 0) line += underline();
		if (flags & Style.Blink != 0) line += blink();
		if (flags & Style.RapidBlink != 0) line += rapidBlink();
		if (flags & Style.Reverse != 0) line += reverse();
		if (flags & Style.Hidden != 0) line += hidden();
		if (flags & Style.Strike != 0) line += strike();
		if (flags & Style.DoubleUnderline != 0) line += doubleUnderline();

		line += '$text';

		line += reset();

		return line;
	}

	/**
	 * paints the text while preserving existing ansi color codes. will only paint unpainted
	 * text with the new color.
	 */
	public static function paintPreserve(text : Dynamic, ?fg : Color, ?bg : Color, ?flags : Int = 0) : String {
			
		var sets = discord.utils.log.ansi.CommandTools.splitByCodeSets(text);

		var newtext = "";
		for (pair in sets) {
			if (pair.code == null) newtext += paint(pair.text, fg, bg, flags);
			else newtext += pair.code + pair.text + reset();
		}

		return newtext;
	}
}
