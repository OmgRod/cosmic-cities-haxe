package gameplay;

/**
 * A single sequence/segment within a chapter
 */
typedef SequenceData = {
    /**
     * Unique identifier for this sequence
     */
    var id:String;
    
    /**
     * Display name/description of this sequence
     */
    var name:String;
    
    /**
     * Gameplay mode for this sequence
     */
    var mode:GameplayMode;
    
    /**
     * Map to load (if applicable for this mode)
     */
    @:optional var map:String;
    
    /**
     * Tileset for the map (if applicable)
     */
    @:optional var tileset:String;
    
    /**
     * Music track for this sequence (optional)
     */
    @:optional var music:String;
    
    /**
     * Trigger ID that advances to next sequence (e.g., object interaction ID)
     */
    @:optional var triggerToAdvance:String;
    
    /**
     * Auto-advance after duration (seconds), 0 = manual trigger required
     */
    @:optional var autoAdvanceAfter:Float;
    
    /**
     * Callback when sequence starts
     */
    @:optional var onStart:() -> Void;
    
    /**
     * Callback when sequence ends
     */
    @:optional var onEnd:() -> Void;
    
    /**
     * Custom data for this sequence
     */
    @:optional var customData:Dynamic;
}
