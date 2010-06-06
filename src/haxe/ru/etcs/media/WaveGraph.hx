package ru.etcs.media;

extern class WaveGraph extends flash.display.Sprite {
	var backgroundColor : UInt;
	var graphColor : UInt;
	var graphHeight : UInt;
	var graphWidth : UInt;
	var lineAlpha : Float;
	var lineColor : UInt;
	var lineThickness : Float;
	var position : Float;
	function new(p0 : flash.utils.ByteArray, p1 : PCMFormat) : Void;
	function redraw() : Void;
}
