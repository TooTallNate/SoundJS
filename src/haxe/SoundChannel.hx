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