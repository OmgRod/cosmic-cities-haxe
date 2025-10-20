package utils;

import flixel.FlxState;
import flixel.text.FlxBitmapText;
import managers.ModManager;

class ModIntegration
{
	public static function getModWelcomeMessage():String
	{
		var modManager = ModManager.getInstance();
		var enabledMods = modManager.getEnabledMods();
		
		if (enabledMods.length == 0)
			return "No mods enabled";
		
		var messages:Array<String> = [];
		for (modId in enabledMods)
		{
			var modData = modManager.getModData(modId);
			if (modData != null)
			{
				messages.push('${modData.title} v${modData.version}');
			}
		}
		
		return "Active mods: " + messages.join(", ");
	}
	
	public static function isExampleModEnabled():Bool
	{
		var modManager = ModManager.getInstance();
		return modManager.isModEnabled("example-mod");
	}
	
	public static function getAvailableCustomMaps():Array<CustomMapInfo>
	{
		var modManager = ModManager.getInstance();
		var maps:Array<CustomMapInfo> = [];
		
		var enabledMods = modManager.getEnabledMods();
		for (modId in enabledMods)
		{
			var modData = modManager.getModData(modId);
			if (modData != null && modData.maps != null)
			{
				for (mapFile in modData.maps)
				{
					maps.push({
						name: mapFile.split(".")[0],
						file: mapFile,
						modId: modId,
						modTitle: modData.title
					});
				}
			}
		}
		
		return maps;
	}
	
	public static function applyModCosmetics(state:FlxState):Void
	{
		var modManager = ModManager.getInstance();
		
		if (modManager.isModEnabled("example-mod"))
		{
			trace("Example Mod: Custom cosmetics applied!");
		}
	}
	
	public static function getModConfig(modId:String, configFile:String):Null<Dynamic>
	{
		return ModContent.loadJSON(configFile, modId);
	}
}

typedef CustomMapInfo = {
	var name:String;
	var file:String;
	var modId:String;
	var modTitle:String;
}
