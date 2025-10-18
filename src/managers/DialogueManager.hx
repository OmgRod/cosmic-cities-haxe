package managers;

import managers.EventManager;
import managers.StoryManager;

typedef DialogueLine = {
    var speaker:String;
    var text:String;
    var ?emotion:String;
    var ?choices:Array<DialogueChoice>;
    var ?condition:String;
    var ?event:String;
    var ?nextId:String;
}

typedef DialogueChoice = {
    var text:String;
    var nextId:String;
    var ?condition:String;
    var ?event:String;
}

typedef DialogueTree = {
    var id:String;
    var lines:Map<String, DialogueLine>;
    var startId:String;
}

class DialogueManager {
    private static var instance:DialogueManager;
    
    private var dialogueTrees:Map<String, DialogueTree>;
    private var currentTree:DialogueTree;
    private var currentLineId:String;
    private var eventManager:EventManager;
    private var storyManager:StoryManager;
    
    public var onDialogueStart:Void->Void;
    public var onDialogueEnd:Void->Void;
    public var onLineChanged:DialogueLine->Void;
    
    public static function getInstance():DialogueManager {
        if (instance == null) {
            instance = new DialogueManager();
        }
        return instance;
    }
    
    private function new() {
        dialogueTrees = new Map();
        eventManager = EventManager.getInstance();
        storyManager = StoryManager.getInstance();
    }
    
    public function registerDialogue(tree:DialogueTree):Void {
        dialogueTrees.set(tree.id, tree);
    }
    
    public function startDialogue(treeId:String):Bool {
        if (!dialogueTrees.exists(treeId)) {
            trace('Dialogue tree not found: $treeId');
            return false;
        }
        
        currentTree = dialogueTrees.get(treeId);
        currentLineId = currentTree.startId;
        
        if (onDialogueStart != null) onDialogueStart();
        eventManager.emit("dialogue:started", {targetId: treeId});
        
        showCurrentLine();
        return true;
    }
    
    public function advance(?choiceIndex:Int):Void {
        if (currentTree == null || currentLineId == null) return;
        
        var line = getCurrentLine();
        if (line == null) {
            endDialogue();
            return;
        }
        
        if (line.event != null) {
            eventManager.emit(line.event, {targetId: currentTree.id});
        }
        
        var nextId:String = null;
        
        if (choiceIndex != null && line.choices != null && choiceIndex < line.choices.length) {
            var choice = line.choices[choiceIndex];
            if (choice.condition == null || storyManager.checkCondition(choice.condition)) {
                nextId = choice.nextId;
                if (choice.event != null) {
                    eventManager.emit(choice.event, {targetId: currentTree.id, value: choiceIndex});
                }
            }
        } else {
            nextId = line.nextId;
        }
        
        if (nextId == null || nextId == "end") {
            endDialogue();
            return;
        }
        
        currentLineId = nextId;
        showCurrentLine();
    }
    
    public function getCurrentLine():DialogueLine {
        if (currentTree == null || currentLineId == null) return null;
        
        var line = currentTree.lines.get(currentLineId);
        
        if (line != null && line.condition != null) {
            if (!storyManager.checkCondition(line.condition)) {
                if (line.nextId != null) {
                    currentLineId = line.nextId;
                    return getCurrentLine();
                }
                return null;
            }
        }
        
        return line;
    }
    
    public function getAvailableChoices():Array<DialogueChoice> {
        var line = getCurrentLine();
        if (line == null || line.choices == null) return [];
        
        var available:Array<DialogueChoice> = [];
        for (choice in line.choices) {
            if (choice.condition == null || storyManager.checkCondition(choice.condition)) {
                available.push(choice);
            }
        }
        return available;
    }
    
    private function showCurrentLine():Void {
        var line = getCurrentLine();
        if (line != null) {
            if (onLineChanged != null) onLineChanged(line);
            eventManager.emit("dialogue:lineChanged", {data: line});
        } else {
            endDialogue();
        }
    }
    
    private function endDialogue():Void {
        var treeId = currentTree != null ? currentTree.id : "unknown";
        currentTree = null;
        currentLineId = null;
        
        if (onDialogueEnd != null) onDialogueEnd();
        eventManager.emit("dialogue:ended", {targetId: treeId});
    }
    
    public function isActive():Bool {
        return currentTree != null;
    }
    
    public function getCurrentTreeId():String {
        return currentTree != null ? currentTree.id : null;
    }
}
