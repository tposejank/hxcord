package discord.log.ansi;

import discord.log.ansi.colors.ColorTools;

/**
 * General ANSI commands, for text appearance @see ansi.Paint
 */
class Command {

	// STATIC COMMAND STRINGS //////////////////////////////////////////

	/*** The starting escape character that starts the command */
	inline public static var ESC : String = "\033";

	/*** The ending code to stop a command */
	inline public static var END : String = "m";

	// CLEARING ////////////////////////////////////////////////////////

	/*** Clears the console screen */
	public static function clearScreen() exec('2J');

	/*** Clears the screen from 1,1 to the cursor */
	public static function clearScreenBeforeCursor() exec('1J');

	/*** Clears the screen from the cursor to the end of the screen */
	public static function clearScreenAfterCursor() exec('0J');

	/*** Clears the whole line */
	public static function clearLine() exec("2K");

	/*** Clears the line to the left of the cursor */
	public static function clearLeft() exec("1K");

	/*** Clears the line to the right of the cursor */
	public static function clearRight() exec("0K");

	// CURSOR CONTROL //////////////////////////////////////////////////

	/*** Hides the cursor */
	public static function hideCursor() exec('?25l');

	/*** Shows the cursor */
	public static function showCursor() exec('?25h');

	/**
	 * Moves the cursor to the requested point on the screen
	 *
	 * @param r The row position
	 * @param c The column position
	 */
	public static function moveCursor(r:Int, c:Int) exec('${r};${c}H');

	/*** Moves the cursor to the home position; 0,0 */
	public static function moveCursorHome() exec('H');

	/*** Relatively moves the cursor `rows` rows up from the current position */
	public static function moveCursorUp(?rows : Int = 1) exec('${rows}A');
	
	/*** Relatively moves the cursor `rows` rows down from the current position */
	public static function moveCursorDown(?rows : Int = 1) exec('${rows}B');
	
	/*** Relatively moves the cursor `columns` columns left from the current position */
	public static function moveCursorLeft(?columns : Int = 1) exec('${columns}C');
	
	/*** Relatively moves the cursor `columns` columns right from the current position */
	public static function moveCursorRight(?columns : Int = 1) exec('${columns}D');

	/**
	 * Relatively moves the cursor `rows` rows down from the current position,
	 * to the start of the row.
	 */
	public static function moveCursorDownStart(?rows : Int = 1) exec('${rows}E');
	
	/**
	 * Relatively moves the cursor `rows` rows up from the current position,
	 * to the start of the row
	 */
	public static function moveCursorUpStart(?rows : Int = 1) exec('${rows}F');

	/*** Moves the cursor to the requested column */
	public static function moveCursorToColumn(?columns : Int = 1) exec('${columns}C');

	/*** saves the current position of the cursor */
	public static function saveCursor() exec("s");

	/*** moves the cursor to the saved position */
	public static function restoreCursor() exec("u");

	/**
	 * Writes the string to the supplied console row and column
	 *
	 * @param r The row
	 * @param c The column
	 * @param text The text to write to the screen
	 *
	 * @return The cursor column position after writing the text
	 */
	public static function write(r:Int, c:Int, text:String) : Int {
		moveCursor(r,c);
		Sys.print(text);
		var length = ColorTools.length(text);
		return length + c;
	}

	/**
	 * Fill the space with the given text. Does not check the size
	 * of the text so if `text.length > 1` then the drawn text will
	 * not be confined to the limits of the box.
	 *
	 * @param r The row
	 * @param c The column
	 * @param height The row height
	 * @param width The column width
	 * @param text The text to write to the screen
	 *
	 * @return The cursor column position after writing the text
	 */
	public static function fill(r:Int, c:Int, height:Int, width:Int, text:String) {
		var string = "";
		for (_ in 0 ... width) string += text;
		for (h in 0 ... height) {
			write(r+h, c, string);
		}
	}

	/**
	 * Gives the current cursor postion
	 */
	public static function cursorPosition() : Null<{ r:Int, c:Int }> {
		if (Mode.mode == Bare) return null;

		exec('6n');

		var w = 0;
		var h = 0;
		var code = 0;
		var int = "";

		while(code != 82) {

			code = Sys.getChar(false);
			switch(code) {

				// a '[' we are starting capturing the row value
				case 91:
					int = "";

				// a ';' we finish the row, starting the col
				case 59:
					h = Std.parseInt(int);
					int = "";

				// a 'R', we are at the end and now have the col
				case 82:
					w = Std.parseInt(int);

				default:
					int += String.fromCharCode(code);
			}


		}

		return { c:w, r:h };
	}

	/**
	 * Gets the size of the current terminal window
	 */
	public static function getSize() : Null<{ r:Int, c:Int }> {
		if (Mode.mode == Bare) return null;

		// originally used saveCursor / restoreCursor but i got
		// weird stuff where it would not restore to the same point
		// and i would see partial command codes output to the terminal.
		var startingPos = cursorPosition();
		moveCursor(999,999);
		var size = cursorPosition();
		moveCursor(startingPos.r, startingPos.c);

		return size;
	}

	/*** Internal helper function for sending a command to the terminal */
	inline public static function exec(command:String) {
		if (Mode.mode != Bare) Sys.print(make(command));
	}

	// TODO: need to decide if i want to include DEC commands too
	// http://gist.github.com/fnky/45871934aabd01cfb17a3a4f7296797
	/*** Internal helper function for sending DEC commands */
	inline public static function execDec(command:String) {
		if (Mode.mode != Bare) Sys.print('$ESC$command');
	}

	inline public static function make(command:String) : String {
		if (Mode.mode == Bare) return "";
		else return '$ESC[$command';
	}
}
