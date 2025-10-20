package managers;

import flixel.util.FlxSignal;
import haxe.Json;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if js
import openfl.utils.Assets;
#end

typedef ModData = {
	var id:String;
	var title:String;
	var description:String;
	var version:String;
	var author:String;
	var api_version:String;
	var ?dependencies:Array<String>;
	var ?maps:Array<String>;
	var ?data:Array<String>;
	var ?scripts:Array<String>;
}

class ModManager
{
	private static var instance:ModManager;
	
	private var mods:Map<String, ModData> = new Map();
	private var modPaths:Map<String, String> = new Map();
	private var enabledMods:Array<String> = [];
	private var modAssetOverrides:Map<String, String> = new Map();
	
	public var onModLoaded:FlxSignal = new FlxSignal();
	public var onModUnloaded:FlxSignal = new FlxSignal();
	
	private function new()
	{
	}
	
	public static function getInstance():ModManager
	{
		if (instance == null)
			instance = new ModManager();
		return instance;
	}
	
	public function discoverMods(modsDir:String = "mods"):Void
	{
		#if sys
		if (!FileSystem.exists(modsDir))
		{
			trace("Mods directory not found: " + modsDir);
			return;
		}
		
		var entries = FileSystem.readDirectory(modsDir);
		for (entry in entries)
		{
			var modPath = modsDir + "/" + entry;
			if (!FileSystem.isDirectory(modPath))
				continue;
			
			var modJsonPath = modPath + "/mod.json";
			if (!FileSystem.exists(modJsonPath))
				continue;
			
			try
			{
				var jsonContent = File.getContent(modJsonPath);
				var modData:ModData = Json.parse(jsonContent);
				
				mods.set(modData.id, modData);
				modPaths.set(modData.id, modPath);
				trace("Discovered mod: " + modData.id + " v" + modData.version);
			}
			catch (e:Dynamic)
			{
				trace("Error loading mod.json from " + modPath + ": " + e);
			}
		}
		#elseif js
		trace("Polymod discovery not available in JS target");
		#end
	}
	
	public function enableMod(modId:String):Bool
	{
		if (!mods.exists(modId))
		{
			trace("Mod not found: " + modId);
			return false;
		}
		
		if (enabledMods.contains(modId))
		{
			trace("Mod already enabled: " + modId);
			return true;
		}
		
		var mod = mods.get(modId);
		
		if (mod.dependencies != null)
		{
			for (depId in mod.dependencies)
			{
				if (!enabledMods.contains(depId))
				{
					if (!enableMod(depId))
					{
						trace("Failed to enable dependency: " + depId);
						return false;
					}
				}
			}
		}
		
		enabledMods.push(modId);
		trace("Enabled mod: " + modId);
		onModLoaded.dispatch();
		return true;
	}
	
	public function disableMod(modId:String):Bool
	{
		if (!enabledMods.contains(modId))
			return false;
		
		for (enabledId in enabledMods)
		{
			if (enabledId == modId)
				continue;
			
			var mod = mods.get(enabledId);
			if (mod.dependencies != null && mod.dependencies.contains(modId))
			{
				trace("Cannot disable mod " + modId + " - required by " + enabledId);
				return false;
			}
		}
		
		enabledMods.remove(modId);
		trace("Disabled mod: " + modId);
		onModUnloaded.dispatch();
		return true;
	}
	
	public function getAllMods():Map<String, ModData>
	{
		return mods.copy();
	}
	
	public function getEnabledMods():Array<String>
	{
		return enabledMods.copy();
	}
	
	public function isModEnabled(modId:String):Bool
	{
		return enabledMods.indexOf(modId) != -1;
	}
	
	public function getModData(modId:String):Null<ModData>
	{
		return mods.get(modId);
	}
	
	public function getModPath(modId:String):Null<String>
	{
		return modPaths.get(modId);
	}
	
	public function getAvailableMaps():Array<{modId:String, mapId:String, mapPath:String}>
	{
		var maps:Array<{modId:String, mapId:String, mapPath:String}> = [];
		
		for (modId in enabledMods)
		{
			var mod = mods.get(modId);
			if (mod.maps == null)
				continue;
			
			for (mapPath in mod.maps)
			{
				var mapId = haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(mapPath));
				maps.push({
					modId: modId,
					mapId: mapId,
					mapPath: mapPath
				});
			}
		}
		
		return maps;
	}
	
	public function getMapPath(modId:String, mapPath:String):String
	{
		var modPath = modPaths.get(modId);
		if (modPath == null)
			return mapPath;
		
		return modPath + "/assets/maps/" + mapPath;
	}
	
	public function getAssetPath(assetPath:String):String
	{
		var i = enabledMods.length - 1;
		while (i >= 0)
		{
			var modId = enabledMods[i];
			var modPath = modPaths.get(modId);
			if (modPath == null)
			{
				i--;
				continue;
			}
			
			var fullPath = modPath + "/" + assetPath;
			
			#if sys
			if (FileSystem.exists(fullPath))
				return fullPath;
			#end
			
			i--;
		}
		
		return assetPath;
	}
	
	public function hasModFile(modId:String, filePath:String):Bool
	{
		var modPath = modPaths.get(modId);
		if (modPath == null)
			return false;
		
		#if sys
		return FileSystem.exists(modPath + "/" + filePath);
		#elseif js
		return false;
		#end
	}
	
	public function getModFileContent(modId:String, filePath:String):Null<String>
	{
		#if sys
		var modPath = modPaths.get(modId);
		if (modPath == null)
			return null;
		
		var fullPath = modPath + "/" + filePath;
		if (!FileSystem.exists(fullPath))
			return null;
		
		try
		{
			return File.getContent(fullPath);
		}
		catch (e:Dynamic)
		{
			trace("Error reading mod file " + fullPath + ": " + e);
			return null;
		}
		#elseif js
		return null;
		#end
	}
	
	public function loadModData():Map<String, Dynamic>
	{
		var data:Map<String, Dynamic> = new Map();
		
		for (modId in enabledMods)
		{
			var mod = mods.get(modId);
			if (mod.data == null)
				continue;
			
			for (dataFile in mod.data)
			{
				var content = getModFileContent(modId, "assets/data/" + dataFile);
				if (content != null)
				{
					try
					{
						var parsed = Json.parse(content);
						data.set(modId + ":" + dataFile, parsed);
						trace("Loaded data from mod: " + modId + "/" + dataFile);
					}
					catch (e:Dynamic)
					{
						trace("Error parsing data file " + dataFile + " from mod " + modId + ": " + e);
					}
				}
			}
		}
		
		return data;
	}
	
	public function getModsSummary():String
	{
		if (enabledMods.length == 0)
			return "No mods enabled";
		
		var summary = "Enabled mods (" + enabledMods.length + "):\n";
		for (modId in enabledMods)
		{
			var mod = mods.get(modId);
			summary += "  - " + mod.title + " v" + mod.version + " by " + mod.author + "\n";
		}
		return summary;
	}
}
