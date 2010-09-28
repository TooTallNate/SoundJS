/**
 * Copyright (c) 2010 Nathan Rajlich
 * 
 * This file is part of SoundJS.
 * 
 * SoundJS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version.
 * 
 * SoundJS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with SoundJS.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * The "Sound" class directly reflects our Sound JavaScript Class. It is
 * meant to be abstract, but I don't know if HaXe is capable of that.
 */
import flash.events.EventDispatcher;
import flash.net.URLRequest;
 
class Sound extends EventDispatcher {
    public function getLength() : Float {
        return 0;
    }
    public function play(offset:Float, volume:Float, pan:Float) : SoundChannel {
        return null;
    }
    
    public static function getInstance(src:String) : Sound {
        var url : URLRequest = new URLRequest(src);
        if (~/\.(mp3)(\?.*)?$/i.match(src)) {
            return new MP3(url);
        } else if (~/\.(ogg|oga)(\?.*)?$/i.match(src)) {
            return new OGG(url);
        } else if (~/\.(wav)(\?.*)?$/i.match(src)) {
            return new WAV(url);
        }
        return null;
    }
}
