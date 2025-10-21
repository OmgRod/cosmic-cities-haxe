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
			var allMods = modManager.getAllMods();
			for (modId in allMods.keys())
			{
				modManager.enableMod(modId);
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
