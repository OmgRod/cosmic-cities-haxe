package managers;

typedef EventData = {
    ?targetId:String,
    ?value:Dynamic,
    ?data:Dynamic
}

typedef EventListener = EventData->Void;

class EventManager {
    private static var instance:EventManager;
    private var listeners:Map<String, Array<EventListener>>;
    private var eventHistory:Array<{event:String, timestamp:Float}>;
    
    public static function getInstance():EventManager {
        if (instance == null) {
            instance = new EventManager();
        }
        return instance;
    }
    
    private function new() {
        listeners = new Map();
        eventHistory = [];
    }
    
    public function on(eventName:String, callback:EventListener):Void {
        if (!listeners.exists(eventName)) {
            listeners.set(eventName, []);
        }
        listeners.get(eventName).push(callback);
    }
    
    public function off(eventName:String, callback:EventListener):Void {
        if (!listeners.exists(eventName)) return;
        var list = listeners.get(eventName);
        list.remove(callback);
    }
    
    public function once(eventName:String, callback:EventListener):Void {
        var wrappedCallback:EventListener = null;
        wrappedCallback = (data:EventData) -> {
            callback(data);
            off(eventName, wrappedCallback);
        };
        on(eventName, wrappedCallback);
    }
    
    public function emit(eventName:String, ?data:EventData):Void {
        eventHistory.push({event: eventName, timestamp: haxe.Timer.stamp()});
        
        if (listeners.exists(eventName)) {
            var list = listeners.get(eventName).copy();
            for (listener in list) {
                listener(data != null ? data : {});
            }
        }
    }
    
    public function hasListeners(eventName:String):Bool {
        return listeners.exists(eventName) && listeners.get(eventName).length > 0;
    }
    
    public function clear():Void {
        listeners = new Map();
        eventHistory = [];
    }
    
    public function getHistory():Array<{event:String, timestamp:Float}> {
        return eventHistory.copy();
    }
    
    public function wasEventFired(eventName:String):Bool {
        for (entry in eventHistory) {
            if (entry.event == eventName) return true;
        }
        return false;
    }
}
