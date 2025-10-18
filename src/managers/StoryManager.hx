package managers;

import managers.EventManager;
import utils.GameSaveManager;

typedef StoryFlag = {
    var name:String;
    var value:Dynamic;
    var timestamp:Float;
}

class StoryManager {
    private static var instance:StoryManager;
    
    private var flags:Map<String, Dynamic>;
    private var currentChapter:String;
    private var currentScene:String;
    private var completedScenes:Array<String>;
    private var eventManager:EventManager;
    
    public static function getInstance():StoryManager {
        if (instance == null) {
            instance = new StoryManager();
        }
        return instance;
    }
    
    private function new() {
        flags = new Map();
        completedScenes = [];
        currentChapter = "prologue";
        currentScene = "intro";
        eventManager = EventManager.getInstance();
        
        setupStoryEvents();
    }
    
    private function setupStoryEvents():Void {
        eventManager.on("story:sceneComplete", (data) -> {
            if (data.targetId != null) {
                completeScene(data.targetId);
            }
        });
        
        eventManager.on("story:chapterComplete", (data) -> {
            if (data.targetId != null) {
                trace('Chapter completed: ${data.targetId}');
            }
        });
    }
    
    public function setFlag(name:String, value:Dynamic):Void {
        flags.set(name, value);
        eventManager.emit("story:flagSet", {targetId: name, value: value});
    }
    
    public function getFlag(name:String, ?defaultValue:Dynamic):Dynamic {
        return flags.exists(name) ? flags.get(name) : defaultValue;
    }
    
    public function hasFlag(name:String):Bool {
        return flags.exists(name);
    }
    
    public function removeFlag(name:String):Void {
        flags.remove(name);
    }
    
    public function checkCondition(condition:String):Bool {
        var parts = condition.split(" ");
        if (parts.length < 3) return false;
        
        var flagName = parts[0];
        var op = parts[1];
        var compareValue = parts[2];
        
        if (!hasFlag(flagName)) return false;
        
        var flagValue = getFlag(flagName);
        
        switch (op) {
            case "==": return Std.string(flagValue) == compareValue;
            case "!=": return Std.string(flagValue) != compareValue;
            case ">": return Std.parseFloat(Std.string(flagValue)) > Std.parseFloat(compareValue);
            case "<": return Std.parseFloat(Std.string(flagValue)) < Std.parseFloat(compareValue);
            case ">=": return Std.parseFloat(Std.string(flagValue)) >= Std.parseFloat(compareValue);
            case "<=": return Std.parseFloat(Std.string(flagValue)) <= Std.parseFloat(compareValue);
            default: return false;
        }
    }
    
    public function setChapter(chapter:String):Void {
        currentChapter = chapter;
        eventManager.emit("story:chapterChanged", {targetId: chapter});
    }
    
    public function setScene(scene:String):Void {
        currentScene = scene;
        eventManager.emit("story:sceneChanged", {targetId: scene});
    }
    
    public function completeScene(scene:String):Void {
        if (!completedScenes.contains(scene)) {
            completedScenes.push(scene);
            eventManager.emit("story:sceneCompleted", {targetId: scene});
        }
    }
    
    public function isSceneCompleted(scene:String):Bool {
        return completedScenes.contains(scene);
    }
    
    public function getCurrentChapter():String {
        return currentChapter;
    }
    
    public function getCurrentScene():String {
        return currentScene;
    }
    
    public function saveToData():{flags:Map<String, Dynamic>, chapter:String, scene:String, completed:Array<String>} {
        return {
            flags: flags,
            chapter: currentChapter,
            scene: currentScene,
            completed: completedScenes
        };
    }
    
    public function loadFromData(data:{flags:Map<String, Dynamic>, chapter:String, scene:String, completed:Array<String>}):Void {
        flags = data.flags;
        currentChapter = data.chapter;
        currentScene = data.scene;
        completedScenes = data.completed;
    }
    
    public function reset():Void {
        flags = new Map();
        completedScenes = [];
        currentChapter = "prologue";
        currentScene = "intro";
    }
}
