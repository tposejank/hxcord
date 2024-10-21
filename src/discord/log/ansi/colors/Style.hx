package discord.log.ansi.colors;

enum abstract Style(Int) to Int {
	var None = 0;
	var Bold = 1 << 0;
	var Dim = 1 << 1;
	var Standout = 1 << 2;
	var Underline = 1 << 3;
	var Blink = 1 << 4;
	var RapidBlink = 1 << 5;
	var Reverse = 1 << 6;
	var Hidden = 1 << 7;
	var Strike = 1 << 8;
	var DoubleUnderline = 1 << 9;
	var FGBright = 1 << 10;
	var BGBright = 1 << 11;
}

// STYLE SET CODES ///////////////////////////

inline var RESET : String = "0";
inline var BOLD : String = "1";
inline var DIM : String = "2";
inline var STANDOUT : String = "3";
inline var UNDERSCORE : String = "4";
inline var BLINK : String = "5";
inline var RAPIDBLINK : String = "6";
inline var REVERSE : String = "7";
inline var HIDDEN : String = "8";
inline var STRIKETHROUGH : String = "9";
inline var DOUBLEUNDERSCORE : String = "21";

// STYLE RESET CODES //////////////////////////

inline var BOLD_RESET : String = "22";
inline var DIM_RESET : String = "22";
inline var STANDOUT_RESET : String = "23";
inline var UNDERSCORE_RESET : String = "24";
inline var BLINK_RESET : String = "25";
inline var REVERSE_RESET : String = "27";
inline var HIDDEN_RESET : String = "28";
inline var STRIKETHROUGH_RESET : String = "29";
inline var DOUBLEUNDERSCORE_RESET : String = "24";
