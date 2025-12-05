package gameplay;

import states.GameState;

/**
 * Helper class for managing chapter transitions and sequence progression.
 */
class ChapterManager {
    /**
     * Load a chapter by ID and optionally switch to GameState
     */
    public static function loadChapter(chapterId:String, switchToGameState:Bool = false):Bool {
        // Initialize context if needed
        if (GameState.gameplayContext == null) {
            GameState.gameplayContext = new GameplayContext();
        }
        
        var success = GameState.gameplayContext.loadChapter(chapterId);
        
        if (success) {
            var sequence = GameState.gameplayContext.currentSequence;
            
            // Start music if specified in sequence
            if (sequence != null && sequence.music != null && sequence.music != "") {
                managers.MusicManager.play(sequence.music);
            }
            
            // Switch to game state if requested
            if (switchToGameState) {
                flixel.FlxG.switchState(() -> new GameState());
            }
        }
        
        return success;
    }
    
    /**
     * Advance to the next sequence in the current chapter
     */
    public static function advanceSequence():Bool {
        if (GameState.gameplayContext == null) {
            trace('[ChapterManager] No gameplay context available');
            return false;
        }
        
        var success = GameState.gameplayContext.advanceSequence();
        
        if (success) {
            var sequence = GameState.gameplayContext.currentSequence;
            
            // Start music for new sequence
            if (sequence != null && sequence.music != null && sequence.music != "") {
                managers.MusicManager.play(sequence.music);
            }
            
            // Reload the map/state if needed (this should trigger GameState.create() again)
            flixel.FlxG.resetState();
        }
        
        return success;
    }
    
    /**
     * Check if a trigger should advance the sequence
     */
    public static function checkTrigger(triggerId:String):Bool {
        if (GameState.gameplayContext == null) {
            return false;
        }
        
        return GameState.gameplayContext.checkTrigger(triggerId);
    }
    
    /**
     * Load a specific sequence by index
     */
    public static function loadSequence(index:Int):Bool {
        if (GameState.gameplayContext == null) {
            trace('[ChapterManager] No gameplay context available');
            return false;
        }
        
        var success = GameState.gameplayContext.loadSequence(index);
        
        if (success) {
            var sequence = GameState.gameplayContext.currentSequence;
            
            // Start music for new sequence
            if (sequence != null && sequence.music != null && sequence.music != "") {
                managers.MusicManager.play(sequence.music);
            }
        }
        
        return success;
    }
    
    /**
     * Get current chapter ID
     */
    public static function getCurrentChapterId():Null<String> {
        if (GameState.gameplayContext == null || GameState.gameplayContext.currentChapter == null) {
            return null;
        }
        return GameState.gameplayContext.currentChapter.id;
    }
    
    /**
     * Get current gameplay mode
     */
    public static function getCurrentMode():GameplayMode {
        if (GameState.gameplayContext == null) {
            return TiledWalking; // Default
        }
        return GameState.gameplayContext.currentMode;
    }
    
    /**
     * Check if we're in a specific mode
     */
    public static function isMode(mode:GameplayMode):Bool {
        return getCurrentMode() == mode;
    }
}
