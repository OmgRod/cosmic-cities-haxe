package modding;

import ModHooks;
import StringTools;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import hscript.Interp;

class ModScriptBindings
{
	public static function apply(interp:Interp, modId:String):Void
	{
		interp.variables.set("Hooks", new ScriptHookAPI(modId));
		interp.variables.set("Events", ModHookEvents);
		interp.variables.set("ModHookContext", ModHookContext);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxBitmapText", FlxBitmapText);
		interp.variables.set("FlxColor", FlxColor);
		interp.variables.set("Std", Std);
		interp.variables.set("Math", Math);
		interp.variables.set("Reflect", Reflect);
		interp.variables.set("Type", Type);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("trace", function(value:Dynamic)
		{
			trace("[Mod:" + modId + "] " + value);
		});
	}
}
