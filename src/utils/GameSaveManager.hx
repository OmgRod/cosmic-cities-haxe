package utils;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

typedef SaveData = {
    var username:String;
    var playTimeSeconds:Int; 
}

class GameSaveManager {
    public static var saveDir:String = "saves/";
    public static var fileExt:String = ".ccsave";

    
    public static var currentSlot:Int = -1;
    public static var currentData:Null<SaveData> = null;

    
    public static function saveRaw(slotName:String, data:String):Void {
        var path = saveDir + slotName + fileExt;
        #if sys
        if (!FileSystem.exists(saveDir)) FileSystem.createDirectory(saveDir);
        File.saveContent(path, data);
        #end
    }

    public static function loadRaw(slotName:String):Null<String> {
        var path = saveDir + slotName + fileExt;
        #if sys
        if (FileSystem.exists(path)) {
            return File.getContent(path);
        }
        #end
        return null;
    }

    public static function deleteRaw(slotName:String):Void {
        var path = saveDir + slotName + fileExt;
        #if sys
        if (FileSystem.exists(path)) {
            FileSystem.deleteFile(path);
        }
        #end
    }

    public static function listSaves():Array<String> {
        var saves:Array<String> = [];
        #if sys
        if (FileSystem.exists(saveDir)) {
            var files = FileSystem.readDirectory(saveDir);
            for (i in 0...files.length) {
                var file = files[i];
                if (StringTools.endsWith(file, fileExt)) {
                    saves.push(file.substr(0, file.length - fileExt.length));
                }
            }
        }
        #end
        return saves;
    }

    
    static inline function slotName(slot:Int):String return 'slot' + slot;
    static inline function slotPath(slot:Int):String return saveDir + slotName(slot) + fileExt;

    public static function exists(slot:Int):Bool {
        #if sys
        return FileSystem.exists(slotPath(slot));
        #else
        return false;
        #end
    }

    public static function saveData(slot:Int, data:SaveData):Void {
        #if sys
        if (!FileSystem.exists(saveDir)) FileSystem.createDirectory(saveDir);
        var json = Json.stringify(data);
        File.saveContent(slotPath(slot), json);
        #end
    }

    public static function loadData(slot:Int):Null<SaveData> {
        #if sys
        var path = slotPath(slot);
        if (FileSystem.exists(path)) {
            var json = File.getContent(path);
            try {
                var obj:Dynamic = Json.parse(json);
				var prev:Null<SaveData> = currentData;
				var totalTime:Int = obj.playTimeSeconds;
				if (prev != null && slot == currentSlot)
				{
					totalTime += prev.playTimeSeconds;
				}
				var d:SaveData = {username: obj.username, playTimeSeconds: totalTime};
				return d;
            } catch (_:Dynamic) {
                return null;
            }
        }
        #end
        return null;
    }

    public static function delete(slot:Int):Void {
        #if sys
        var path = slotPath(slot);
        if (FileSystem.exists(path)) FileSystem.deleteFile(path);
        #end
    }

    public static function setCurrent(slot:Int, data:SaveData):Void {
        currentSlot = slot;
        currentData = data;
    }

    public static function clearCurrent():Void {
        currentSlot = -1;
        currentData = null;
    }

    public static function formatDuration(seconds:Int):String {
        if (seconds < 0) seconds = 0;
        var h = Std.int(seconds / 3600);
        var m = Std.int((seconds % 3600) / 60);
        var s = seconds % 60;
        function pad(n:Int):String return (n < 10 ? '0' : '') + n;
        return h > 0 ? (pad(h) + ':' + pad(m) + ':' + pad(s)) : (pad(m) + ':' + pad(s));
    }
}
