package utils;

import haxe.Json;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if js
import js.Browser;
#end

typedef SaveData = {
    var username:String;
    var playTimeSeconds:Int; 
}

typedef OptionsData =
{
	var language:String;
	var volume:Float;
	var ?useOldIntroMusic:Bool;
	var ?controls:ControlsData;
}

typedef ControlsData =
{
	var ?moveLeft:String;
	var ?moveRight:String;
	var ?moveUp:String;
	var ?moveDown:String;
	var ?skipDialog:String;
	var ?advanceDialog:String;
	var ?pause:String;
	var ?quit:String;
}

class GameSaveManager {
    public static var saveDir:String = "saves/";
    public static var fileExt:String = ".ccsave";
	private static var optionsFile:String = "options.json";
	private static var optionsKey:String = "cosmic_cities_options";

    
    public static var currentSlot:Int = -1;
    public static var currentData:Null<SaveData> = null;

    
    public static function saveRaw(slotName:String, data:String):Void {
        var path = saveDir + slotName + fileExt;
        #if sys
		try
		{
			if (!FileSystem.exists(saveDir))
				FileSystem.createDirectory(saveDir);
			File.saveContent(path, data);
		}
		catch (e:Dynamic)
		{
			trace("Error saving raw data: " + e);
		}
		#elseif js
		try
		{
			var key = "cosmic_cities_" + slotName;
			Browser.getLocalStorage().setItem(key, data);
		}
		catch (e:Dynamic)
		{
			trace("Error saving to localStorage: " + e);
		}
        #end
    }

    public static function loadRaw(slotName:String):Null<String> {
        var path = saveDir + slotName + fileExt;
        #if sys
		try
		{
			if (FileSystem.exists(path))
			{
				return File.getContent(path);
			}
		}
		catch (e:Dynamic)
		{
			trace("Error loading raw data: " + e);
		}
		#elseif js
		try
		{
			var key = "cosmic_cities_" + slotName;
			return Browser.getLocalStorage().getItem(key);
		}
		catch (e:Dynamic)
		{
			trace("Error loading from localStorage: " + e);
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
		#elseif js
		var key = "cosmic_cities_" + slotName;
		Browser.getLocalStorage().removeItem(key);
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
		#elseif js
		var storage = Browser.getLocalStorage();
		for (i in 0...storage.length)
		{
			var key = storage.key(i);
			if (key != null && StringTools.startsWith(key, "cosmic_cities_"))
			{
				var slotName = key.substr(14);
				if (StringTools.endsWith(slotName, fileExt))
				{
					saves.push(slotName.substr(0, slotName.length - fileExt.length));
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
		#elseif js
		var key = "cosmic_cities_" + slotName(slot);
		return Browser.getLocalStorage().getItem(key) != null;
        #else
        return false;
        #end
    }

    public static function saveData(slot:Int, data:SaveData):Void {
        #if sys
        if (!FileSystem.exists(saveDir)) FileSystem.createDirectory(saveDir);
        var json = Json.stringify(data);
        File.saveContent(slotPath(slot), json);
		#elseif js
		var json = Json.stringify(data);
		var key = "cosmic_cities_" + slotName(slot);
		Browser.getLocalStorage().setItem(key, json);
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
		#elseif js
		var key = "cosmic_cities_" + slotName(slot);
		var json = Browser.getLocalStorage().getItem(key);
		if (json != null)
		{
			try
			{
				var obj:Dynamic = Json.parse(json);
				var prev:Null<SaveData> = currentData;
				var totalTime:Int = obj.playTimeSeconds;
				if (prev != null && slot == currentSlot)
				{
					totalTime += prev.playTimeSeconds;
				}
				var d:SaveData = {username: obj.username, playTimeSeconds: totalTime};
				return d;
			}
			catch (_:Dynamic)
			{
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
		#elseif js
		var key = "cosmic_cities_" + slotName(slot);
		Browser.getLocalStorage().removeItem(key);
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
	public static function saveOptions(options:OptionsData):Void
	{
		#if sys
		if (!FileSystem.exists(saveDir))
			FileSystem.createDirectory(saveDir);
		var json = Json.stringify(options);
		File.saveContent(saveDir + optionsFile, json);
		#elseif js
		var json = Json.stringify(options);
		Browser.getLocalStorage().setItem(optionsKey, json);
		#end
		trace("Options saved: language=" + options.language + " volume=" + options.volume);
	}

	public static function loadOptions():Null<OptionsData>
	{
		#if sys
		var path = saveDir + optionsFile;
		if (FileSystem.exists(path))
		{
			try
			{
				var json = File.getContent(path);
				var parsed:Dynamic = Json.parse(json);
				if (parsed != null && parsed.language != null && parsed.volume != null)
				{
					var options:OptionsData = {
						language: parsed.language,
						volume: parsed.volume,
						useOldIntroMusic: parsed.useOldIntroMusic == true
					};
					if (parsed.controls != null)
						options.controls = parsed.controls;
					trace("Options loaded from file: language=" + options.language + " volume=" + options.volume + " useOldIntroMusic="
						+ options.useOldIntroMusic + " controls=" + (options.controls != null ? "yes" : "no"));
					return options;
				}
			}
			catch (_:Dynamic)
			{
				trace("Error loading options from file");
				return null;
			}
		}
		#elseif js
		var json = Browser.getLocalStorage().getItem(optionsKey);
		if (json != null)
		{
			try
			{
				var parsed:Dynamic = Json.parse(json);
				if (parsed != null && parsed.language != null && parsed.volume != null)
				{
					var options:OptionsData = {
						language: parsed.language,
						volume: parsed.volume,
						useOldIntroMusic: parsed.useOldIntroMusic == true
					};
					if (parsed.controls != null)
						options.controls = parsed.controls;
					trace("Options loaded from localStorage: language=" + options.language + " volume=" + options.volume
						+ " useOldIntroMusic=" + options.useOldIntroMusic + " controls=" + (options.controls != null ? "yes" : "no"));
					return options;
				}
			}
			catch (_:Dynamic)
			{
				trace("Error loading options from localStorage");
				return null;
			}
		}
		#end
		return null;
	}

	public static function loadOptionsWithDefaults():OptionsData
	{
		var options = loadOptions();
		if (options != null)
		{
			// Ensure useOldIntroMusic has a default if not set
			if (options.useOldIntroMusic == null) {
				options.useOldIntroMusic = false;
			}
			return options;
		}
		var defaults:OptionsData = {language: "en-US", volume: 1.0, useOldIntroMusic: false};
		trace("Using default options: language=" + defaults.language + " volume=" + defaults.volume + " useOldIntroMusic=" + defaults.useOldIntroMusic);
		return defaults;
	}

	public static function deleteOptions():Void
	{
		#if sys
		var path = saveDir + optionsFile;
		if (FileSystem.exists(path))
		{
			FileSystem.deleteFile(path);
		}
		#elseif js
		Browser.getLocalStorage().removeItem(optionsKey);
		#end
	}
	public static function getDefaultControls():ControlsData
	{
		return {
			moveLeft: "LEFT",
			moveRight: "RIGHT",
			moveUp: "UP",
			moveDown: "DOWN",
			skipDialog: "X",
			advanceDialog: "ENTER",
			pause: "P",
			quit: "BACKSPACE"
		};
	}

	public static function getControls():ControlsData
	{
		var options = loadOptions();
		if (options != null && options.controls != null)
		{
			return options.controls;
		}
		return getDefaultControls();
	}

	public static function saveControls(controls:ControlsData):Void
	{
		var options = loadOptionsWithDefaults();
		options.controls = controls;
		saveOptions(options);
		trace("Controls saved");
	}
}
