package discord;

import haxe.io.Bytes;
import haxe.crypto.Base64;

using StringTools;

class Utils {
    public static function _bytesStartsWith(data:Bytes, prefix:Bytes):Bool {
        if (data.length < prefix.length) return false;
        return data.sub(0, prefix.length).compare(prefix) == 0;
    }

    public static function getMimeTypeForImage(data:Bytes):String {
        if (_bytesStartsWith(data, Bytes.ofString("\u0089\u0050\u004E\u0047\u000D\u000A\u001A\u000A"))) {
            return "image/png";
        } else if (data.sub(0, 3).compare(Bytes.ofString("\u00ff\u00d8\u00ff")) == 0 || 
                  (data.length > 10 && (data.sub(6, 4).toString() == "JFIF" || data.sub(6, 4).toString() == "Exif"))) {
            return "image/jpeg";
        } else if (_bytesStartsWith(data, Bytes.ofString("\u0047\u0049\u0046\u0038\u0037\u0061")) || 
                    _bytesStartsWith(data, Bytes.ofString("\u0047\u0049\u0046\u0038\u0039\u0061"))) {
            return "image/gif";
        } else if (_bytesStartsWith(data, Bytes.ofString("RIFF")) && data.length > 12 && data.sub(8, 4).toString() == "WEBP") {
            return "image/webp";
        } else {
            throw 'Unsupported image type given';
        }
    }

    public static function bytesToBase64Data(data:Bytes):String {
        var mime = getMimeTypeForImage(data);
        var b64 = Base64.encode(data); // Already returns an ASCII-safe string
        return 'data:' + mime + ';base64,' + b64;
    }
}