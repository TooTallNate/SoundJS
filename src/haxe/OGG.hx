/**
 * The "OGG" class implements OGG Vorbis playback support, through
 * the use of Flash 10's enhanced Sound API. More specifically, the
 * ability to dynamically write audio data, needed for the Vorbis
 * decoder to communicate with.
 *
 * The class was created using the existing implementation found here:
 *     https://launchpad.net/fogg
 */
import flash.Vector;

import flash.events.Event;
import flash.events.ProgressEvent;

import flash.external.ExternalInterface;

import flash.media.SoundLoaderContext;

import flash.net.URLRequest;
import flash.net.URLStream;

import flash.utils.ByteArray;

import org.xiph.foggy.Demuxer;

import org.xiph.system.Bytes;

class OGG extends Sound {
    var _slc : SoundLoaderContext;
    var _req : URLRequest;
    var _ul : URLStream;

    var _c1 : Int;
    
    private var data : ByteArray;

    public function new(url:URLRequest) {
        super();
        _ul = new URLStream();

        _ul.addEventListener(flash.events.Event.OPEN, onOpen);
        _ul.addEventListener(flash.events.ProgressEvent.PROGRESS, onProgress);
        _ul.addEventListener(flash.events.Event.COMPLETE, onLoaded);
        _ul.addEventListener(flash.events.IOErrorEvent.IO_ERROR, onError);
        _ul.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, onSecurity);
                             
        _req = url;
        
        _ul.load(_req);
        
    }

    public override function play(offset:Float, volume:Float, pan:Float) : SoundChannel {
        return new OGGChannel(this.data, offset, volume, pan);
    }
    
    public override function getLength() : Float {
        return 0;
    }
    
    // URLStream callbacks
    private function onOpen(e) {
        //ExternalInterface.call("console.log", '_on_open;');
        this.data = new ByteArray();
        dispatchEvent(new SoundEvent(SoundEvent.OPEN));
    }
    private function onProgress(e) {
        dispatchEvent(new SoundEvent(SoundEvent.PROGRESS));
    }
    private function onLoaded(e) {
        //ExternalInterface.call("console.log", '_on_complete: ' + _ul.bytesAvailable);
        _ul.readBytes(this.data);
        //ExternalInterface.call("console.log", "data loaded: " + this.data.length + " bytes");
        dispatchEvent(new SoundEvent(SoundEvent.LOADED));
    }
    private function onError(e) {
        ExternalInterface.call("console.log", e);
        dispatchEvent(new SoundEvent(SoundEvent.ERROR));
    }
    private function onSecurity(e) {
        ExternalInterface.call("console.log", e);
        dispatchEvent(new SoundEvent(SoundEvent.ERROR));
    }
}
