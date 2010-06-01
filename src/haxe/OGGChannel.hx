import flash.events.Event;
import flash.media.SoundTransform;

import org.xiph.system.AudioSink;

class OGGChannel extends SoundChannel {
    private var sink : AudioSink;
    
    public function new(ogg:OGG, offset:Float, volume:Float, pan:Float) {
        super();
        this.sink = new PAudioSink(8192, true, 132300);//params: data chunk for Sound.onSampleData, doFill with zeroes, trigger play after...
        this.sink.setBufferCB(_doBuffer);
        this.sink.setStatusCB(_doState);
        this.sink.setVolume(volume);
        this.sink.set_cb(88200, _on_data_needed);
    }
    
    public override function stop() : Void {
    }

    public override function getPosition() : Float {
    }
    
    public override function getVolume() : Float {
    }
    
    public override function getPan() : Float {
    }
    
    public override function setVolume(volume : Float) : Void {
    }
    
    public override function setPan(pan : Float) : Void {
    }
}
