/**
 * The "Sound" class directly reflects our Sound JavaScript Class. It is
 * meant to be abstract, but I don't know if HaXe is capable of that.
 */
import flash.events.EventDispatcher;
import flash.net.URLRequest;
 
class Sound extends EventDispatcher {
    public function getLength() : Float {
        return 0;
    }
    public function play(offset:Float, volume:Float, pan:Float) : SoundChannel {
        return null;
    }
    
    public static function getInstance(src:String) : Sound {
        var url : URLRequest = new URLRequest(src);
        return new MP3(url);
    }
}
