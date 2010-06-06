/**
* PCMFormat by Denis Kolyako. May 28, 2007
* Visit http://dev.etcs.ru for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
* 
*
* Please contact etc[at]mail.ru prior to distributing modified versions of this class.
*/
package ru.etcs.media; 

import flash.utils.ByteArray;
	
class PCMFormat  {
	
	/*
	* *********************************************************
	* CLASS PROPERTIES
	* *********************************************************
	*
	*/
	
	
	/*
	* *********************************************************
	* CLASS PROPERTIES
	* *********************************************************
	*
	*/
	public var channels:UInt;
	public var sampleRate:UInt;
	public var byteRate:UInt;
	public var blockAlign:UInt;
	public var bitsPerSample:UInt;
	public var waveDataLength:UInt;
	public var fullDataLength:UInt;
	
	public static var HEADER_SIZE:UInt = 44;
	
	/*
	* *********************************************************
	* CONSTRUCTOR
	* *********************************************************
	*
	*/
	public function new() {
		
	}
	
	/*
	* *********************************************************
	* PUBLIC METHODS
	* *********************************************************
	*
	*/
	public function analyzeHeader(byteArray:ByteArray):Void {
		var typeArray:ByteArray = new ByteArray();
		byteArray.readBytes(typeArray,0,4);
		
		if (typeArray.toString() != 'RIFF') {
			throw "Decode error: incorrect RIFF header";
			return;
		}
		
		fullDataLength = byteArray.readUnsignedInt()+8;
		byteArray.position = 0x10;
		var chunkSize:Float = byteArray.readUnsignedInt();
		
		if (chunkSize != 0x10) {
			throw "Decode error: incorrect chunk size";
			return;
		}
		
		var isPCM:Bool = byteArray.readShort() > 0;
		
		if (!isPCM) {
			throw "Decode error: this file is not PCM wave file";
			return;
		}
		
		channels = byteArray.readShort();
		sampleRate = byteArray.readUnsignedInt();
		
		switch (sampleRate) {
			case 44100:
			case 22050:
			case 11025:
			case 5512:
			default:
			    throw "Decode error: incorrect sample rate";
			return;
		}
		
		byteRate = byteArray.readUnsignedInt();
		blockAlign = byteArray.readShort();
		bitsPerSample = byteArray.readShort();
		byteArray.position += 0x04;
		waveDataLength = byteArray.readUnsignedInt();
		
		if (blockAlign <= 0) {
			blockAlign = cast(channels * bitsPerSample / 8, Int);
		}

		byteArray.position = 0;
	}
}
