package discord.log;

//call Log.init somewhere

import haxe.Constraints.Function;
import haxe.PosInfos;

import discord.log.ansi.Paint.*;
import discord.log.ansi.colors.Color;

using StringTools;

class LogLevel {
    public static var TRACE = 0;
    public static var ERROR = 1;
    public static var WARN = 2;
    public static var INFO = 3;
    public static var DEBUG = 4;
    public static var TEST = 5;
}

/**
 * This class *originally* is from
 * https://github.com/CobaltBar/FNF-Horizon-Engine/blob/main/source/horizon/util/Log.hx
 * 
 * - Heavily modified for `hxcord`.
 * 
 * https://gist.github.com/martinwells/5980517
 * https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
 */
class Log
{
	static var ogTrace:Function;
	static var log:Array<String> = [];

    /**
     * The maximum message level allowed to be sent to the console.
     * 
     * A message level of `WARN` (2) will not send `INFO`, `DEBUG` or `TEST` 
     * to the console, **but will** send `WARN`, `ERROR`, and `TRACE`.
     */
    public static var LEVEL:Int = LogLevel.INFO;

	public static function init(?level:Null<Int>):Void
	{
		ogTrace = haxe.Log.trace;
		haxe.Log.trace = hxTrace;

        if (level != null) LEVEL = level;
	}

	static function hxTrace(value:Dynamic, ?pos:PosInfos):Void print(value, 'TRACE', pos); 
	public static function error(value:Dynamic, ?pos:PosInfos):Void print(value, 'ERROR', pos);
	public static function warn(value:Dynamic, ?pos:PosInfos):Void print(value, 'WARN', pos);
	public static function info(value:Dynamic, ?pos:PosInfos):Void print(value, 'INFO', pos);
    public static function debug(value:Dynamic, ?pos:PosInfos):Void print(value, 'DEBUG', pos);
    public static function test(value:Dynamic, ?pos:PosInfos):Void print(value, 'TEST', pos);

	@:noCompletion public static inline function print(value:Dynamic, level:String, ?pos:PosInfos):Void
	{
		var msg = '${bold()}${background(Blue)}${color(White)} ';
        msg += '${DateTools.format(Date.now(), '%H:%M:%S')} ${reset()} ';

        var bgColor:Color = Green;
        var fgColor:Color = White;
        var llToCompare:Int = LogLevel.TRACE;

        switch (level) {
            case 'TRACE':
                bgColor = Magenta;
            case 'ERROR':
                llToCompare = LogLevel.ERROR;
                bgColor = Red;
                fgColor = Black;
            case 'WARN':
                llToCompare = LogLevel.WARN;
                bgColor = Yellow;
                fgColor = White;
            case 'INFO':
                llToCompare = LogLevel.INFO;
                bgColor = Cyan;
                fgColor = White;
            case 'DEBUG':
                llToCompare = LogLevel.DEBUG;
                bgColor = White;
                fgColor = Black;
            case 'TEST':
                llToCompare = LogLevel.TEST;
                bgColor = Blue;
                fgColor = White;
        }

        if (llToCompare > LEVEL) return;

        msg += '${background(bgColor)} ${color(fgColor)}${level.rpad(' ', 5)} ${reset()} ';
        msg += '${background(Green)} ${color(Black)}${italic()}${pos.fileName}:${pos.lineNumber} ${reset()}';

		Sys.println('${msg.rpad(' ', 45)}: $value${reset()}');
		// log.push('[${DateTools.format(Date.now(), '%H:%M:%S')} ${pos.fileName.replace('source/', '').replace('horizon/', '')}:${pos.lineNumber}] $level: $value');
	}
}