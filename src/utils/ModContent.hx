package utils;

import haxe.Json;
import managers.ModManager;

class ModContent
{
	public static function loadJSON(filePath:String, ?modId:String):Null<Dynamic>
	{
		var modManager = ModManager.getInstance();
		var content:String = null;
		
		if (modId != null)
		{
			content = modManager.getModFileContent(modId, filePath);
		}
		else
		{
			var enabledMods = modManager.getEnabledMods();
			var i = enabledMods.length - 1;
			while (i >= 0)
			{
				var currentModId = enabledMods[i];
				content = modManager.getModFileContent(currentModId, filePath);
				if (content != null)
					break;
				i--;
			}
		}
		
		if (content == null)
			return null;
		
		try
		{
			return Json.parse(content);
		}
		catch (e:Dynamic)
		{
			trace("Error parsing JSON from " + filePath + ": " + e);
			return null;
		}
	}
	
	public static function getSpritePath(relativePath:String, ?modId:String):String
	{
		var modManager = ModManager.getInstance();
		
		if (modId != null)
		{
			if (modManager.hasModFile(modId, "assets/sprites/" + relativePath))
				return modManager.getModPath(modId) + "/assets/sprites/" + relativePath;
		}
		else
		{
			var enabledMods = modManager.getEnabledMods();
			var i = enabledMods.length - 1;
			while (i >= 0)
			{
				var currentModId = enabledMods[i];
				if (modManager.hasModFile(currentModId, "assets/sprites/" + relativePath))
					return modManager.getModPath(currentModId) + "/assets/sprites/" + relativePath;
				i--;
			}
		}
		
		return "assets/sprites/" + relativePath;
	}
	
	public static function getSoundPath(relativePath:String, ?modId:String):String
	{
		var modManager = ModManager.getInstance();
		
		if (modId != null)
		{
			if (modManager.hasModFile(modId, "assets/sounds/" + relativePath))
				return modManager.getModPath(modId) + "/assets/sounds/" + relativePath;
		}
		else
		{
			var enabledMods = modManager.getEnabledMods();
			var i = enabledMods.length - 1;
			while (i >= 0)
			{
				var currentModId = enabledMods[i];
				if (modManager.hasModFile(currentModId, "assets/sounds/" + relativePath))
					return modManager.getModPath(currentModId) + "/assets/sounds/" + relativePath;
				i--;
			}
		}
		
		return "assets/sounds/" + relativePath;
	}
	
	public static function getAvailableLevels():Array<LevelInfo>
	{
		var modManager = ModManager.getInstance();
		var levels:Array<LevelInfo> = [];
		
		var maps = modManager.getAvailableMaps();
		for (map in maps)
		{
			levels.push({
				id: map.mapId,
				name: formatMapName(map.mapId),
				modId: map.modId,
				mapPath: map.mapPath
			});
		}
		
		return levels;
	}
	
	private static function formatMapName(mapId:String):String
	{
		var formatted = mapId.split("-").map(function(word:String)
		{
			return word.charAt(0).toUpperCase() + word.substr(1).toLowerCase();
		}).join(" ");
		
		return formatted;
	}
}

typedef LevelInfo = {
	var id:String;
	var name:String;
	var modId:String;
	var mapPath:String;
}
