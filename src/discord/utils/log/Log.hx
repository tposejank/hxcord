package discord.utils.log;

//call Log.init somewhere

import haxe.Constraints.Function;
import haxe.PosInfos;

import discord.utils.log.ansi.Paint.*;
import discord.utils.log.ansi.colors.Color;

using StringTools;

/**
 * This class *originally* is from
 * https://github.com/CobaltBar/FNF-Horizon-Engine/blob/main/source/horizon/util/Log.hx
 * 
 * - Heavily modified for `discord.hx`.
 * 
 * https://gist.github.com/martinwells/5980517
 * https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
 */
class Log
{
	static var ogTrace:Function;
	static var log:Array<String> = [];

	public static function init():Void
	{
		ogTrace = haxe.Log.trace;
		haxe.Log.trace = hxTrace;

		info('Now running log');
	}

	static function hxTrace(value:Dynamic, ?pos:PosInfos):Void print(value, 'TRACE', pos); 
	public static function error(value:Dynamic, ?pos:PosInfos):Void print(value, 'ERROR', pos);
	public static function warn(value:Dynamic, ?pos:PosInfos):Void print(value, 'WARN', pos);
	public static function info(value:Dynamic, ?pos:PosInfos):Void print(value, 'INFO', pos);

	@:noCompletion public static inline function print(value:Dynamic, level:String, ?pos:PosInfos):Void
	{
		var msg = '${bold()}${background(Blue)}${color(White)} ';
        msg += '${DateTools.format(Date.now(), '%H:%M:%S')} ${reset()} ';

        var bgColor:Color = Green;
        var fgColor:Color = White;

        switch (level) {
            case 'TRACE':
                bgColor = Magenta;
            case 'ERROR':
                bgColor = Red;
                fgColor = Black;
            case 'WARN':
                bgColor = Yellow;
                fgColor = White;
            case 'INFO':
                bgColor = Cyan;
                fgColor = White;
        }

        msg += '${background(bgColor)} ${color(fgColor)}${level.rpad(' ', 5)} ${reset()} ';
        msg += '${background(Green)} ${color(Black)}${italic()}${pos.fileName}:${pos.lineNumber} ${reset()}';

		Sys.println('${msg.rpad(' ', 45)}: $value${reset()}');
		// log.push('[${DateTools.format(Date.now(), '%H:%M:%S')} ${pos.fileName.replace('source/', '').replace('horizon/', '')}:${pos.lineNumber}] $level: $value');
	}
}