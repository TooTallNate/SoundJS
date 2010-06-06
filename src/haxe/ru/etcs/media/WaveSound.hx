package ru.etcs.media;

extern class WaveSound extends flash.events.EventDispatcher {
	var audioData(default,null) : flash.utils.ByteArray;
	var audioFormat(default,null) : PCMFormat;
	var bytesLoaded(default,null) : UInt;
	var bytesTotal(default,null) : UInt;
	var length(default,null) : Float;
	var url(default,null) : String;
	function new(?p0 : flash.net.URLRequest) : Void;
	function close() : Void;
	function load(p0 : flash.net.URLRequest) : Void;
	function play(?p0 : Float, ?p1 : UInt, ?p2 : flash.media.SoundTransform) : flash.media.SoundChannel;
}
