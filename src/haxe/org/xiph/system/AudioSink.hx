package org.xiph.system;

//import org.xiph.system.Bytes;

import flash.Vector;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.events.SampleDataEvent;


class AudioSink {
    var buffer : Bytes;
    public var available : Int;
    var triggered : Bool;
    var trigger : Int;
    var fill : Bool;
    var size : Int;

    var s : Sound;
    var sch : SoundChannel;

    public function new(chunk_size : Int, fill = true, trigger = 0) {
        size = chunk_size;
        this.fill = fill;
        this.trigger = trigger;
        if (this.trigger == -1)
            this.trigger = size;
        triggered = false;

        buffer = new Bytes();
        available = 0;
        s = new Sound();
        sch = null;
    }

    public function play() : Void {
        //trace("adding callback");
        s.addEventListener("sampleData", _data_cb);
        //trace("playing");
        sch = s.play();
        //trace(sch);
    }

    public function stop() : Void {
        if (sch != null) {
            sch.stop();
        }
    }

    function _data_cb(event : SampleDataEvent) : Void {
        var i : Int;
        var to_write : Int = available > size ? size : available;
        var missing = to_write < size ? size - to_write : 0;
        var bytes : Int = to_write * 8;
        if (to_write > 0) {
            event.data.writeBytes(buffer, 0, bytes);
            available -= to_write;
            System.bytescopy(buffer, bytes, buffer, 0, available * 8);
        }
        i = 0;
        if (missing > 0 && missing != size && fill) {
            //trace("samples data underrun: " + missing);
            while (i < missing) {
                untyped {
                event.data.writeFloat(0.0);
                event.data.writeFloat(0.0);
                };
                i++;
            }
        } else if (missing > 0) {
            //trace("not enough data, stopping");
            //stop();
        }
    }

    public function write(pcm : Array<Vector<Float>>, index : Vector<Int>,
                          samples : Int) : Void {
        var i : Int;
        var end : Int;
        buffer.position = available * 8; // 2 ch * 4 bytes per sample (float)
        if (pcm.length == 1) {
            // one channel
            var c = pcm[0];
            var s : Float;
            i = index[0];
            end = i + samples;
            while (i < samples) {
                s = c[i++];
                buffer.writeFloat(s);
                buffer.writeFloat(s);
            }
        } else if (pcm.length == 2) {
            // two channels
            var c1 = pcm[0];
            var c2 = pcm[1];
            i = index[0];
            var i2 = index[1];
            end = i + samples;
            while (i < end) {
                buffer.writeFloat(c1[i]);
                buffer.writeFloat(c2[i2++]);
                i++;
            }
        } else {
            throw "-EWRONGNUMCHANNELS";
        }

        available += samples;
        if (!triggered && trigger > 0 && available > trigger) {
            triggered = true;
            play();
        }
    }
}
