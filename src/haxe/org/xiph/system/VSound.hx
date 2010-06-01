package org.xiph.system;

import flash.Vector;

import flash.events.EventDispatcher;
import flash.events.SampleDataEvent;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.media.SoundTransform;
import flash.media.ID3Info;

import flash.net.URLRequest;
import flash.net.URLStream;

import flash.utils.ByteArray;

import org.xiph.foggy.Demuxer;

import org.xiph.system.Bytes;

class VSound extends flash.events.EventDispatcher {
    public var bytesLoaded(default,null) : UInt;
    public var id3(default,null) : ID3Info;
    public var isBuffering(default,null) : Bool;
    public var length(default,null) : Float;
    public var url(default,null) : String;

    var _slc : SoundLoaderContext;
    var _req : URLRequest;
    var _ul : URLStream;

    var _aq : ADQueue; // audio data queue
    var _dec : VSoundDecoder;

    var _decoding : Bool;
    var _need_data : Bool;
    var _need_samples : Bool;
    var _data_min : Bool;
    var _data_complete : Bool;
    var _read_pending : Bool;

    var _s : Sound;
    var _sch : SoundChannel;

    var _c1 : Int;
    
    private var data : ByteArray;
    private var bytesTotal : Int;

    public static inline var SAMPLERATE : Int = 44100;
    public static inline var DATA_CHUNK_SIZE : Int = 16384;

    public function new(?stream : URLRequest,
                        ?context : SoundLoaderContext) {
        super();

        _aq = null;
        _dec = null;

        _need_data = false;
        _need_samples = false;
        _data_min = false; // FIXME: should be _samples_min !!
        _data_complete = false;
        _read_pending = false;
        _decoding = false;

        _c1 = 0;

        _ul = new URLStream();

        _ul.addEventListener(flash.events.Event.OPEN, _on_open);
        _ul.addEventListener(flash.events.ProgressEvent.PROGRESS, _on_progress);
        _ul.addEventListener(flash.events.Event.COMPLETE, _on_complete);
        _ul.addEventListener(flash.events.IOErrorEvent.IO_ERROR, _on_error);
        _ul.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR,
                             _on_security);


        if (stream != null) {
            load(stream, context);
        } else {
            _slc = context;
            if (_slc == null)
                _slc = new SoundLoaderContext();
        }
    }

    public function close() : Void {
    }

    public function load(stream : URLRequest,
                         ?context : SoundLoaderContext) : Void {
        if (_req != null)
            return;

        if (context != null)
            _slc = context;
        else if (_slc == null)
            _slc = new SoundLoaderContext();
        _req = stream;

        _aq = new ADQueue(Std.int(_slc.bufferTime * SAMPLERATE / 1000));
        _dec = new VSoundDecoder();

        _aq.over_min_cb = _on_over_min;
        _aq.over_max_cb = _on_over_max;
        _aq.under_max_cb = _on_under_max;

        _dec.decoded_cb = _on_decoded;

        _ul.load(_req);
    }

    public function play(?startTime : Float, ?loops : Int,
                         ?sndTransform : SoundTransform) : SoundChannel {
        if (_req == null) {
            throw "-ENOTLOADING";
        }

        if (_decoding)
            return _sch;

        //@ trace('play: ' + _decoding + ', (' + _ul.bytesAvailable + ')');
        if (_decoding)
            return _sch;

        _decoding = true;
        _need_samples = true;

        _s = new Sound();
        _sch = null;
        _s.addEventListener("sampleData", _data_cb);

        haxe.Timer.delay(_decode, 0);

        if (_data_min) {
            _sch = _s.play();
        }

        return _sch;
    }


    // private data / sample handling methods

    function _try_write_data() : Void {
        _read_pending = false;

        if (! _need_data)
            return;

        //trace('_try_write_data: ' + [_need_data, _ul.bytesAvailable,
        //                             _data_complete, _need_samples]);

        var to_read : Int = this.data.length;
        if (to_read >= DATA_CHUNK_SIZE) {
            to_read = DATA_CHUNK_SIZE;
        } else if (_data_complete) {
            if (_dec.dmx.eos) {
                _need_data = false;
                return;
            }
            // pass
        } else {
            // we could reshedule read here, but if we don't have
            // enough data and we're still downloading then
            // on_progress should call us again... right?
            return;
        }

        _need_data = false;

        _dec.dmx.read(this.data, to_read);

        //if (_data_complete)
        //    _dec.dmx.read(_ul, 0);

        if (_need_samples)
            haxe.Timer.delay(_decode, 0);
    }

    function _decode() : Void {
        var result : Int = 0;

        while(_need_samples && (result = _dec.dmx.process(1)) == 1) {
            // pass
        }

        if (result == Demuxer.EOF) {
            // pass
        } else if (result == 0) {
            _need_data = true;
            if (!_read_pending) {
                _read_pending = true;
                haxe.Timer.delay(_try_write_data, 0);
            }
        }
    }

    // URLStream callbacks

    function _on_open(e : flash.events.Event) : Void {
        trace('_on_open;');
        this.data = new ByteArray();
        this.bytesTotal = 0;
    }

    function _on_progress(e : flash.events.ProgressEvent) : Void {
        //trace('_on_progress: ' + _ul.bytesAvailable);
        //_try_write_data();
    }

    function _on_complete(e : flash.events.Event) : Void {
        trace('_on_complete: ' + _ul.bytesAvailable);
        _ul.readBytes(this.data);
        _data_complete = true;
        _try_write_data();
        _ul = null;
    }

    function _on_error(e : flash.events.IOErrorEvent) : Void {
        trace("error occured: " + e);
    }

    function _on_security(e : flash.events.SecurityErrorEvent) : Void {
        trace("security error: " + e);
    }


    // ADQueue callbacks

    function _on_over_min() : Void {
        trace('_on_over_min');
        _data_min = true;
        if (_decoding && _sch == null) {
            _sch = _s.play(); //??
        }
    }

    function _on_over_max() : Void {
        //@ trace('_on_over_max');
        _need_samples = false;
    }

    function _on_under_max() : Void {
        //@ trace('_on_under_max');
        _need_samples = true;
        //_decode();
        haxe.Timer.delay(_decode, 0);
    }


    // VSoundDecoder callback

    function _on_decoded(pcm : Array<Vector<Float>>, index : Vector<Int>,
                         samples : Int) : Void
    {
        _aq.write(pcm, index, samples);
    }


    // Sound data callback

    function _data_cb(event : SampleDataEvent) : Void {
        var avail : Int = _aq._samples;
        var to_write = avail > 8192 ? 8192 : avail; // FIXME: unhardcode!

        if (to_write > 0) {
            _aq.read(event.data, to_write);
            _c1 += to_write;
            //trace('_data_cb: ' + [avail, _c1]);
        } else {
            trace('_data_cb: UNDERRUN');
        }
    }
}
