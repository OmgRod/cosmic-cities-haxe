package gameplay;

/**
 * Enum representing different gameplay modes.
 */
enum GameplayMode {
    /**
     * Standard top-down RPG walking mode with tiled map collision
     */
    TiledWalking;
    
    /**
     * Flying/space navigation mode
     */
    Flying;
    
    /**
     * Cutscene/scripted sequence mode (player control disabled)
     */
    Cutscene;
    
    /**
     * Custom mode - can be extended for specific chapter needs
     */
    Custom(modeName:String);
}
