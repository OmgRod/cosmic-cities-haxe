package managers;

import managers.EventManager;
import managers.StoryManager;

typedef InteractableObject = {
    var id:String;
    var name:String;
    var description:String;
    var ?interactionText:String;
    var ?requiredFlag:String;
    var ?onInteract:Void->Void;
    var ?dialogueId:String;
    var ?eventId:String;
    var ?oneTime:Bool;
    var ?interacted:Bool;
}

class InteractionManager {
    private static var instance:InteractionManager;
    
    private var objects:Map<String, InteractableObject>;
    private var eventManager:EventManager;
    private var storyManager:StoryManager;
    
    public static function getInstance():InteractionManager {
        if (instance == null) {
            instance = new InteractionManager();
        }
        return instance;
    }
    
    private function new() {
        objects = new Map();
        eventManager = EventManager.getInstance();
        storyManager = StoryManager.getInstance();
    }
    
    public function registerObject(obj:InteractableObject):Void {
        if (obj.interacted == null) obj.interacted = false;
        objects.set(obj.id, obj);
        eventManager.emit("interaction:objectRegistered", {targetId: obj.id});
    }
    
    public function unregisterObject(id:String):Void {
        objects.remove(id);
        eventManager.emit("interaction:objectUnregistered", {targetId: id});
    }
    
    public function interact(objectId:String):Bool {
        if (!objects.exists(objectId)) {
            trace('Interactable object not found: $objectId');
            return false;
        }
        
        var obj = objects.get(objectId);
        
        if (obj.oneTime == true && obj.interacted == true) {
            trace('Object already interacted: $objectId');
            return false;
        }
        
        if (obj.requiredFlag != null && !storyManager.hasFlag(obj.requiredFlag)) {
            trace('Missing required flag: ${obj.requiredFlag}');
            eventManager.emit("interaction:failed", {targetId: objectId, data: "missing_flag"});
            return false;
        }
        
        obj.interacted = true;
        
        if (obj.onInteract != null) {
            obj.onInteract();
        }
        
        if (obj.eventId != null) {
            eventManager.emit(obj.eventId, {targetId: objectId});
        }
        
        eventManager.emit("interaction:success", {targetId: objectId, data: obj});
        
        return true;
    }
    
    public function getObject(id:String):InteractableObject {
        return objects.get(id);
    }
    
    public function isInteractable(objectId:String):Bool {
        if (!objects.exists(objectId)) return false;
        
        var obj = objects.get(objectId);
        
        if (obj.oneTime == true && obj.interacted == true) {
            return false;
        }
        
        if (obj.requiredFlag != null && !storyManager.hasFlag(obj.requiredFlag)) {
            return false;
        }
        
        return true;
    }
    
    public function getAllObjects():Array<InteractableObject> {
        var list:Array<InteractableObject> = [];
        for (obj in objects) {
            list.push(obj);
        }
        return list;
    }
    
    public function getInteractableObjects():Array<InteractableObject> {
        var list:Array<InteractableObject> = [];
        for (obj in objects) {
            if (isInteractable(obj.id)) {
                list.push(obj);
            }
        }
        return list;
    }
    
    public function reset():Void {
        for (obj in objects) {
            obj.interacted = false;
        }
    }
    
    public function clear():Void {
        objects = new Map();
    }
}
