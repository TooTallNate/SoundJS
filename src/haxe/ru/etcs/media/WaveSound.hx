/**
* WaveSound by Denis Kolyako. May 28, 2007
* Visit http://dev.etcs.ru for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
* 
*
* Please contact etc[at]mail.ru prior to distributing modified versions of this class.
*/
/**
 * The WaveSound class lets you work with sound in an application.
 * The WaveSound class lets you create a new WaveSound object, load and play an external WAV file into that object,
 * close the sound stream, and access data about the sound, such as information about the number of bytes in the stream and PCM parameters.
 * More detailed control of the sound is performed through the sound source — the SoundChannel or Microphone object for the sound —
 * and through the properties in the SoundTransform class that control the output of the sound to the computer's speakers. 
 * This class supports 44100, 22050, 11025, 5512.5 sample rates, 8 or 16 bit, 1 or 2 channels (mono/stereo) RIFF (not RIFX) PCM wav-files without any compression.
 */
package ru.etcs.media;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;
import flash.utils.Endian;

import ru.etcs.events.WaveSoundEvent;

class WaveSound extends EventDispatcher {

	/*
	* *********************************************************
	* CLASS PROPERTIES
	* *********************************************************
	*
	*/
	

	public var audioData(getAudioData, null) : ByteArray; 
	public var audioFormat(getAudioFormat, null) : PCMFormat;
	public var bytesLoaded(getBytesLoaded, null) : UInt;
	public var bytesTotal(getBytesTotal, null) : UInt;
	public var length(getLength, null) : Float;
	public var url(getUrl, null) : String;

	/*
	* *********************************************************
	* CLASS PROPERTIES
	* *********************************************************
	*
	*/
	var byteStream:URLStream;
	var waveHeader:ByteArray;
	var waveData:ByteArray;
	var waveFormat:PCMFormat;
	var sound:Sound;
	var isLoadStarted:Bool;
	var isLoaded:Bool;
	var __bytesLoaded:UInt;
	var __bytesTotal:UInt;
	var __length:Float;
	var __url:String;
	
	/*
	* *********************************************************
	* CONSTRUCTOR
	* *********************************************************
	*
	*/
	/**
	 * Creates a new WaveSound object. If you pass a valid URLRequest object to the WaveSound constructor,
	 * the constructor automatically calls the load() function for the Sound object.
	 * If you do not pass a valid URLRequest object to the WaveSound constructor,
	 * you must call the load() function for the WaveSound object yourself, or the stream will not load. 
	 * 
	 * Once load() is called on a WaveSound object, you can't later load a different sound file into that WaveSound object.
	 * To load a different sound file, create a new WaveSound object.
	 * 
	 * @param stream:URLRequest (default = null) — The URL that points to an external WAV file. 
	 */
	public function new(?stream:URLRequest = null) {
		
		isLoadStarted = false;
		isLoaded = false;
		__bytesLoaded = 0;
		__bytesTotal = 0;
		__length = 0;
		super();
		byteStream = new URLStream();
		byteStream.endian = Endian.LITTLE_ENDIAN;
		byteStream.addEventListener(Event.OPEN,openHandler);
		byteStream.addEventListener(Event.COMPLETE,completeHandler);
		byteStream.addEventListener(HTTPStatusEvent.HTTP_STATUS,httpStatusHandler);
		byteStream.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
		byteStream.addEventListener(ProgressEvent.PROGRESS,progressHandler);
		
		if (stream != null) {
			load(stream);
		}
	}
	
	/*
	* *********************************************************
	* PRIVATE METHODS
	* *********************************************************
	*
	*/
	function completeHandler(event:Event):Void {
		waveHeader = new ByteArray();
		waveHeader.endian = Endian.LITTLE_ENDIAN;
		waveData = new ByteArray();
		waveData.endian = Endian.LITTLE_ENDIAN;
		byteStream.readBytes(waveHeader,0,PCMFormat.HEADER_SIZE);
		waveFormat = new PCMFormat();
		
		try {
			waveFormat.analyzeHeader(waveHeader);
		} catch (e : Dynamic) {
			dispatchEvent(new WaveSoundEvent(WaveSoundEvent.DECODE_ERROR));
			return;
		}
		
		var bytesToRead:UInt = byteStream.bytesAvailable < waveFormat.waveDataLength ? byteStream.bytesAvailable : waveFormat.waveDataLength;
		byteStream.readBytes(waveData,0,bytesToRead);
		var swf:SWFFormat = new SWFFormat(waveFormat);
		var compiledSWF:ByteArray = swf.compileSWF(waveData);
		var loader:Loader = new Loader();
		loader.loadBytes(compiledSWF);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,generateCompleteHandler);
	}
	
	function httpStatusHandler(event:HTTPStatusEvent):Void {
		dispatchEvent(event);	
	}
	
	function ioErrorHandler(event:IOErrorEvent):Void {
		dispatchEvent(event);
	}

	function progressHandler(event:ProgressEvent):Void {
		__bytesLoaded = event.bytesLoaded;
		__bytesTotal = event.bytesTotal;

		dispatchEvent(event);
	}
	
	function openHandler(event:Event):Void {
		dispatchEvent(event);
	}

	function securityErrorHandler(event:SecurityErrorEvent):Void {
		dispatchEvent(event);
	}
	
	function generateCompleteHandler(e):Void {
		var soundClass:Class<Dynamic> = cast(cast(e.target, LoaderInfo).applicationDomain.getDefinition(SWFFormat.CLASS_NAME), Class<Dynamic>);
		sound = cast(Type.createInstance(soundClass, []), Sound);
		__length = sound.length;
		isLoaded = true;
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	/*
	* *********************************************************
	* PUBLIC METHODS
	* *********************************************************
	*
	*/
	/**
	 * Initiates loading of an external WAV file from the specified URL. 
	 * 
	 * @param request:URLRequest — A URLRequest object specifying the URL to download. If the value of this parameter or the URLRequest.url property of the URLRequest object passed are null, Flash Player throws a null pointer error.  
	 * 
	 * @event complete:Event — Dispatched after data has loaded successfully.
	 * @event httpStatus:HTTPStatusEvent — If access is by HTTP, and the current Flash Player environment supports obtaining status codes, you may receive these events in addition to any complete or error event.
	 * @event ioError:IOErrorEvent — The load operation could not be completed.
	 * @event open:Event — Dispatched when a load operation starts.
	 * @event securityError:SecurityErrorEvent — A load operation attempted to retrieve data from a server outside the caller's security sandbox. This may be worked around using a policy file on the server. 
	 * @event decodeError:WAVPlayerEvent — Dispatched when a decode operation could not be completed. (i.e. incorrect PCM format).
	 */
	public function load(stream:URLRequest):Void {
		if (isLoadStarted) {
			return;
		}
		
		isLoadStarted = true;
		isLoaded = false;
		__url = stream.url;
		byteStream.load(stream);
	}
	
	/**
	 * Closes the stream, causing any download of data to cease. No data may be read from the stream after the close() method is called. 
	 */
	public function close():Void {
		byteStream.close();
		__bytesLoaded = 0;
		__bytesTotal = 0;
		__url = null;
		__length = 0;
		isLoaded = false;
	}
	
	/**
	 * Generates a new SoundChannel object to play back the sound. This method returns a SoundChannel object, which you access
	 * to stop the sound and to monitor volume. (To control the volume, panning, and balance, access the SoundTransform object
	 * assigned to the sound channel.). Returns null if sound was not loaded.
	 * 
	 * @param startTime:Number (default = 0) — The initial position in milliseconds at which playback should start.
	 * @param loops:int (default = 0) — Defines the number of times a sound loops before the sound channel stops playback. 
	 * @param sndTransform:SoundTransform (default = null) — The initial SoundTransform object assigned to the sound channel.  
	 */
	public function play(?startTime:Float = 0, ?loops:UInt = 0, ?sndTransform:SoundTransform = null):SoundChannel {
		if (isLoaded) {
			return sound.play(startTime, loops, sndTransform);
		}
		
		return null;
	}
	
	/*
	* *********************************************************
	* SETTERS/GETTERS
	* *********************************************************
	*
	*/
	/**
	 * Returns the currently available number of bytes in this sound object. read-only.
	 */
	public function getBytesLoaded():UInt {
		return __bytesLoaded;
	}
	
	/**
	 * Returns the total number of bytes in this sound object. read-only.
	 */
	public function getBytesTotal():UInt {
		return __bytesTotal;
	}

	/**
	 * The length of the current sound in milliseconds. read-only.
	 */
	public function getLength():Float {
		return __length;	
	}
	
	/**
	 * The URL from which this sound was loaded. read-only.
	 */
	public function getUrl():String {
		return __url;
	}
	
	/**
	 * Returns a copy of audio data (from PCM wave-data) in ByteArray. Returns null if sound was not loaded. read-only.
	 */
	public function getAudioData():ByteArray {
		if (isLoaded) {
			var outData:ByteArray = new ByteArray();
			outData.endian = Endian.LITTLE_ENDIAN;
			outData.writeBytes(waveData);
			return outData;
		}
		
		return null;
	}
	
	/**
	 * Returns a copy of PCMFormat object, which contains some parameters of loaded sound. Returns null if sound was not loaded. read-only.
	 */
	public function getAudioFormat():PCMFormat {
		if (isLoaded) {
			var format:PCMFormat = new PCMFormat();
			format.analyzeHeader(waveHeader);
			return format;
		}
		
		return null;
	}
}
