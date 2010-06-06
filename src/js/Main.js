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
(function(global) {
    var VERSION = "0.1",
        IS_IE = navigator.appName == 'Microsoft Internet Explorer',
        HAS_NATIVE_AUDIO = !!global['HTMLAudioElement'],
        // Initally, SWF will contain an array that will hold premature calls
        // (function references) to the SWF before it has been initalized.
        // Once it gets initalized, the array will be drained, and replaced
        // with the actual Flash instance.
        SWF = [];
    SWF['_load'] = function() {
        var args = arguments;
        SWF.push(function() {
            SWF['_load'].apply(SWF, args);
        });
    };

    
    //{src/js/Sound.js}
    //{src/js/SoundChannel.js}


    // Embed the fallback <audio> SWF onto the page
    function embedSwf() {
        var container = document.createElement("div"),
            id = "SoundFLASH",
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
        swfobject.embedSWF(Sound['swfPath'], id, 8, 8, "10", false, flashvars, params, attributes);
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
    
    
    
    
    // Export the Sound & SoundChannel constructors to global
    global['Sound'] = Sound;
    global['SoundChannel'] = SoundChannel;
})(this);
