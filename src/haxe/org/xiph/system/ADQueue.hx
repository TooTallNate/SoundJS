package org.xiph.system;

import flash.Vector;

class ADQueue {
    public var over_min_cb(null, default) : Void -> Void;
    public var over_max_cb(null, default) : Void -> Void;
    public var under_max_cb(null, default) : Void -> Void;

    public var min(get_min, set_min) : Int;
    public var max(get_max, set_max) : Int;

    var _min : Int;
    var _max : Int;

    /* data ready to be written to a Sound object:
       2 ch * 4 bytes (float) per sample */
    /* TODO: make it a ring buffer */
    var _buf : Bytes;
    var _read : Int;
    public var _samples : Int;

    public function new(min : Int = 44100, ?max : Int) {
        _min = min;
        if (max == null)
            max = 2 * _min;
        _max = max;

        _buf = new Bytes();
        _read = 0;
        _samples = 0;
    }

    function get_min() : Int {
        return _min;
    }

    function get_max() : Int {
        return _max;
    }

    function set_min(v : Int) : Int {
        if (v == _min)
            return _min;

        var old = _min;
        _min = v;

        if (_min < old) {
            if (over_min_cb != null && _samples < old && _samples >= _min) {
                //@ trace('TRIGGERED: over_min_cb');
                //over_min_cb();
                haxe.Timer.delay(over_min_cb, 0);
            }
        }
        /* no need, we don't notify about that case...
        else if (_min > old)
            // ...
        */

        return _min;
    }

    function set_max(v : Int) : Int {
        if (v == _max)
            return _max;

        var old = _max;
        _max = v;

        if (_max < old) {
            if (over_max_cb != null && _samples < old && _samples >= _max) {
                //@ trace('TRIGGERED: over_max_cb');
                over_max_cb();
            }
        } else if (_max > old) {
            if (under_max_cb != null && _samples >= old && _samples < _max) {
                //@ trace('TRIGGERED: under_max_cb');
                under_max_cb();
            }
        }

        return _max;
    }

    public function write(pcm : Array<Vector<Float>>, index : Vector<Int>,
                          samples : Int) : Void
    {
        //trace('write: ' + samples + ', (' + _samples + ', ' + _read + ')');

        var i : Int;
        var end : Int;

        _buf.position = _samples * 8;
        if (pcm.length == 1) {
            // single channel source data
            var c = pcm[0];
            var s : Float;
            i = index[0];
            end = i + samples;
            while (i < end) {
                s = c[i++];
                _buf.writeFloat(s);
                _buf.writeFloat(s);
            }
        } else if (pcm.length == 2) {
            // two channels
            var c1 = pcm[0];
            var c2 = pcm[1];
            i = index[0];
            var i2 = index[1];
            end = i + samples;
            while (i < end) {
                _buf.writeFloat(c1[i]);
                _buf.writeFloat(c2[i2++]);
                i++;
            }
        } else {
            throw "-EWRONGNUMCHANNELS";
        }

        var old_samples : Int = _samples;
        _samples += samples;

        if (over_max_cb != null && old_samples < _max && _samples >= _max) {
            //@ trace('TRIGGERED: over_max_cb');
            over_max_cb();
        }

        if (over_min_cb != null && old_samples < _min && _samples >= _min) {
            //@ trace('TRIGGERED: over_min_cb');
            //over_min_cb();
            haxe.Timer.delay(over_min_cb, 0);
        }
    }

    public function read(dst : Bytes, samples : Int) : Bool {
        //trace('read: ' + samples + ', (' + _samples + ', ' +
        //      _read + ')');

        var avail : Int = _samples - _read;

        if (avail < samples)
            return false;

        dst.writeBytes(_buf, _read * 8, samples * 8);
        _read += samples;

        haxe.Timer.delay(_sync, 0);

        return true;
    }

    function _sync() : Void {
        if (_read == 0)
            return;

        //@ trace('_sync: (' + _samples + ', ' + _read + ')');

        var new_samples : Int = _samples - _read;
        if (new_samples != 0)
            System.bytescopy(_buf, _read * 8, _buf, 0, new_samples * 8);
        _read = 0;
        var old_samples : Int = _samples;
        _samples = new_samples;

        if (under_max_cb != null && old_samples >= _max && new_samples < _max) {
            //@ trace('TRIGGERED: under_max_cb');
            under_max_cb();
        }

        // we don't notify if the level falls under the set minimum
        if (old_samples >= _min && new_samples < _min) {
            //trace('UNDER MIN');
        }
    }
}
