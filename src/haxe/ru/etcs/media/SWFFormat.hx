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
import flash.utils.Endian;

class SWFFormat {
    
    /*
    * *********************************************************
    * CLASS PROPERTIES
    * *********************************************************
    *
    */
    static var SWF_PART0:String = '46575309';
    static var SWF_PART1:String = '7800055F00000FA000000C01004411080000004302FFFFFFBF150B00000001005363656E6520310000BF14C7000000010000000010002E00000000080013574156506C61796572536F756E64436C6173730B666C6173682E6D6564696105536F756E64064F626A6563740C666C6173682E6576656E74730F4576656E744469737061746368657205160116031802160600050701020702040701050704070300000000000000000000000000010102080300010000000102010104010003000101050603D030470000010101060706D030D04900470000020201010517D0306500600330600430600230600258001D1D1D6801470000BF03';
    static var SWF_PART2:String = '3F131800000001000100574156506C61796572536F756E64436C61737300440B0800000040000000';
    
    public static var CLASS_NAME:String = 'WAVPlayerSoundClass';
    
    var pcmFormat:PCMFormat;
    
    /*
    * *********************************************************
    * CONSTRUCTOR
    * *********************************************************
    *
    */
    public function new(format:PCMFormat) {
        pcmFormat = format;
    }
    
    /*
    * *********************************************************
    * PRIVATE METHODS
    * *********************************************************
    *
    */
    function writeBytesFromString(byteArray:ByteArray,bytesHexString:String):Void {
        var length:UInt = bytesHexString.length;
        
        var i:UInt = 0;
           while (i<length) {
            var hexByte:String = bytesHexString.substr(i,2);
            var byte:UInt = Std.parseInt('0x'+hexByte);
            byteArray.writeByte(byte);
        	i+=2;
           }
    }
    
    function traceArray(array:ByteArray):String { // for debug
        var out:String = '';
        var pos:UInt = array.position;
        array.position = 0;
        
        while (cast(array.bytesAvailable, Bool)) {
            var str:String = toRadix(array.readUnsignedByte(), 16).toUpperCase();
            str = str.length < 2 ? '0'+str : str;
            out += str+' ';
        }
        
        array.position = pos;
        return out;
    }
    
    function getFormatByte():UInt {
        var byte:UInt = (pcmFormat.bitsPerSample == 0x10) ? 0x32 : 0x00;
        byte += (pcmFormat.channels-1);
        byte += 4*(toRadix(Math.floor(pcmFormat.sampleRate/5512.5), 2).length-1); // :-)
        return byte;
    }
    
    /*
    * Required to make up for HaXe's lack of a proper Number#toString(radix)
    */
    private static function toRadix(N:Int, radix:Int) : String {
        var HexN:String="";
        var Q:Int=Math.floor(Math.abs(N));
        var R:Int;
        while (true) {
            R = Q % radix;
            HexN = "0123456789abcdefghijklmnopqrstuvwxyz".charAt(R) + HexN;
            Q = cast((Q-R)/radix, Int);
            if (Q==0)
                break;
        }
        return ((N<0) ? "-"+HexN : HexN);
    }

    /*
    * *********************************************************
    * PUBLIC METHODS
    * *********************************************************
    *
    */
    public function compileSWF(audioData:ByteArray):ByteArray {
        var dataLength:UInt = audioData.length;
        var swfSize:UInt = dataLength + 307;
        var totalSamples:UInt = cast(dataLength / pcmFormat.blockAlign, UInt);
        var output:ByteArray = new ByteArray();
        output.endian = Endian.LITTLE_ENDIAN;
        writeBytesFromString(output, SWFFormat.SWF_PART0);
        output.writeUnsignedInt(swfSize);
        writeBytesFromString(output, SWFFormat.SWF_PART1);
        output.writeUnsignedInt(dataLength + 7);
        output.writeByte(1);
        output.writeByte(0);
        output.writeByte(getFormatByte());
        output.writeUnsignedInt(totalSamples);
        output.writeBytes(audioData);
        writeBytesFromString(output, SWFFormat.SWF_PART2);
        return output;
    }
}

