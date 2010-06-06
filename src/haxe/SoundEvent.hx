/**
 * Copyright (c) 2010 Nathan Rajlich
 * 
 * This file is part of Sound.js.
 * 
 * Sound.js is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version.
 * 
 * Sound.js is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with Sound.js.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
import flash.events.Event;

class SoundEvent extends Event {
    public static var LOADED:String = "loaded";
    public static var OPEN:String = "open";
    public static var ERROR:String = "error";
    public static var PROGRESS:String = "progress";

    public var message:String;

    public function new(command:String, ?message:String=null) {
        super(command);
        this.message = message;
    }
}
