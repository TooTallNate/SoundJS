(function(global) {
    var VERSION = "0.1",
        IS_IE = navigator.appName == 'Microsoft Internet Explorer',
        HAS_NATIVE_AUDIO = !!global['HTMLAudioElement'];
    
    function SoundEffect(src) {
        var self = this;
        self.src = src;
        self.loaded = false;
        
        // The handle to the native Audio or Flash controller for the sound
        var audio;
        
        /**
         * Begins loading the sound effect.
         */
        self.load = function() {
            if (HAS_NATIVE_AUDIO && !SoundEffect['forceFlash']) {
                // Attempt to load through native HTML5 Audio
                audio = loadNative(self);
            } else {
                // Have Flash load and be in charge of the sound
                audio = loadFlash(self);
            }
        }
        
        /**
         * Creates a 'Play' instace.
         */
        self.play = function() {
            
        }
    }
        
    SoundEffect['version'] = VERSION;
    SoundEffect['forceFlash'] = false;
    SoundEffect['load'] = function(src) {
        var sound = new SoundEffect(src);
        sound.load();
        return sound;
    }
    
    function loadNative(se) {
        var audio = new Audio(se.src);
        audio.addEventListener("progress", function() {
            console.log("progress");
            console.log(this);
        }, false);
        audio.addEventListener("error", function() {
            console.log("error");
            console.log(this);
        }, false);
        audio.load();
        return audio;
    }

    function loadFlash(se) {
        return SoundEffect['_swf']['_Load'](se.src);
    }
    
    
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
        console.log('flash ready');
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
    
    
    
    
    
    global['SoundEffect'] = SoundEffect;
})(this);
