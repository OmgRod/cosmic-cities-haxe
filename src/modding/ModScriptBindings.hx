package modding;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import hscript.Interp;
import managers.MusicManager;
import states.CreditsState;
import states.GameState;
import states.LoadingState;
import states.MainMenuState;
import states.OptionsState;
import ui.backgrounds.Starfield;
import ui.menu.TextButton;
import utils.BMFont;
#if desktop
import states.ModsState;
#end

class ModScriptBindings
{
	public static function apply(interp:Interp, modId:String):Void
	{
		interp.variables.set("Hooks", new ScriptHookAPI(modId));
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
			CREDITS_DESTROY_POST: ModHookEvents.CREDITS_DESTROY_POST,
			SAVESELECT_CREATE_PRE: ModHookEvents.SAVESELECT_CREATE_PRE,
			SAVESELECT_CREATE_POST: ModHookEvents.SAVESELECT_CREATE_POST,
			SAVESELECT_UPDATE_PRE: ModHookEvents.SAVESELECT_UPDATE_PRE,
			SAVESELECT_UPDATE_POST: ModHookEvents.SAVESELECT_UPDATE_POST,
			SAVESELECT_DESTROY_PRE: ModHookEvents.SAVESELECT_DESTROY_PRE,
			SAVESELECT_DESTROY_POST: ModHookEvents.SAVESELECT_DESTROY_POST,
			MODSSTATE_CREATE_PRE: ModHookEvents.MODSSTATE_CREATE_PRE,
			MODSSTATE_CREATE_POST: ModHookEvents.MODSSTATE_CREATE_POST,
			MODSSTATE_UPDATE_PRE: ModHookEvents.MODSSTATE_UPDATE_PRE,
			MODSSTATE_UPDATE_POST: ModHookEvents.MODSSTATE_UPDATE_POST,
			MODSSTATE_DESTROY_PRE: ModHookEvents.MODSSTATE_DESTROY_PRE,
			MODSSTATE_DESTROY_POST: ModHookEvents.MODSSTATE_DESTROY_POST,
			LEVELSELECT_CREATE_PRE: ModHookEvents.LEVELSELECT_CREATE_PRE,
			LEVELSELECT_CREATE_POST: ModHookEvents.LEVELSELECT_CREATE_POST,
			LEVELSELECT_UPDATE_PRE: ModHookEvents.LEVELSELECT_UPDATE_PRE,
			LEVELSELECT_UPDATE_POST: ModHookEvents.LEVELSELECT_UPDATE_POST,
			LEVELSELECT_DESTROY_PRE: ModHookEvents.LEVELSELECT_DESTROY_PRE,
			LEVELSELECT_DESTROY_POST: ModHookEvents.LEVELSELECT_DESTROY_POST,
			PAUSEMENU_CREATE_PRE: ModHookEvents.PAUSEMENU_CREATE_PRE,
			PAUSEMENU_CREATE_POST: ModHookEvents.PAUSEMENU_CREATE_POST,
			PAUSEMENU_UPDATE_PRE: ModHookEvents.PAUSEMENU_UPDATE_PRE,
			PAUSEMENU_UPDATE_POST: ModHookEvents.PAUSEMENU_UPDATE_POST,
			PAUSEMENU_DESTROY_PRE: ModHookEvents.PAUSEMENU_DESTROY_PRE,
			PAUSEMENU_DESTROY_POST: ModHookEvents.PAUSEMENU_DESTROY_POST,
			DIALOGBOX_CREATE_PRE: ModHookEvents.DIALOGBOX_CREATE_PRE,
			DIALOGBOX_CREATE_POST: ModHookEvents.DIALOGBOX_CREATE_POST,
			DIALOGBOX_SHOW_PRE: ModHookEvents.DIALOGBOX_SHOW_PRE,
			DIALOGBOX_SHOW_POST: ModHookEvents.DIALOGBOX_SHOW_POST,
			DIALOGBOX_CLOSE_PRE: ModHookEvents.DIALOGBOX_CLOSE_PRE,
			DIALOGBOX_CLOSE_POST: ModHookEvents.DIALOGBOX_CLOSE_POST,
			STATE_CREATE_PRE: ModHookEvents.STATE_CREATE_PRE,
			STATE_CREATE_POST: ModHookEvents.STATE_CREATE_POST,
			STATE_UPDATE_PRE: ModHookEvents.STATE_UPDATE_PRE,
			STATE_UPDATE_POST: ModHookEvents.STATE_UPDATE_POST,
			STATE_DESTROY_PRE: ModHookEvents.STATE_DESTROY_PRE,
			STATE_DESTROY_POST: ModHookEvents.STATE_DESTROY_POST,
			STATE_DRAW_PRE: ModHookEvents.STATE_DRAW_PRE,
			STATE_DRAW_POST: ModHookEvents.STATE_DRAW_POST
		};
		interp.variables.set("Events", events);
		
		interp.variables.set("ModHookContext", ModHookContext);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxState", FlxState);
		interp.variables.set("ModState", modding.ModState);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxBitmapText", FlxBitmapText);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxTimer", FlxTimer);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("GameState", GameState);
		interp.variables.set("OptionsState", OptionsState);
		interp.variables.set("CreditsState", CreditsState);
		interp.variables.set("LoadingState", LoadingState);
		#if desktop
		interp.variables.set("ModsState", ModsState);
		#end
		interp.variables.set("TextButton", TextButton);
		interp.variables.set("Starfield", Starfield);
		interp.variables.set("BMFont", BMFont);
		interp.variables.set("MusicManager", MusicManager);
		interp.variables.set("Main", Main);
		interp.variables.set("ModStateRegistry", ModStateRegistry);
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
		interp.variables.set("Array", Array);
		interp.variables.set("Map", haxe.ds.StringMap);
		interp.variables.set("createTimer", function(delay:Float, callback:Void->Void, ?loops:Int = 1)
		{
			var timer = new flixel.util.FlxTimer();
			timer.start(delay, function(_) callback(), loops);
			return timer;
		});
		interp.variables.set("playSound", function(path:String, ?volume:Float = 1.0)
		{
			FlxG.sound.play(path, volume);
		});
		interp.variables.set("trace", function(value:Dynamic)
		{
			trace("[Mod:" + modId + "] " + value);
		});
	}
}
