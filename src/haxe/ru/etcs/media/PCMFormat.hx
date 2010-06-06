package ru.etcs.media;

extern class PCMFormat {
	var bitsPerSample : UInt;
	var blockAlign : UInt;
	var byteRate : UInt;
	var channels : UInt;
	var fullDataLength : UInt;
	var sampleRate : UInt;
	var waveDataLength : UInt;
	function new() : Void;
	function analyzeHeader(p0 : flash.utils.ByteArray) : Void;
	static var HEADER_SIZE : UInt;
}
