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
(function(global) {
    var VERSION = "0.1",
        IS_IE = navigator.appName == 'Microsoft Internet Explorer',
        HAS_NATIVE_AUDIO = !!global['HTMLAudioElement'],
        SWF = null;
    
    function SoundEffect(src) {
        var self = this;
        self.src = src;
        self.loaded = false;
        
        // The handle to the native Audio or Flash controller for the sound
        var audio;
        
        var loadNative = function() {
            audio = new Audio(self.src);
        	audio.addEventListener("progress", function() {
                console.log("progress");
                console.log(this);
            }, false);
            audio.addEventListener("error", function() {
                console.log("error");
                loadFlash();
            }, false);
            audio.load();
        }

        var loadFlash = function() {
            audio = {};
            audio.flash = true;
            audio.id = SWF['_load'](self.src);
        }

        if (HAS_NATIVE_AUDIO && !SoundEffect['forceFlash']) {
            // Attempt to load through native HTML5 Audio
            loadNative();
        } else {
            // Have Flash load and be in charge of the sound
            loadFlash();
        }
        
        /**
         * Creates a 'Play' instace.
         */
        self.play = function(options) {
            if (audio.flash) {
                SWF['_play'](audio.id, options['volume'], options['pan']);
            } else {
                // Play HTML5
                var play = audio.cloneNode(false);
                console.log(play);
            }
        }
    }
        
    SoundEffect['version'] = VERSION;
    SoundEffect['forceFlash'] = false;
    
    

    // Embed the fallback <audio> SWF onto the page
    function embedSwf() {
        var container = document.createElement("div"),
            id = "SoundEffectFLASH",
            flashvars = {},
            params = {
                "wmode": "transparent",
                "allowScriptAccess": "always"
            },
            attributes = {
                "style": "position:fixed;top:0px;right:0px;"
            };
        container.id = id;
        document.body.appendChild(container);
        // TODO: Make the path to the SWF configurable
        swfobject.embedSWF("SoundEffect.swf", id, 8, 8, "10", false, flashvars, params, attributes);
    }

    /**
     * Called by Flash ExternalInterface when the Flash object has
     * finished loading.
     */
    SoundEffect['_swfReady'] = function() {
        // Get the SWF object into our local scope, and delete the global reference.        
        SWF = SoundEffect['_swf'];
        delete SoundEffect['_swf'];
    }
    
    
    
    
    function init() {
        if (arguments.callee.done) return;
        arguments.callee.done = true;
        // do your thing
        embedSwf();
    }
    
    // DOM loaded code
    if (document.addEventListener) {
        document.addEventListener('DOMContentLoaded', init, false);
    }
    (function() {
        if (IS_IE) {
            try {
                document.body.doScroll('up');
                return init();
            } catch(e) {}
        } else {
            if (/loaded|complete/.test(document.readyState)) return init();
        }
        if (!init.done) setTimeout(arguments.callee, 30);
    })();
    if (global.addEventListener) {
        global.addEventListener('load', init, false);
    } else if (global.attachEvent) {
        global.attachEvent('onload', init);
    }
    // end DOM loaded code
    
    
    
    
    // Export the SoundEffect constructor to global
    global['SoundEffect'] = SoundEffect;
})(this);
