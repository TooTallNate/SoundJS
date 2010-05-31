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
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;

class Mpeg3 {
    private var src : String;
    private var sound : Sound;
    private var soundId : Int;

    public function new(src:String, soundId:Int) {
        this.src = src;
        this.soundId = soundId;
        this.sound = new Sound(new URLRequest(src));
        this.sound.addEventListener("complete", soundComplete);
        this.sound.addEventListener("ioError", soundIoError);
        this.sound.addEventListener("open", soundOpen);
        this.sound.addEventListener("progress", soundProgress);
        //this.sound.load();
    }

    public function play(offset:Float, volume:Float, pan:Float, channelId:Int) {
        var channel : SoundChannel = this.sound.play(offset, 0, new SoundTransform(volume, pan));
        channel.addEventListener(Event.SOUND_COMPLETE, function(e) {
            ExternalInterface.call("SoundChannel["+channelId+"].done");
            channels[channelId] = null;
        });
        return channel;
    }
    
    public function getLength() {
        return this.sound.length;
    }
    
    private function soundComplete(e) {
        ExternalInterface.call("Sound["+this.soundId+"].loaded", e);
    }

    private function soundIoError(e) {
        ExternalInterface.call("Sound["+this.soundId+"].error", e);
    }

    private function soundOpen(e) {
        ExternalInterface.call("Sound["+this.soundId+"].open", e);
    }

    private function soundProgress(e) {
        ExternalInterface.call("Sound["+this.soundId+"].progress", e);
    }
}
