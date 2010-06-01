package org.xiph.system;

import flash.utils.IDataInput;

import org.xiph.foggy.Demuxer;

class TheRightWayDemuxer extends Demuxer {
    public var eos(default, null) : Bool;

    public function new() {
        eos = false;
        super();
    }

    override public function read(data : IDataInput, len : Int,
                                  pos : Int = -1) : Int {
        //flash.external.ExternalInterface.call("console.log", 'TRWD::read(' + len + ')');
        //@ trace('TRWD::read(' + len + ')');
        var buffer : Bytes;
        var index : Int = oy.buffer(len);
        buffer = oy.data;

        // ignore pos, read from the data's current position
        data.readBytes(buffer, index, len);
        oy.wrote(len);

        if (len == 0)
            eos = true;

        return len;
    }

    public function process(pages : Int) : Int {
        var processed : Int = 0;
        var ret : Int;
        var buffer : Bytes = oy.data;

        if (buffer == null)
            return processed;

        while (processed < pages) {
            if ((ret = oy.pageout(og)) != 1) {
                if (ret == 0 && processed == 0 && eos) {
                    return Demuxer.EOF;
                } else if (buffer.length < 16384 || ret == 0) {
                    return processed;
                } else {
                    return Demuxer.ENOTOGG;
                }
            }

            _process_page(og);
            // TODO: check for returns from _process_page()
            processed += 1;
        }

        return processed;
    }
}
