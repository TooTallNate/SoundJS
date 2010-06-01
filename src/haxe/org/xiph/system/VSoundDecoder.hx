package org.xiph.system;

import flash.Vector;

import org.xiph.fogg.Packet;

import org.xiph.foggy.Demuxer;

import org.xiph.fvorbis.Info;
import org.xiph.fvorbis.Comment;
import org.xiph.fvorbis.DspState;
import org.xiph.fvorbis.Block;

class VSoundDecoder {
    var _packets : Int;
    var vi : Info;
    var vc : Comment;
    var vd : DspState;
    var vb : Block;

    var _pcm : Array<Array<Vector<Float>>>;
    var _index : Vector<Int>;

    public var dmx(default, null) : TheRightWayDemuxer;

    public var decoded_cb(null, default) :
        Array<Vector<Float>> -> Vector<Int> -> Int -> Void;

    function _proc_packet_head(p : Packet, sn : Int) : DemuxerStatus {
        vi.init();
        vc.init();
        if (vi.synthesis_headerin(vc, p) < 0) {
            // not vorbis - clean up and ignore
            vc.clear();
            vi.clear();
        } else {
            // vorbis - detach this cb and attach the main decoding cb
            // to the specific serialno
            dmx.remove_packet_cb(-1);
            dmx.set_packet_cb(sn, _proc_packet);
        }

        _packets++;
        return dmx_ok;
    }

    function _proc_packet(p : Packet, sn : Int) : DemuxerStatus {
        var samples : Int;

        switch(_packets) {
        case 0:
            /*
            vi.init();
            vc.init();
            if (vi.synthesis_headerin(vc, p) < 0) {
                return dmx_ok;
            } else {
                dmx.set_packet_cb(sn, _proc_packet);
                dmx.remove_packet_cb(-1);
            }
            */
        case 1:
            vi.synthesis_headerin(vc, p);

        case 2:
            vi.synthesis_headerin(vc, p);

            {
                var ptr : Array<Bytes> = vc.user_comments;
                var j : Int = 0;
                ////trace("");
                while (j < ptr.length) {
                    if (ptr[j] == null) {
                        break;
                    };
                    //trace(System.fromBytes(ptr[j], 0, ptr[j].length - 1));
                    j++;
                };

                //trace("Bitstream is " + vi.channels + " channel, " +vi.rate + "Hz");
                //trace(("Encoded by: " + System.fromBytes(vc.vendor, 0, vc.vendor.length - 1)) + "\n");
            }

            vd.synthesis_init(vi);
            vb.init(vd);

            _pcm = [null];
            _index = new Vector(vi.channels, true);

        default:
            if (vb.synthesis(p) == 0) {
                vd.synthesis_blockin(vb);
            }

            while ((samples = vd.synthesis_pcmout(_pcm, _index)) > 0) {
                //asink.write(_pcm[0], _index, samples);
                if (decoded_cb != null)
                    decoded_cb(_pcm[0], _index, samples);
                vd.synthesis_read(samples);
            }
        }

        _packets++;

        return dmx_ok;
    }

    public function new() {
        // ???
        dmx = new TheRightWayDemuxer();

        vi = new Info();
        vc = new Comment();
        vd = new DspState();
        vb = new Block(vd);

        _packets = 0;

        dmx.set_packet_cb(-1, _proc_packet_head);
        // ...
    }
}
