package discord.utils;

import haxe.io.BytesOutput;

class MultipartUtils {
    public static function boundary(output:BytesOutput) {
        output.writeString('--hxcordboundary');
    }
    public static function newline(output:BytesOutput) {
        output.writeString('\n');
    }
    public static function add(output:BytesOutput, s:String) {
        output.writeString(s);
    }
    public static function end(output:BytesOutput) {
        output.writeString('--hxcordboundary--');
    }
}