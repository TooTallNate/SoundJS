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
 * The "SoundChannel" class directly reflects our SoundChannel
 * JavaScript Class. It is meant to be abstract.
 */
import flash.events.EventDispatcher;

class SoundChannel extends EventDispatcher {
    public function stop() : Void {
        
    }
    
    public function getPosition() : Float {
        return -1;
    }
    public function getVolume() : Float {
        return -1;
    }
    public function getPan() : Float {
        return -1;
    }
    public function setVolume(volume : Float) : Void {
        
    }
    public function setPan(pan : Float) : Void {
        
    }
}