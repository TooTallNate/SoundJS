/**
 * The "OGG" class implements OGG Vorbis playback support, through
 * the use of Flash 10's enhanced Sound API. More specifically, the
 * ability to dynamically write audio data, needed for the Vorbis
 * decoder to communicate with.
 *
 * The class was created using the existing implementation found here:
 *     http://code.google.com/p/anoggplayer/
 */
import flash.Vector;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.URLStream;
import flash.utils.ByteArray;

import org.xiph.fogg.SyncState;
import org.xiph.fogg.StreamState;
import org.xiph.fogg.Page;
import org.xiph.fogg.Packet;

import org.xiph.fvorbis.Info;
import org.xiph.fvorbis.Comment;
import org.xiph.fvorbis.DspState;
import org.xiph.fvorbis.Block;

import org.xiph.foggy.Demuxer;
//import org.xiph.foggy.DemuxerStatus;

import org.xiph.system.AudioSink;
import org.xiph.system.Bytes;


class OGG extends Sound {
    private var url : URLRequest;
    private var stream : URLStream;    
    
    var _packets : Int;
    var vi : Info;
    var vc : Comment;
    var vd : DspState;
    var vb : Block;
    var dmx : Demuxer;


    var _pcm : Array<Array<Vector<Float>>>;
    var _index : Vector<Int>;

    var read_pending : Bool;
    var read_started : Bool;
    var read_buff_pending: Bool;
    var buff_write_pos:Int;
    var play_buffered:Bool;//use buffer, don't set to true for streaming?
    var streamDetected:Bool;//do NOT use buffer.


    public function new(url:URLRequest) {
        super();
        this.url = url;
        this.stream = new flash.net.URLStream();
        this.stream.addEventListener(Event.OPEN, onOpen);
        this.stream.addEventListener(ProgressEvent.PROGRESS, onProgress);
        this.stream.addEventListener(Event.COMPLETE, onLoaded);
        this.stream.addEventListener(flash.events.IOErrorEvent.IO_ERROR, onError);
        this.stream.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, onSecurity);

        dmx = new Demuxer();

        vi = new Info();
        vc = new Comment();
        vd = new DspState();
        vb = new Block(vd);

        _packets = 0;

        dmx.set_packet_cb(-1, _proc_packet_head);

        // Start loading the OGG Vorbis resource
        this.stream.load(url);
    }

    public override function play(offset:Float, volume:Float, pan:Float) : SoundChannel {
        return new OGGChannel(this, offset, volume, pan);
    }
    
    public override function getLength() {
        return this.sound.length;
    }
    
    private function onOpen(e) {
        
    }
    private function onOpen(e) {
        
    }
    private function onOpen(e) {
        
    }
    private function onOpen(e) {
        
    }
    private function onOpen(e) {
        
    }
}
