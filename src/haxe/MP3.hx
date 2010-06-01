/**
 * The "MP3" class wraps MP3 playback support around Flash's native
 * flash.media.Sound class. MP3 is the only natively supported filetype
 * able to be stream from a server with this class.
 */
import flash.external.ExternalInterface;
import flash.events.Event;
import flash.net.URLRequest;

class MP3 extends Sound {
    private var url : URLRequest;
    private var sound : flash.media.Sound;

    public function new(url:URLRequest) {
        super();
        this.url = url;
        this.sound = new flash.media.Sound(url);
        this.sound.addEventListener("complete", soundComplete);
        this.sound.addEventListener("ioError", soundIoError);
        this.sound.addEventListener("open", soundOpen);
        this.sound.addEventListener("progress", soundProgress);
    }

    public override function play(offset:Float, volume:Float, pan:Float) : SoundChannel {
        return new MP3Channel(this.sound, offset, volume, pan);
    }
    
    public override function getLength() {
        return this.sound.length;
    }
    
    private function soundComplete(e) {
        dispatchEvent(new SoundEvent(SoundEvent.LOADED));
    }

    private function soundIoError(e) {
        dispatchEvent(new SoundEvent(SoundEvent.ERROR));
    }

    private function soundOpen(e) {
        dispatchEvent(new SoundEvent(SoundEvent.OPEN));
    }

    private function soundProgress(e) {
        dispatchEvent(new SoundEvent(SoundEvent.PROGRESS));
    }
}
