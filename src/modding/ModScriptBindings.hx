package modding;

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
		// Expose all event constants as an object
		var events = {
			LOADING_CREATE_PRE: ModHookEvents.LOADING_CREATE_PRE,
			LOADING_CREATE_POST: ModHookEvents.LOADING_CREATE_POST,
			LOADING_DESTROY_PRE: ModHookEvents.LOADING_DESTROY_PRE,
			LOADING_DESTROY_POST: ModHookEvents.LOADING_DESTROY_POST,
			MAINMENU_CREATE_PRE: ModHookEvents.MAINMENU_CREATE_PRE,
			MAINMENU_CREATE_POST: ModHookEvents.MAINMENU_CREATE_POST,
			MAINMENU_UPDATE_PRE: ModHookEvents.MAINMENU_UPDATE_PRE,
			MAINMENU_UPDATE_POST: ModHookEvents.MAINMENU_UPDATE_POST,
			MAINMENU_DESTROY_PRE: ModHookEvents.MAINMENU_DESTROY_PRE,
			MAINMENU_DESTROY_POST: ModHookEvents.MAINMENU_DESTROY_POST,
			GAMESTATE_CREATE_PRE: ModHookEvents.GAMESTATE_CREATE_PRE,
			GAMESTATE_CREATE_POST: ModHookEvents.GAMESTATE_CREATE_POST,
			GAMESTATE_UPDATE_PRE: ModHookEvents.GAMESTATE_UPDATE_PRE,
			GAMESTATE_UPDATE_POST: ModHookEvents.GAMESTATE_UPDATE_POST,
			GAMESTATE_DESTROY_PRE: ModHookEvents.GAMESTATE_DESTROY_PRE,
			GAMESTATE_DESTROY_POST: ModHookEvents.GAMESTATE_DESTROY_POST,
			OPTIONS_CREATE_PRE: ModHookEvents.OPTIONS_CREATE_PRE,
			OPTIONS_CREATE_POST: ModHookEvents.OPTIONS_CREATE_POST,
			OPTIONS_UPDATE_PRE: ModHookEvents.OPTIONS_UPDATE_PRE,
			OPTIONS_UPDATE_POST: ModHookEvents.OPTIONS_UPDATE_POST,
			OPTIONS_DESTROY_PRE: ModHookEvents.OPTIONS_DESTROY_PRE,
			OPTIONS_DESTROY_POST: ModHookEvents.OPTIONS_DESTROY_POST,
			CREDITS_CREATE_PRE: ModHookEvents.CREDITS_CREATE_PRE,
			CREDITS_CREATE_POST: ModHookEvents.CREDITS_CREATE_POST,
			CREDITS_UPDATE_PRE: ModHookEvents.CREDITS_UPDATE_PRE,
			CREDITS_UPDATE_POST: ModHookEvents.CREDITS_UPDATE_POST,
			CREDITS_DESTROY_PRE: ModHookEvents.CREDITS_DESTROY_PRE,
			CREDITS_DESTROY_POST: ModHookEvents.CREDITS_DESTROY_POST
		};
		interp.variables.set("Events", events);
		
		interp.variables.set("ModHookContext", ModHookContext);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxBitmapText", FlxBitmapText);
		// Expose common FlxColor values
		var colors = {
			WHITE: FlxColor.WHITE,
			BLACK: FlxColor.BLACK,
			RED: FlxColor.RED,
			GREEN: FlxColor.GREEN,
			BLUE: FlxColor.BLUE,
			YELLOW: FlxColor.YELLOW,
			CYAN: FlxColor.CYAN,
			MAGENTA: FlxColor.MAGENTA,
			ORANGE: FlxColor.ORANGE,
			PURPLE: FlxColor.PURPLE,
			PINK: FlxColor.PINK,
			GRAY: FlxColor.GRAY,
			TRANSPARENT: FlxColor.TRANSPARENT
		};
		interp.variables.set("FlxColor", colors);
		
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
