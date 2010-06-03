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
import flash.events.Event;
import flash.media.SoundTransform;

class MP3Channel extends SoundChannel {
    private var channel : flash.media.SoundChannel;
    
    public function new(sound : flash.media.Sound, offset:Float, volume:Float, pan:Float) {
        super();
        this.channel = sound.play(offset, 0, new SoundTransform(volume, pan));
        this.channel.addEventListener(Event.SOUND_COMPLETE, channelComplete);
    }
    
    public override function stop() : Void {
        this.channel.removeEventListener(Event.SOUND_COMPLETE, channelComplete);
        this.channel.stop();
    }

    public override function getPosition() : Float {
        return this.channel.position;
    }
    
    public override function getVolume() : Float {
        return this.channel.soundTransform.volume;
    }
    
    public override function getPan() : Float {
        return this.channel.soundTransform.pan;
    }
    
    public override function setVolume(volume : Float) : Void {
        var t : SoundTransform = this.channel.soundTransform;
        t.volume = volume;
        this.channel.soundTransform = t;
    }
    
    public override function setPan(pan : Float) : Void {
        var t : SoundTransform = this.channel.soundTransform;
        t.pan = pan;
        this.channel.soundTransform = t;        
    }
    
    private function channelComplete(e) {
        dispatchEvent(new SoundEvent(Event.SOUND_COMPLETE));
    }
}
