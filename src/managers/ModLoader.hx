package managers;

import modding.ModHookLoader;

class ModLoader
{
	private static var initialized:Bool = false;
	
	public static function init(modsDir:String = "mods", autoEnableAll:Bool = true):Void
	{
		if (initialized)
			return;
		
		var modManager = ModManager.getInstance();
		
		trace("=== Initializing Mod System ===");
		trace("Mods directory: " + modsDir);
		
		modManager.discoverMods(modsDir);
		
		if (autoEnableAll)
		{
			var order = modManager.computeLoadOrder();
			var enabled:Array<String> = [];
			for (modId in order)
			{
				var m = modManager.getModData(modId);
				var hasConflict = false;
				if (m != null && m.conflicts != null)
				{
					for (c in m.conflicts)
					{
						if (enabled.indexOf(c) != -1)
						{
							hasConflict = true;
							break;
						}
					}
				}
				if (hasConflict)
				{
					trace('[Mods] Skipping ' + modId + ' due to conflict with an already enabled mod');
					continue;
				}
				if (modManager.enableMod(modId))
				{
					enabled.push(modId);
				}
			}
		}
		
		trace(modManager.getModsSummary());
		ModHookLoader.init();
		
		initialized = true;
		trace("=== Mod System Initialized ===");
	}
	
	public static function isInitialized():Bool
	{
		return initialized;
	}
}
