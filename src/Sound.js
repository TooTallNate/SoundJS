/* The MIT License
 * 
 * Copyright (c) 2010 Nathan Rajlich
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
function Sound(src) {
    var self = this,
        listeners = {},
        loadedCalled = false;
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
            //console.log("native progress");
            var percentLoaded = e.lengthComputable ? e.loaded / e.total : audio.buffered.end(0) / audio.duration;
            fire("progress");
            if (!loadedCalled && percentLoaded >= 0.9) {
                fire("loaded");
                loadedCalled = true;
            }
            //console.log(percentLoaded);
        }, false);
        audio.addEventListener("error", function(e) {
            fire("error");
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
        audio.id = SWF['_load'](self.src);
        audio.flash = true;
        audio.src = self.src;
        audio['loaded'] = function() {
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
    //self['audio'] = audio;
}
    
Sound['version'] = VERSION;
Sound['forceFlash'] = false;
Sound['swfPath'] = "Sound.swf";
/**
 * Called by Flash ExternalInterface when the Flash object has finished loading.
 */
Sound['_swfReady'] = function() {
    // Get the SWF object into our local scope, and delete the global reference.        
    SWF = Sound['_swf'];
    delete Sound['_swf'];
    delete Sound['_swfReady'];
}
