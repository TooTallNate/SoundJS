/* The MIT License
 * 
 * Copyright (c) 2010 Nathan Rajlich
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import flash.external.ExternalInterface;
import flash.events.Event;
import flash.media.SoundChannel;
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
        var sound : Sound = new Sound(src, soundId);
        sounds.push(sound);
        return soundId;
    }
    
    public static function Play(index:Int, offset:Float, volume:Float, pan:Float) {
        var channelId : Int = channels.length;
        var sound : SoundEffect = sounds[index];
        var channel : SoundChannel = sound.play(offset, volume, pan, channelId);
        channels.push(channel);
        return channelId;
    }
    
    public static function Stop(index:Int) {
        var sound:SoundChannel = channels[index];
        sound.stop();        
    }
    
    public static function GetPosition(index:Int) {
        var sound:SoundChannel = channels[index];
        return sound.position;        
    }

    public static function GetPan(index:Int) {
        var sound:SoundChannel = channels[index];
        return sound.soundTransform.pan;
    }

    public static function GetVolume(index:Int) {
        var sound:SoundChannel = channels[index];
        return sound.soundTransform.volume;
    }

    public static function SetPan(index:Int, pan:Float) {
        var sound:SoundChannel = channels[index];
        var transform:SoundTransform = sound.soundTransform;
        transform.pan = pan;
        sound.soundTransform = transform;
    }

    public static function SetVolume(index:Int, volume:Float) {
        var sound:SoundChannel = channels[index];
        var transform:SoundTransform = sound.soundTransform;
        transform.volume = volume;
        sound.soundTransform = transform;
    }
    
    public static function GetLength(index:Int) {
        var sound:SoundEffect = sounds[index];
        return sound.getLength();
    }
    

    public static function main() {
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