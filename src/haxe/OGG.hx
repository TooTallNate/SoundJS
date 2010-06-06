/**
 * Copyright (c) 2010 Nathan Rajlich
 * 
 * This file is part of Sound.js.
 * 
 * Sound.js is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version.
 * 
 * Sound.js is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with Sound.js.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * The "OGG" class implements OGG Vorbis playback support, through
 * the use of Flash 10's enhanced Sound API. More specifically, the
 * ability to dynamically write audio data, needed for the Vorbis
 * decoder to communicate with.
 *
 * The class was created using the existing implementation found here:
 *     https://launchpad.net/fogg
 *  
 *  Revision 58 of the FOgg repo hosted at the link above was used as a base.
 */
import flash.Vector;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import org.xiph.foggy.Demuxer;
import org.xiph.system.Bytes;

class OGG extends Sound {
    private var _slc : SoundLoaderContext;
    private var _req : URLRequest;
    private var _ul : URLStream;
    private var data : ByteArray;

    public function new(url:URLRequest) {
        super();
        _req = url;

        _ul = new URLStream();
        _ul.addEventListener(Event.OPEN, onOpen);
        _ul.addEventListener(ProgressEvent.PROGRESS, onProgress);
        _ul.addEventListener(Event.COMPLETE, onLoaded);
        _ul.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _ul.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurity);
        try {
            _ul.load(_req);
        } catch (e:Dynamic) {
            var t = this;
            haxe.Timer.delay(function() {
                t.onSecurity(e);
            }, 0);
        }
    }

    public override function play(offset:Float, volume:Float, pan:Float) : SoundChannel {
        return new OGGChannel(this.data, offset, volume, pan);
    }
    
    public override function getLength() : Float {
        return 0;
    }
    
    // URLStream callbacks
    private function onOpen(e) {
        this.data = new ByteArray();
        dispatchEvent(new SoundEvent(SoundEvent.OPEN));
    }
    private function onProgress(e) {
        var newBytes : Int = e.bytesLoaded - this.data.length;
        if (newBytes > 0) {
            _ul.readBytes(this.data, this.data.length, newBytes);
        
            dispatchEvent(new SoundEvent(SoundEvent.PROGRESS));
        }
    }
    private function onLoaded(e) {
        dispatchEvent(new SoundEvent(SoundEvent.LOADED));
    }
    private function onError(e) {
        dispatchEvent(new SoundEvent(SoundEvent.ERROR));
    }
    private function onSecurity(e) {
        dispatchEvent(new SoundEvent(SoundEvent.ERROR));
    }
}
