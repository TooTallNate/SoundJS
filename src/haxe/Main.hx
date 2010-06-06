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
import flash.external.ExternalInterface;
import flash.events.Event;
import flash.media.SoundTransform;
import flash.net.URLRequest;

class Main {

    public static var sounds :  Array<Sound> = new Array();
    public static var channels : Array<SoundChannel> = new Array();
    
    // ExternalInterface functions available to JavaScript
    public static function IS_SOUNDEFFECT_JS() {
        return true;
    }

    public static function Load(src:String) {
        var soundId : Int = sounds.length;
        var sound : Sound = Sound.getInstance(src);
        if (sound != null) {
            sound.addEventListener(SoundEvent.LOADED, function(e) {
                ExternalInterface.call("Sound["+soundId+"].loaded", e);
            });
            sound.addEventListener(SoundEvent.ERROR, function(e) {
                ExternalInterface.call("Sound["+soundId+"].error", e);
            });
            sound.addEventListener(SoundEvent.OPEN, function(e) {
                ExternalInterface.call("Sound["+soundId+"].open", e);
            });
            sound.addEventListener(SoundEvent.PROGRESS, function(e) {
                ExternalInterface.call("Sound["+soundId+"].progress", e);
            });
        } else {
            haxe.Timer.delay(function() {
                ExternalInterface.call("Sound["+soundId+"].error", new SoundEvent(SoundEvent.ERROR, "Unsupported File Extension"));                
            }, 100);
        }
        sounds.push(sound);
        return soundId;
    }
    
    public static function Play(index:Int, offset:Float, volume:Float, pan:Float) {
        var channelId : Int = channels.length;
        var sound : Sound = sounds[index];
        var channel : SoundChannel = sound.play(offset, volume, pan);
        channel.addEventListener(Event.SOUND_COMPLETE, function(e) {
            ExternalInterface.call("SoundChannel["+channelId+"].done");
            channels[channelId] = null;
        });
        channels.push(channel);
        return channelId;
    }
    
    public static function Stop(index:Int) {
        var sound:SoundChannel = channels[index];
        sound.stop();        
    }
    
    public static function GetPosition(index:Int) {
        var sound:SoundChannel = channels[index];
        return sound.getPosition();        
    }

    public static function GetPan(index:Int) {
        var sound:SoundChannel = channels[index];
        return sound.getPan();
    }

    public static function GetVolume(index:Int) {
        var sound:SoundChannel = channels[index];
        return sound.getVolume();
    }

    public static function SetPan(index:Int, pan:Float) {
        var sound:SoundChannel = channels[index];
        sound.setPan(pan);
    }

    public static function SetVolume(index:Int, volume:Float) {
        var sound:SoundChannel = channels[index];
        sound.setVolume(volume);
    }
    
    public static function GetLength(index:Int) {
        var sound:Sound = sounds[index];
        return sound.getLength();
    }
    

    public static function main() {
        // Needed for OGG Vorbis playback support.
        // TODO: find a better way to initialize these static bits?
        org.xiph.fogg.Buffer._s_init();
        org.xiph.fvorbis.FuncFloor._s_init();
        org.xiph.fvorbis.FuncMapping._s_init();
        org.xiph.fvorbis.FuncTime._s_init();
        org.xiph.fvorbis.FuncResidue._s_init();


        flash.system.Security.allowDomain("*");

        ExternalInterface.addCallback("IS_SOUNDEFFECT_JS", IS_SOUNDEFFECT_JS);
        ExternalInterface.addCallback("_load", Load);
        ExternalInterface.addCallback("_play", Play);
        ExternalInterface.addCallback("_stop", Stop);
        ExternalInterface.addCallback("_getPos", GetPosition);
        ExternalInterface.addCallback("_getPan", GetPan);
        ExternalInterface.addCallback("_getVol", GetVolume);
        ExternalInterface.addCallback("_setPan", SetPan);
        ExternalInterface.addCallback("_setVol", SetVolume);
        ExternalInterface.addCallback("_getLen", GetLength);
        ExternalInterface.call([
        "(function(){",
            "var f = function(tag){",
                "var elems = document.getElementsByTagName(tag);",
                "for (var i=0; i<elems.length; i++) if (elems[i].IS_SOUNDEFFECT_JS) return elems[i];",
            "};",
            "Sound._swf = f('embed') || f('object');",
        "})" ].join(''));
        ExternalInterface.call("Sound._swfReady");            
    }
}
