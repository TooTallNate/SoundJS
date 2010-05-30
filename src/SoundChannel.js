/**
 * A SoundChannel represents an audio channel playing a sound file. They
 * are created by calling Sound#play. They are NOT reusable once it's data
 * has been played, or once SoundChannel#stop has been called.
 */
function SoundChannel(controller, options) {
    var self = this,
        channel = null,
        listeners = {};

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

    // Initialization
    if (controller.flash) {
        // Play through Flash
        //console.log("attempting to play '" + controller.src + "' via flash: fid=" + controller.id);
        channel = {};
        channel.id = SWF['_play'](controller.id, options['offset'], options['volume'], options['pan']);
        channel.flash = true;
        // ExternalInterface needs a global function to call when the channel completes.
        channel["done"] = function() {
            delete SoundChannel[channel.id];
            fire("ended");
        }
        // Make the 'handler' globally available for Flash ExternalInterface. 
        SoundChannel[channel.id] = channel;
    } else {
        // Play HTML5
        //console.log("attempting to play '" + controller.src + "' natively");
        channel = controller.cloneNode(false);
        channel.addEventListener("ended", function(e) {
            fire("ended");
        }, false);
        //channel['currentTime'] = options['offset'];
        // 'pan' is not (currently) supported by HTML5 Audio
        channel.play();
        channel['muted'] = false;
        channel['volume'] = options['volume'];
    }
    
    
    self['getPosition'] = function() {
        if (channel.flash) {
            return SWF['_getPos'](channel.id);
        } else {
            return channel['currentTime'] * 1000;
        }
    }
    self['setVolume'] = function(volume) {
        if (channel.flash) {
            SWF['_setVol'](channel.id, volume);
        } else {
            channel['volume'] = volume;
        }
    }
    self['getVolume'] = function() {
        if (channel.flash) {
            return SWF['_getVol'](channel.id);
        } else {
            return channel['volume'];
        }
    }
    self['setVolume'] = function(volume) {
        if (channel.flash) {
            SWF['_setVol'](channel.id, volume);
        } else {
            channel['volume'] = volume;
        }
    }
    self['getPan'] = function() {
        if (channel.flash) {
            return SWF['_getPan'](channel.id);
        } else {
            // Pan not supported by HTML5 audio.
        }
    }
    self['setPan'] = function(pan) {
        if (channel.flash) {
            return SWF['_setPan'](channel.id, pan);
        } else {
            // Pan not supported by HTML5 audio.
        }
    }
    self['stop'] = function() {
        if (channel.flash) {
            SWF['_stop'](channel.id);
            channel['done']();
        } else {
            channel.pause();
            fire("ended");
        }
    }
    /**
     * Registers a listener (Function) for the specified event type.
     *  
     *  Possible event 'type's for Sound are:
     *    - ended | called when the sound file finishes playing on the channel.
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
        return "[object SoundChannel]";
    }
    // Debug
    //self['channel'] = channel;
}
