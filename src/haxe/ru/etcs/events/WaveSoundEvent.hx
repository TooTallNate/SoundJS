/**
* WaveSoundEvent by Denis Kolyako. May 28, 2007
* Visit http://dev.etcs.ru for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
* 
*
* Please contact etc[at]mail.ru prior to distributing modified versions of this class.
*/
package ru.etcs.events; 

import flash.events.Event;

class WaveSoundEvent extends Event {
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
	public static var DECODE_ERROR:String = 'decodeError';

	/*
	* *********************************************************
	* CONSTRUCTOR
	* *********************************************************
	*
	*/
	public function new(type:String,?bubbles:Bool=false,?cancelable:Bool=false) {
		super(type,bubbles,cancelable);
	}
}
