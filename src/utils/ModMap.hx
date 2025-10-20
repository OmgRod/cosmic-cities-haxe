package utils;

import haxe.Json;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class ModMap
{
	public static function loadTmx(mapPath:String, ?modId:String):Null<String>
	{
		var modManager = managers.ModManager.getInstance();
		
		if (modId != null)
		{
			return modManager.getModFileContent(modId, "assets/maps/" + mapPath);
		}
		
		var enabledMods = modManager.getEnabledMods();
		var i = enabledMods.length - 1;
		while (i >= 0)
		{
			var currentModId = enabledMods[i];
			var content = modManager.getModFileContent(currentModId, "assets/maps/" + mapPath);
			if (content != null)
				return content;
			i--;
		}
		
		#if sys
		var basePath = "assets/maps/" + mapPath;
		if (FileSystem.exists(basePath))
		{
			return File.getContent(basePath);
		}
		#elseif js
		try
		{
			return openfl.utils.Assets.getText("assets/maps/" + mapPath);
		}
		catch (e:Dynamic)
		{
			return null;
		}
		#end
		
		return null;
	}
	
	public static function loadTilesetImage(imagePath:String, ?modId:String):Null<String>
	{
		var modManager = managers.ModManager.getInstance();
		
		if (modId != null)
		{
			var fullPath = "assets/sprites/" + imagePath;
			return modManager.getModFileContent(modId, fullPath);
		}
		
		var enabledMods = modManager.getEnabledMods();
		var i = enabledMods.length - 1;
		while (i >= 0)
		{
			var currentModId = enabledMods[i];
			var content = modManager.getModFileContent(currentModId, "assets/sprites/" + imagePath);
			if (content != null)
				return content;
			i--;
		}
		
		return modManager.getAssetPath("assets/sprites/" + imagePath);
	}
	
	public static function getMapPath(mapPath:String, ?modId:String):String
	{
		var modManager = managers.ModManager.getInstance();
		
		if (modId != null)
		{
			return modManager.getMapPath(modId, mapPath);
		}
		
		var enabledMods = modManager.getEnabledMods();
		var i = enabledMods.length - 1;
		while (i >= 0)
		{
			var currentModId = enabledMods[i];
			var fullPath = modManager.getMapPath(currentModId, mapPath);
			
			#if sys
			if (sys.FileSystem.exists(fullPath))
				return fullPath;
			#end
			
			i--;
		}
		
		return "assets/maps/" + mapPath;
	}
}
