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
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import haxe.Timer;

class SoundEffect {
    private var src : String;
    private var sound : Sound;

    public function new(src:String) {
        this.src = src;
        this.sound = new Sound();
        //this.sound.addEventListener("complete", soundComplete);
        //this.sound.addEventListener("id3", soundId3);
        //this.sound.addEventListener("ioError", soundIoError);
        //this.sound.addEventListener("open", soundOpen);
        //this.sound.addEventListener("progress", soundProgress);
        this.sound.load(new URLRequest(src));
    }

    public function play(offset:Float, volume:Float, pan:Float) {
        var channel : SoundChannel = this.sound.play(offset, 0, new SoundTransform(volume, pan));
        //channel.addEventListener("soundComplete", this.channelComplete);
    }


    // Called when the sound finishes playing to the end (by SoundChannel's 'soundComplete' event)
    private function channelComplete(e) {
        //ExternalInterface.call("console.log", "channelComplete");
        //this.playTimer.stop();
        //this.channel.removeEventListener("soundComplete", this.channelComplete);
        //this.channel.stop();
        //this.channel = null;
        //this.lastPosition = this.sound.length;
        //ExternalInterface.call("HTMLAudioElement.__swfSounds["+this.fallbackId+"].__endedCallback");
    }





    /*
    
    ///////////////////  Event Handlers  ///////////////////
    private function soundComplete(e) {
        ExternalInterface.call("(function() { " +
            "var s = HTMLAudioElement.__swfSounds["+this.fallbackId+"]; " +
            "s.__duration = " + (this.sound.length/1000) + "; " +
            "s.__fireMediaEvent('durationchange'); "+
            "s.__fireMediaEvent('progress', "+this.sound.bytesLoaded+", "+this.sound.bytesTotal+"); "+
        "})");
        //ExternalInterface.call("HTMLAudioElement.__swfSounds["+this.fallbackId+"].__fireMediaEvent", "progress", this.sound.bytesLoaded, this.sound.bytesTotal);
    }
    
    private function soundId3(e) {
        //ExternalInterface.call("console.log", e);
    }
    
    private function soundIoError(e) {
        this.sound.close();
        ExternalInterface.call("HTMLAudioElement.__swfSounds["+this.fallbackId+"].__errorCallback");
    }
    
    private function soundOpen(e) {
    }
    
    private function soundProgress(e) {
        var now : Float = Date.now().getTime();
        if (!this.metadataSent) {
            var percent : Float = this.sound.bytesLoaded / this.sound.bytesTotal;
            // Set the duration to a calculated estimate while its loading
            this.duration = this.sound.length * this.sound.bytesLoaded / this.sound.bytesTotal / 1000;
            if (this.duration > 0 && percent > .05) {
                ExternalInterface.call("HTMLAudioElement.__swfSounds["+this.fallbackId+"].__metadataCallback", this.duration);
                this.metadataSent = true;
            }
        }
        if (this.sound.bytesLoaded > 0 && now - this.lastProgressEvent > 350) {            
            this.lastProgressEvent = now;
            ExternalInterface.call("HTMLAudioElement.__swfSounds["+this.fallbackId+"].__fireMediaEvent", "progress", this.sound.bytesLoaded, this.sound.bytesTotal);
        }
    }
    */






    public static var sounds:Array<SoundEffect> = new Array();
    
    // ExternalInterface functions available to JavaScript
    public static function IS_SOUNDEFFECT_JS() {
        return true;
    }

    public static function Load(src:String) {
        try {
            ExternalInterface.call("console.log", src);
            var sound:SoundEffect = new SoundEffect(src);
            sounds.push(sound);
            return sounds.length-1;
        } catch (e : Dynamic) {
            ExternalInterface.call("console.log", e);
            return 0;
        }
    }
    
    public static function Play(index:Int, offset:Float, volume:Float, pan:Float) {
        var sound:SoundEffect = sounds[index];
        sound.play(offset, volume, pan);
    }

    public static function main() {
        ExternalInterface.addCallback("IS_SOUNDEFFECT_JS", IS_SOUNDEFFECT_JS);
        ExternalInterface.addCallback("_load", Load);
        ExternalInterface.addCallback("_play", Play);
        ExternalInterface.call([
        "(function(){",
            "var f = function(tag){",
                "var elems = document.getElementsByTagName(tag);",
                "for (var i=0; i<elems.length; i++) if (elems[i].IS_SOUNDEFFECT_JS) return elems[i];",
            "};",
            "SoundEffect._swf = f('embed') || f('object');",
        "})" ].join(''));
        ExternalInterface.call("SoundEffect._swfReady");            
    }
}

