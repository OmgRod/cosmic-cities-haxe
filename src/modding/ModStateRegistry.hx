package modding;

import flixel.FlxState;

class ModStateRegistry
{
	private static var customStates:Map<String, Class<FlxState>> = new Map();
	
	public static function register(id:String, stateClass:Class<FlxState>):Void
	{
		if (customStates.exists(id))
		{
			trace("Warning: Overwriting existing custom state: " + id);
		}
		customStates.set(id, stateClass);
		trace("Registered custom state: " + id);
	}
	
	public static function unregister(id:String):Void
	{
		if (customStates.remove(id))
		{
			trace("Unregistered custom state: " + id);
		}
	}
	
	public static function get(id:String):Class<FlxState>
	{
		return customStates.get(id);
	}
	
	public static function exists(id:String):Bool
	{
		return customStates.exists(id);
	}
	
	public static function switchTo(id:String):Bool
	{
		var stateClass = customStates.get(id);
		if (stateClass != null)
		{
			flixel.FlxG.switchState(() -> Type.createInstance(stateClass, []));
			return true;
		}
		trace("Error: Custom state not found: " + id);
		return false;
	}
	
	public static function clear():Void
	{
		customStates.clear();
	}
	
	public static function listStates():Array<String>
	{
		var list:Array<String> = [];
		for (id in customStates.keys())
		{
			list.push(id);
		}
		return list;
	}
}
