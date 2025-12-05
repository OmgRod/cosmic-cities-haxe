package gameplay;

/**
 * Context object that holds the current gameplay state.
 */
class GameplayContext {
    /**
     * Current active chapter
     */
    public var currentChapter:Null<ChapterData>;
    
    /**
     * Current sequence within the chapter
     */
    public var currentSequence:Null<SequenceData>;
    
    /**
     * Index of current sequence in chapter
     */
    public var currentSequenceIndex:Int = 0;
    
    /**
     * Current gameplay mode
     */
    public var currentMode:GameplayMode;
    
    /**
     * Current map path
     */
    public var currentMap:String;
    
    /**
     * Current tileset path
     */
    public var currentTileset:String;
    
    /**
     * Timer for auto-advancing sequences
     */
    public var sequenceTimer:Float = 0;
    
    /**
     * Custom context data for mode-specific needs
     */
    public var customData:Dynamic;
    
    public function new() {
        currentMode = TiledWalking;
        currentMap = "";
        currentTileset = "";
        customData = {};
    }
    
    /**
     * Load a chapter by ID and start at first sequence
     */
    public function loadChapter(chapterId:String):Bool {
        var chapter = ChapterRegistry.get(chapterId);
        if (chapter == null) {
            trace('[GameplayContext] Chapter not found: $chapterId');
            return false;
        }
        
        if (chapter.sequences == null || chapter.sequences.length == 0) {
            trace('[GameplayContext] Chapter has no sequences: $chapterId');
            return false;
        }
        
        currentChapter = chapter;
        currentSequenceIndex = 0;
        
        trace('[GameplayContext] Loaded chapter: ${chapter.name}');
        trace('[GameplayContext]   Sequences: ${chapter.sequences.length}');
        
        // Call custom init if available
        if (chapter.onInit != null) {
            chapter.onInit();
        }
        
        // Load first sequence
        loadSequence(0);
        
        return true;
    }
    
    /**
     * Load a specific sequence by index within current chapter
     */
    public function loadSequence(index:Int):Bool {
        if (currentChapter == null) {
            trace('[GameplayContext] No chapter loaded');
            return false;
        }
        
        if (index < 0 || index >= currentChapter.sequences.length) {
            trace('[GameplayContext] Invalid sequence index: $index');
            return false;
        }
        
        currentSequenceIndex = index;
        currentSequence = currentChapter.sequences[index];
        
        // Update context from sequence
        currentMode = currentSequence.mode;
        currentMap = currentSequence.map != null ? currentSequence.map : "";
        currentTileset = currentSequence.tileset != null ? currentSequence.tileset : "";
        sequenceTimer = 0;
        
        trace('[GameplayContext] Loaded sequence ${index + 1}/${currentChapter.sequences.length}: ${currentSequence.name}');
        trace('[GameplayContext]   Mode: ${currentSequence.mode}');
        if (currentSequence.map != null) {
            trace('[GameplayContext]   Map: ${currentSequence.map}');
        }
        
        // Call sequence start callback
        if (currentSequence.onStart != null) {
            currentSequence.onStart();
        }
        
        return true;
    }
    
    /**
     * Advance to the next sequence in the chapter
     */
    public function advanceSequence():Bool {
        if (currentChapter == null) {
            trace('[GameplayContext] No chapter loaded');
            return false;
        }
        
        // Call current sequence end callback
        if (currentSequence != null && currentSequence.onEnd != null) {
            currentSequence.onEnd();
        }
        
        var nextIndex = currentSequenceIndex + 1;
        
        if (nextIndex >= currentChapter.sequences.length) {
            // Chapter complete
            trace('[GameplayContext] Chapter complete: ${currentChapter.name}');
            
            if (currentChapter.onComplete != null) {
                currentChapter.onComplete();
            }
            
            // Load next chapter if specified
            if (currentChapter.nextChapter != null) {
                return loadChapter(currentChapter.nextChapter);
            }
            
            return false; // No more sequences
        }
        
        return loadSequence(nextIndex);
    }
    
    /**
     * Update sequence timer (call this in update loop)
     */
    public function updateSequenceTimer(dt:Float):Void {
        if (currentSequence == null) return;
        
        // Check for auto-advance
        if (currentSequence.autoAdvanceAfter != null && currentSequence.autoAdvanceAfter > 0) {
            sequenceTimer += dt;
            if (sequenceTimer >= currentSequence.autoAdvanceAfter) {
                advanceSequence();
            }
        }
    }
    
    /**
     * Check if a trigger should advance the sequence
     */
    public function checkTrigger(triggerId:String):Bool {
        if (currentSequence == null) return false;
        
        if (currentSequence.triggerToAdvance != null && currentSequence.triggerToAdvance == triggerId) {
            return advanceSequence();
        }
        
        return false;
    }
    
    /**
     * Get a description of the current mode
     */
    public function getModeDescription():String {
        return switch (currentMode) {
            case TiledWalking: "Tiled Walking Mode";
            case Flying: "Flying Mode";
            case Cutscene: "Cutscene Mode";
            case Custom(name): 'Custom Mode: $name';
        }
    }
    
    /**
     * Get current sequence progress
     */
    public function getSequenceProgress():String {
        if (currentChapter == null) return "No chapter loaded";
        return '${currentSequenceIndex + 1}/${currentChapter.sequences.length}';
    }
}
