package discord.utils.log.ansi.colors;

enum abstract ColorMode(Int) {
	var CM16 = 0;
	var CM256 = 1;
	var TRUE_COLOR = 2;
}

var mode : ColorMode = TRUE_COLOR;

function check() mode = get();

function get() {

	// checking for truecolor.
	Sys.print(discord.utils.log.ansi.Paint.colorRGB(1,1,1));
	Sys.print("\033P$qm\033\\");
	Sys.print(discord.utils.log.ansi.Paint.reset());
	if (getColorMode() == "38") return TRUE_COLOR;

	Sys.print(discord.utils.log.ansi.Paint.color256(132));
	Sys.print("\033P$qm\033\\");
	Sys.print(discord.utils.log.ansi.Paint.reset());
	if (getColorMode() == "95m") return CM256;

	return CM16;
}

private function getColorMode() : String {
	var code : Array<Int> = [];
	while(code.length == 0 || code[code.length-1] != 92) code.push(Sys.getChar(false));
	while(code.length > 0) {
		var char = code.shift();
		if (char == 114) {
			var setting = "";
			while(code.length > 0 && code[0] != 58) setting += String.fromCharCode(code.shift());
			return setting;
		}
	}

	return "";
}
