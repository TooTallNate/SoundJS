import flash.events.Event;

class SoundEvent extends Event {
    public static var LOADED:String = "loaded";
    public static var OPEN:String = "open";
    public static var ERROR:String = "error";
    public static var PROGRESS:String = "progress";

    public function new(command:String) {
        super(command);
        // TODO: Something?
    }
}
