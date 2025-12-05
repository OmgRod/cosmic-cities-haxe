package gameplay;

/**
 * Data structure for a game chapter with sequences.
 * Each chapter consists of multiple sequences that can have different gameplay modes.
 */
typedef ChapterData = {
    /**
     * Unique identifier for the chapter
     */
    var id:String;
    
    /**
     * Display name of the chapter
     */
    var name:String;
    
    /**
     * Ordered array of sequences that make up this chapter
     */
    var sequences:Array<SequenceData>;
    
    /**
     * Custom initialization function (optional)
     */
    @:optional var onInit:() -> Void;
    
    /**
     * Callback when chapter completes (optional)
     */
    @:optional var onComplete:() -> Void;
    
    /**
     * ID of next chapter to load after completion (optional)
     */
    @:optional var nextChapter:String;
    
    /**
     * Custom data for chapter-specific needs
     */
    @:optional var customData:Dynamic;
}
