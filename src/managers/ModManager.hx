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

typedef ModResources =
{
	var ?maps:Array<String>;
	var ?locales:Array<String>;
	var ?sounds:Array<String>;
	var ?sprites:Array<String>;
}

typedef ModCreditItem =
{
	var ?section:String;
	var ?role:String;
	var ?name:String;
	var ?text:String;
}

typedef ModData = {
	var id:String;
	var title:String;
	var description:String;
	var version:String;
	var author:String;
	var api_version:String;
	var ?dependencies:Array<String>;
	var ?conflicts:Array<String>;
	var ?loadAfter:Array<String>;
	var ?priority:Int;
	var ?maps:Array<String>;
	var ?scripts:Array<String>;
	var ?locales:Array<String>;
	var ?sounds:Array<String>;
	var ?sprites:Array<String>;
	var ?resources:ModResources;
	var ?credits:Array<ModCreditItem>;
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
	
	private function processModResources(modData:ModData, modPath:String):Void
	{
		#if sys
		if (modData.resources != null)
		{
			if (modData.resources.maps != null)
			{
				modData.maps = expandWildcards(modPath, modData.resources.maps);
			}
			if (modData.resources.locales != null)
			{
				modData.locales = expandWildcards(modPath, modData.resources.locales);
			}
			if (modData.resources.sounds != null)
			{
				modData.sounds = expandWildcards(modPath, modData.resources.sounds);
			}
			if (modData.resources.sprites != null)
			{
				modData.sprites = expandWildcards(modPath, modData.resources.sprites);
			}
		}

		if (modData.maps == null)
			modData.maps = [];
		if (modData.scripts == null)
			modData.scripts = [];
		if (modData.locales == null)
			modData.locales = [];
		if (modData.sounds == null)
			modData.sounds = [];
		if (modData.sprites == null)
			modData.sprites = [];
		#end
	}

	private function expandWildcards(modPath:String, patterns:Array<String>):Array<String>
	{
		#if sys
		var result:Array<String> = [];

		for (pattern in patterns)
		{
			if (pattern.indexOf("*") != -1)
			{
				var files = findFilesMatchingPattern(modPath, pattern);
				for (file in files)
				{
					result.push(file);
				}
			}
			else
			{
				result.push(pattern);
			}
		}

		return result;
		#else
		return patterns;
		#end
	}

	private function findFilesMatchingPattern(modPath:String, pattern:String):Array<String>
	{
		#if sys
		var result:Array<String> = [];

		var lastSlash = pattern.lastIndexOf("/");
		var dir = lastSlash != -1 ? pattern.substr(0, lastSlash) : "";
		var filePattern = lastSlash != -1 ? pattern.substr(lastSlash + 1) : pattern;

		var fullDir = modPath + "/" + dir;

		if (!FileSystem.exists(fullDir) || !FileSystem.isDirectory(fullDir))
		{
			return result;
		}

		var regexPattern = "^" + StringTools.replace(StringTools.replace(filePattern, ".", "\\."), "*", ".*") + "$";
		var regex = new EReg(regexPattern, "");

		var entries = FileSystem.readDirectory(fullDir);
		for (entry in entries)
		{
			var fullPath = fullDir + "/" + entry;
			if (FileSystem.isDirectory(fullPath))
				continue;

			if (regex.match(entry))
			{
				result.push(entry);
			}
		}

		return result;
		#else
		return [];
		#end
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
				
				processModResources(modData, modPath);

				if (modData.priority == null)
					modData.priority = 0;
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
	public function computeLoadOrder():Array<String>
	{
		var nodes = new Array<{id:String, pri:Int, deps:Array<String>}>();
		var graph = new Map<String, Array<String>>();
		var indeg = new Map<String, Int>();
		inline function getIndeg(key:String):Int
		{
			var v = indeg.get(key);
			return v == null ? 0 : v;
		}
		for (id in mods.keys())
		{
			var m = mods.get(id);
			var deps:Array<String> = [];
			if (m.dependencies != null)
				deps = deps.concat(m.dependencies);
			if (m.loadAfter != null)
				deps = deps.concat(m.loadAfter);
			graph.set(id, []);
			indeg.set(id, 0);
			nodes.push({id: id, pri: m.priority != null ? m.priority : 0, deps: deps});
		}
		for (n in nodes)
		{
			for (d in n.deps)
			{
				if (!mods.exists(d))
					continue;
				var list = graph.get(d);
				list.push(n.id);
				graph.set(d, list);
				indeg.set(n.id, getIndeg(n.id) + 1);
			}
		}
		var queue:Array<String> = [];
		for (id in mods.keys())
		{
			if (getIndeg(id) == 0)
				queue.push(id);
		}
		queue.sort(function(a, b)
		{
			var pa = mods.get(a).priority != null ? mods.get(a).priority : 0;
			var pb = mods.get(b).priority != null ? mods.get(b).priority : 0;
			return pa - pb;
		});
		var order:Array<String> = [];
		while (queue.length > 0)
		{
			var id = queue.shift();
			order.push(id);
			for (nei in graph.get(id))
			{
				var d = getIndeg(nei) - 1;
				indeg.set(nei, d);
				if (d == 0)
				{
					queue.push(nei);
					queue.sort(function(a, b)
					{
						var pa = mods.get(a).priority != null ? mods.get(a).priority : 0;
						var pb = mods.get(b).priority != null ? mods.get(b).priority : 0;
						return pa - pb;
					});
				}
			}
		}
		var __total = 0;
		for (_ in mods.keys())
			__total++;
		if (order.length < __total)
		{
			var remaining = [];
			for (id in mods.keys())
				if (order.indexOf(id) == -1)
					remaining.push(id);
			remaining.sort(function(a, b)
			{
				var pa = mods.get(a).priority != null ? mods.get(a).priority : 0;
				var pb = mods.get(b).priority != null ? mods.get(b).priority : 0;
				return pa - pb;
			});
			for (r in remaining)
				order.push(r);
			trace("[Mods] Warning: dependency cycle detected; using priority order for some mods");
		}
		return order;
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

	public function getModCredits():Array<{modId:String, item:ModCreditItem}>
	{
		var out:Array<{modId:String, item:ModCreditItem}> = [];
		for (id in enabledMods)
		{
			var m = mods.get(id);
			if (m == null)
				continue;

			#if sys
			var creditsPath = getModPath(id) + "/data/credits.json";
			if (sys.FileSystem.exists(creditsPath))
			{
				try
				{
					var content = sys.io.File.getContent(creditsPath);
					var creditsData:{credits:Array<ModCreditItem>} = haxe.Json.parse(content);
					if (creditsData != null && creditsData.credits != null)
					{
						for (c in creditsData.credits)
						{
							out.push({modId: id, item: c});
						}
					}
				}
				catch (e:Dynamic)
				{
					trace("Warning: Failed to parse credits.json for mod " + id + ": " + e);
				}
			}
			else
			#end
			if (m.credits != null)
			{
				for (c in m.credits)
				{
					out.push({modId: id, item: c});
				}
			}
		}
		return out;
	}
}
