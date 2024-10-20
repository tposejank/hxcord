package discord.utils.log.ansi;

class CommandTools {

	public static function splitByCodeSets(string : String) : Array<{text:String, ?code:String}> {
		var sets = [];
		
		var currentcode : String = "";
		var currentstring : String = "";

		var i = 0;
		while(i < string.length) {
			var code = string.charCodeAt(i);

			// the start of a command
			if (code == 27) {
				var end = i;
				while(end < string.length && string.charCodeAt(end) != 109) end += 1;
				var codestring = string.substr(i, end - i + 1);
				
				if (currentstring.length > 0) sets.push({
					text: currentstring,
					code: if(currentcode.length > 0) currentcode else null
				});

				// checks if this is a reset code. and if so we set
				// the code to nothing instead of saving the currently
				// saved code.
				if (codestring.charCodeAt(2) == 48) currentcode = "";
				// if we don't have a string value then we stack this code to the
				// the previous one
				else if (currentstring.length == 0) currentcode += codestring;
				else currentcode = codestring;

				currentstring = "";

				i = end;
			} else {
				currentstring += string.charAt(i);
			}

			i += 1;
		}

		if (string.length > 0) sets.push({
			text: currentstring,
			code: if(currentcode.length > 0) currentcode else null
		});

		return sets;
	}
}
