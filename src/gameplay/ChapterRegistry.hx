package gameplay;

/**
 * Registry for managing game chapters.
 */
class ChapterRegistry {
    private static var chapters:Map<String, ChapterData> = new Map();
    private static var chapterOrder:Array<String> = [];
    
    /**
     * Register a new chapter
     */
    public static function register(chapter:ChapterData):Void {
        chapters.set(chapter.id, chapter);
        if (!chapterOrder.contains(chapter.id)) {
            chapterOrder.push(chapter.id);
        }
        trace('[ChapterRegistry] Registered chapter: ${chapter.id} (${chapter.name})');
    }
    
    /**
     * Get a chapter by ID
     */
    public static function get(id:String):Null<ChapterData> {
        return chapters.get(id);
    }
    
    /**
     * Get all registered chapters
     */
    public static function getAll():Array<ChapterData> {
        var result:Array<ChapterData> = [];
        for (id in chapterOrder) {
            var chapter = chapters.get(id);
            if (chapter != null) {
                result.push(chapter);
            }
        }
        return result;
    }
    
    /**
     * Get all chapter IDs in registration order
     */
    public static function getAllIds():Array<String> {
        return chapterOrder.copy();
    }
    
    /**
     * Check if a chapter exists
     */
    public static function exists(id:String):Bool {
        return chapters.exists(id);
    }
    
    /**
     * Clear all chapters (useful for testing)
     */
    public static function clear():Void {
        chapters.clear();
        chapterOrder = [];
    }
    
    /**
     * Initialize default chapters with sequence-based progression
     */
    public static function initDefaults():Void {
        // Chapter 1: Evacuation - Multiple sequences showing walk → interact → fly → cutscene
        register({
            id: "ch1_exodus",
            name: "Chapter 1: The Exodus",
            sequences: [
                {
                    id: "explore_ship",
                    name: "Explore the Ship",
                    mode: TiledWalking,
                    map: "assets/maps/ship-main.tmx",
                    tileset: "assets/sprites/CC_shipSheet_001.png",
                    music: "geton",
                    triggerToAdvance: "alarm_console", // Interact with alarm console to advance
                    onStart: function() {
                        trace("Sequence: Explore Ship started");
                    },
                    customData: {}
                },
                {
                    id: "escape_flight",
                    name: "Escape Flight",
                    mode: Flying,
                    map: "assets/maps/space-sector.tmx",
                    tileset: "assets/sprites/space-tileset.png",
                    music: "escape",
                    autoAdvanceAfter: 30.0, // Fly for 30 seconds then auto-advance
                    onStart: function() {
                        trace("Sequence: Escape Flight started");
                    },
                    customData: {}
                },
                {
                    id: "arrival_cutscene",
                    name: "Arrival at Station",
                    mode: Cutscene,
                    music: "arrival",
                    autoAdvanceAfter: 5.0, // 5 second cutscene
                    onStart: function() {
                        trace("Sequence: Arrival Cutscene started");
                    },
                    onEnd: function() {
                        trace("Chapter 1 complete!");
                    },
                    customData: {}
                }
            ],
            onInit: function() {
                trace("Chapter 1: The Exodus initialized!");
            },
            onComplete: function() {
                trace("Chapter 1: The Exodus completed!");
            },
            nextChapter: "ch2_station",
            customData: {
                difficulty: "tutorial"
            }
        });
        
        // Chapter 2: Space Station - Walk around station then cutscene
        register({
            id: "ch2_station",
            name: "Chapter 2: New Home",
            sequences: [
                {
                    id: "land_station",
                    name: "Landing",
                    mode: Cutscene,
                    music: "landing",
                    autoAdvanceAfter: 3.0,
                    onStart: function() {
                        trace("Sequence: Landing started");
                    },
                    customData: {}
                },
                {
                    id: "explore_station",
                    name: "Explore the Station",
                    mode: TiledWalking,
                    map: "assets/maps/station-main.tmx",
                    tileset: "assets/sprites/station-tileset.png",
                    music: "explore",
                    triggerToAdvance: "meet_captain", // Meet the captain trigger
                    onStart: function() {
                        trace("Sequence: Explore Station started");
                    },
                    customData: {}
                }
            ],
            onInit: function() {
                trace("Chapter 2: New Home initialized!");
            },
            onComplete: function() {
                trace("Chapter 2: New Home completed!");
            },
            nextChapter: null, // End of content for now
            customData: {
                difficulty: "easy"
            }
        });
        
        trace('[ChapterRegistry] Initialized with ${chapterOrder.length} chapters');
    }
}
