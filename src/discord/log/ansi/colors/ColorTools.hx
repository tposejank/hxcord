package discord.log.ansi.colors;

// TODO: this may not be correctly organized, may want to move stuff around?

/**
	* Tools for working with ANSI terminal colors and strings that contain
	* commands and colors*
	*/
class ColorTools {

	static public function hexToCM256(hex : Int) : Int {
		return rgbToCM256(
			(hex >> 16) & 0xff,
			(hex >> 8) & 0xff,
			hex & 0xff
		);
	}

	static public function rgbToCM256(r : Int, g : Int, b : Int) : Int {
		// https://en.wikipedia.org/wiki/ANSI_escape_code in the description of colors section describing 16-231.
		return 16 +
			36 * (Math.floor(r/255*6)) +
			6 * (Math.floor(g/255*6)) +
			Math.floor(b/255*6);
	}

	/**
	 * returns a color approximation of the RGB using the standard 8
	 * colors
	 */
	static public function rgbToCM8(r : Int, g : Int, b : Int) : Color {
	
		// arbitray check if this is a gray value. averaging the colors
		// and converting it to grayscale. if the difference is less than VAL
		// then we are going to assume its a gray color and the return black
		// or white.
		var gray = 0.3 * r + 0.59 * g + 0.11 * b;
		var avg = (r+g+b)/3;
		if (Math.abs(gray-avg) < 5) {
			if (gray <= 255/2) return Black;
			else return White;
		}

		// we are going to get the hue and then check
		// where we are and give it one of the standard
		// colors.
		var h = hue(r,g,b);

		if (h >= 330 || (0 <= h && h <= 30)) return Red;
		else if (30 <= h && h <= 60) return Yellow;
		else if (60 <= h && h <=135) return Green;
		else if (135 <= h && h <= 195) return Cyan;
		else if (195 <= h && h <= 270) return Blue;
		else return Magenta;

	}

	static public function hue(r : Int, g : Int, b : Int) : Float {
		var max = Math.max(r,Math.max(g,b));
		var min = Math.min(r,Math.min(g,b));

		var h = 0.0;
		if (max == min) return h;
		else if (max == r) h = (g - b) / (max - min);
		else if (max == g) h = 2.0 + (b - r) / (max - min);
		else h = 4.0 + (r - g) / (max - min);

		h *= 60;
		if (h < 0) h += 360;
		return h;
	}

	static public function cm256IsBright(index : Int) : Bool {
		return false;
	}

	static public function rgbIsBright(r : Int, g : Int, b : Int) : Bool {
		return false;
	}

	static public function cm256ToCM8(index : Int) : Color {
		if (0 <= index && index <= 7) return cast(index);
		else if (8 <= index && index <= 15) return cast(index-8);
		else if (232 <= index && index <= 255) return Black;
		else {
			index -= 16;
			var set = Math.ceil(index / 6);
			var position = index - (set-1) * 6;
		
			// using the logic found https://www.ditig.com/256-colors-cheat-sheet
			// building the colors from index using this pattern.
			//
			// there are sets of 6 colors, the B value moves from 0, 95, +40 for the rest
			// The G changes every 6 color following the same pattern
			// the R changes every 6 sets following the same pattern

			var r = {
				var bigset = Math.floor(set / 6);
				if (bigset == 0) 0;
				else if (bigset == 1) 95;
				else (bigset-1) * 40 + 95;
			}

			var g = {
				var bigset = set - 1;
				while(bigset > 6) bigset -= 6;
				if (bigset == 0) 0;
				else if (bigset == 1) 95;
				else (bigset-1) * 40 + 95;
			};

			var b = {
				if(position == 0) 0;
				else if(position == 1) 95;
				else (position - 1) * 40 + 95;
			}

			return rgbToCM8(r,g,b);
		}
	}

	/**
		* Returns the visual length of the string. Ignores terminal color
		* and style character codes and commands.
		*/
	static public function length(string:String) : Int {
		if (string == null) { return 0; }
		var length = 0;
		var count = true;

		for (i in 0 ... string.length) {
			switch(string.charAt(i)) {
				case Command.ESC: count = false;
				case Command.END if (!count):
					length -= 1; // to uncount this character, which will be counted next.
					count = true;
				default:
			}
			
			if (count) length += 1;
		}

		return length;
	}

	/**
		* Pads the string to the desired length using the optionally provided padding
		* character.
		*
		* Supports ANSI term color and style codes and will calculate the true length
		* using `ansi.colors.ColorTools.length,.
		*
		* Will not do anything if the padded length is less that the current string
		* character length
		*
		*/
	static public function pad(string : String, length: Int, ?paddingChar : String = " ") : String {
		var l = ColorTools.length(string);
		for (_ in l ... length) {
			string += paddingChar;
		}
		return string;
	}

	static public function splitLength(string:String, len:Int) : Array<String> {
		var split = [ ];

		var length = 0;
		var count = true;
		var working : String = "";

		for (i in 0 ... string.length) {
			var char = string.charAt(i);
			switch(char) {
				case Command.ESC: count = false;
				case Command.END if (!count):
					length -= 1; // to uncount this character, which will be counted next.
					count = true;
				default:
			}

			if (count) length += 1;
			working += char;

			if (length == len) {
				length = 0;
				split.push(working);
				working = "";
			}
		}

		if (working.length > 0) split.push(working);

		return split;
	}

	public static function parse(string : String) : Color {
		switch (string.toLowerCase()) {
			case "black": return Black;
			case "red": return Red;
			case "green": return Green;
			case "yellow": return Yellow;
			case "blue": return Blue;
			case "magenta": return Magenta;
			case "cyan": return Cyan;
			case "white": return White;
			case other:
				throw 'cannot parse $other as a color';
		}
	}
}
