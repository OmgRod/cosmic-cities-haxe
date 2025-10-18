package managers;

import haxe.Json;
import managers.DialogueManager;
import managers.EventManager;
import managers.InteractionManager;
import managers.StoryManager;
import utils.GameSaveManager;

typedef GameData = {
    var story:Dynamic;
    var playTime:Int;
    var username:String;
}

class GameManager {
    private static var instance:GameManager;
    
    private var eventManager:EventManager;
    private var storyManager:StoryManager;
    private var dialogueManager:DialogueManager;
    private var interactionManager:InteractionManager;
    
    private var gameStartTime:Float;
    private var totalPlayTime:Int;
    private var isPaused:Bool;
    
    public static function getInstance():GameManager {
        if (instance == null) {
            instance = new GameManager();
        }
        return instance;
    }
    
    private function new() {
        eventManager = EventManager.getInstance();
        storyManager = StoryManager.getInstance();
        dialogueManager = DialogueManager.getInstance();
        interactionManager = InteractionManager.getInstance();
        
        totalPlayTime = 0;
        isPaused = false;
        
        setupGameEvents();
    }
    
    private function setupGameEvents():Void {
        eventManager.on("game:start", (data) -> {
            gameStartTime = haxe.Timer.stamp();
            trace("Game started");
        });
        
        eventManager.on("game:pause", (data) -> {
            isPaused = true;
            updatePlayTime();
        });
        
        eventManager.on("game:resume", (data) -> {
            isPaused = false;
            gameStartTime = haxe.Timer.stamp();
        });
        
        eventManager.on("game:quit", (data) -> {
            updatePlayTime();
            saveGame();
        });
    }
    
    public function startNewGame(username:String):Void {
        storyManager.reset();
        interactionManager.reset();
        eventManager.clear();
        
        setupGameEvents();
        
        totalPlayTime = 0;
        gameStartTime = haxe.Timer.stamp();
        isPaused = false;
        
        if (GameSaveManager.currentSlot > 0) {
            GameSaveManager.saveData(GameSaveManager.currentSlot, {
                username: username,
                playTimeSeconds: 0
            });
        }
        
        eventManager.emit("game:start", {});
    }
    
    public function loadGame(slot:Int):Bool {
        var saveData = GameSaveManager.loadData(slot);
        if (saveData == null) return false;
        
        totalPlayTime = saveData.playTimeSeconds;
        gameStartTime = haxe.Timer.stamp();
        isPaused = false;
        
        GameSaveManager.setCurrent(slot, saveData);
        
        eventManager.emit("game:loaded", {targetId: Std.string(slot)});
        return true;
    }
    
    public function saveGame():Bool {
        if (GameSaveManager.currentSlot <= 0) {
            trace("No save slot selected");
            return false;
        }
        
        updatePlayTime();
        
        var currentData = GameSaveManager.currentData;
        if (currentData == null) {
            trace("No current save data");
            return false;
        }
        
        GameSaveManager.saveData(GameSaveManager.currentSlot, {
            username: currentData.username,
            playTimeSeconds: totalPlayTime
        });
        
        eventManager.emit("game:saved", {});
        trace('Game saved to slot ${GameSaveManager.currentSlot}');
        return true;
    }
    
    private function updatePlayTime():Void {
        if (!isPaused && gameStartTime > 0) {
            var elapsed = Std.int(haxe.Timer.stamp() - gameStartTime);
            totalPlayTime += elapsed;
            gameStartTime = haxe.Timer.stamp();
        }
    }
    
    public function getPlayTime():Int {
        updatePlayTime();
        return totalPlayTime;
    }
    
    public function pauseGame():Void {
        eventManager.emit("game:pause", {});
    }
    
    public function resumeGame():Void {
        eventManager.emit("game:resume", {});
    }
    
    public function quitToMenu():Void {
        eventManager.emit("game:quit", {});
    }
    
    public function getEventManager():EventManager {
        return eventManager;
    }
    
    public function getStoryManager():StoryManager {
        return storyManager;
    }
    
    public function getDialogueManager():DialogueManager {
        return dialogueManager;
    }
    
    public function getInteractionManager():InteractionManager {
        return interactionManager;
    }
}
