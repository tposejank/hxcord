package discord.utils.log.ansi.colors;

enum abstract Color(String) {
	var Black = "0";
	var Red = "1";
	var Green = "2";
	var Yellow = "3";
	var Blue = "4";
	var Magenta = "5";
	var Cyan = "6";
	var White = "7";
	var Default = "9";
}

// PLACEMENT CODES ////////////////////////////////////

inline var FG : String = "3";
inline var BG : String = "4";
inline var UL : String = "5";
inline var BFG : String = "9";
inline var BBG : String = "10";

// extra placement codes for AIXTERM spec //////////////

inline var BRIGHT_FG : String = "9";
inline var BRIGHT_BG : String = "10";
