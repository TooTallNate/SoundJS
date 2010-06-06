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
 
// The count for Flash ID's to use
var flashSoundCount = 0;
 
function Sound(src) {
    var self = this,
        listeners = {};
    self.src = src;
    self.loaded = false;
    
    // The handle to the native Audio or Flash controller for the sound
    var audio;
    
    var fire = function(type, evt) {
        if (type in listeners) {
            var array = listeners[type],
                l = array.length,
                i = 0;
            evt = evt || {};
            evt['type'] = type;
            evt['target'] = self;
            for (; i < l; i++) {
                array[i].call(self, evt);
            }
        }
    }
    
    var loadNative = function() {
        //console.log("attempting to load '"+self.src+"' native");
        audio = document.createElement("audio");
    	audio.addEventListener("progress", function(e) {
            var percentLoaded;
            if (audio.readyState == audio.HAVE_ENOUGH_DATA) {
                percentLoaded = 1;
            } else if (e.lengthComputable) {
                // Firefox specific way of getting load progress
                // https://developer.mozilla.org/En/Using_audio_and_video_in_Firefox
                percentLoaded = e.loaded / e.total;
            } else if (audio.buffered.length > 0) {
                // WebKit specific way of getting load progress
                // http://developer.apple.com/safari/library/documentation/AudioVideo/Conceptual/Using_HTML5_Audio_Video/ControllingMediaWithJavaScript/ControllingMediaWithJavaScript.html#//apple_ref/doc/uid/TP40009523-CH3-SW4
                percentLoaded = audio.buffered.end(0) / audio.duration;
            } else {
                // Fail!
                percentLoaded = 0;
            }
            fire("progress");
            /* Testing letting "canplaythrough" take care of this instead...
            if (!self.loaded && percentLoaded >= 0.9) {
                self.loaded = true;
                fire("loaded");
            }
            */
        }, false);
        // Aside from inspecting the progress event, we can also listen for
        // the "canplaythrough" event as a psuedo-loaded event.
        audio.addEventListener("canplaythrough", function(e) {
            if (!self.loaded) {
                self.loaded = true;
                fire("loaded");
            }
        }, false);
        audio.addEventListener("error", function(e) {
            fire("error");
            // On native errors we fall back to Flash
            loadFlash();
        }, false);
        audio.addEventListener("loadstart", function(e) {
            fire("open", {'method':'HTML5'});
        }, false);
        audio.src = self.src;
        audio.load();
        audio.muted = true;
        audio.play();
    }

    var loadFlash = function() {
        //console.log("attempting to load '"+self.src+"' via flash");
        audio = {};
        audio.id = flashSoundCount++;
        SWF['_load'](self.src);
        audio.flash = true;
        audio.src = self.src;
        audio['loaded'] = function() {
            self.loaded = true;
            fire("loaded");
        }
        audio['error'] = function() {
            fire("error");
        }
        audio['open'] = function() {
            fire("open", {'method':'Flash'});
        }
        audio['progress'] = function() {
            fire("progress");
        }
        // Make the 'handler' globally available for Flash ExternalInterface. 
        Sound[audio.id] = audio;
    }

    if (HAS_NATIVE_AUDIO && !Sound['forceFlash']) {
        // Attempt to load through native HTML5 Audio
        loadNative();
    } else {
        // Have Flash load and be in charge of this sound
        loadFlash();
    }
    
    /**
     * Creates and returns a SoundChannel with the specified inital props.
     */
    self["play"] = function(options) {
        options = options || {};
        options['volume'] = options['volume'] || 1;
        options['pan'] = options['pan'] || 0;
        options['offset'] = options['offset'] || 0;
        return new SoundChannel(audio, options);
    }
    self["getLength"] = function() {
        if (audio.flash) {
            return SWF['_getLen'](audio.id);
        } else {
            return audio.duration * 1000;
        }
    }
    /**
     * Registers a listener (Function) for the specified event type.
     *  
     *  Possible event 'type's for Sound are:
     *    - loaded   | called when the Sound file finishes loading.
     *    - open     | called when loading of the file begins
     *    - progress | called repeadedly as the file is loading
     *    - error    | called when a error happens regarding loading the file.
     */
    self["addEventListener"] = function(type, listener) {
        type = type.toLowerCase();
        if (!(type in listeners)) listeners[type] = [];
        listeners[type].push(listener);
    }
    /**
     * Removes a listener from being called when the specified event occurs.
     */
    self["removeEventListener"] = function(type, listener) {

    }
    self['toString'] = function() {
        return "[object Sound]";
    }
    // Debug
    self['audio'] = audio;
}
    
Sound['version'] = VERSION;
Sound['forceFlash'] = false;
Sound['swfPath'] = "Sound.swf";
/**
 * Called by Flash ExternalInterface when the Flash object has finished loading.
 */
Sound['_swfReady'] = function() {
    // Get the SWF object into our local scope, and delete the global reference.
    var prematureCalls = SWF, i=0, funcName = null;
    SWF = Sound['_swf'];
    delete Sound['_swf'];
    delete Sound['_swfReady'];
    for (; i<prematureCalls.length; i++) {
        for (funcName in prematureCalls[i]) {
            prematureCalls[i][funcName]();
        }
    }
}
