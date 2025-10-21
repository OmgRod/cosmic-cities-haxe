package modding;

import hscript.Interp;
import hscript.Parser;
import managers.ModManager;

class ModHookLoader
{
	private static var initialized:Bool = false;

	public static function init():Void
	{
		if (initialized)
		{
			return;
		}

		var modManager = ModManager.getInstance();
		modManager.onModLoaded.add(onModsChanged);
		modManager.onModUnloaded.add(onModsChanged);

		reloadHooks();
		initialized = true;
	}

	public static function reloadHooks():Void
	{
		var modManager = ModManager.getInstance();
		ModHooks.clearModHooks();

		var enabledMods = modManager.getEnabledMods();
		for (modId in enabledMods)
		{
			loadHooksForMod(modId);
		}
	}

	private static function loadHooksForMod(modId:String):Void
	{
		var modManager = ModManager.getInstance();
		var mod = modManager.getModData(modId);
		if (mod == null || mod.scripts == null)
		{
			return;
		}

		for (scriptFile in mod.scripts)
		{
			var content = modManager.getModFileContent(modId, "scripts/" + scriptFile);
			if (content == null)
			{
				trace("[ModHooks] Script not found for mod " + modId + ": " + scriptFile);
				continue;
			}

			try
			{
				var parser = new Parser();
				parser.allowTypes = true;
				parser.allowJSON = true;
				var program = parser.parseString(content, scriptFile);
				var interp = new Interp();
				ModScriptBindings.apply(interp, modId);
				interp.execute(program);
				trace("[ModHooks] Loaded script " + scriptFile + " from mod " + modId);
			}
			catch (e:Dynamic)
			{
				trace("[ModHooks] Error loading script " + scriptFile + " from mod " + modId + ": " + e);
			}
		}
	}

	private static function onModsChanged():Void
	{
		reloadHooks();
	}
}
