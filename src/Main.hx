package;

#if cpp
import Sys;
#end
import flixel.FlxG;
import flixel.FlxGame;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import managers.ModLoader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import states.LoadingState;
import utils.BMFont;
import utils.GameSaveManager;
// #if js
// import newgrounds.NewgroundsAPI;
// #end

class Main extends Sprite
{
	var escapeHeld:Bool = false;
	var escapeHoldTime:Float = 0;
	var quitText:FlxBitmapText;
	var quitting:Bool = false;
	var quitDotTimer:Float = 0;
	var quitDotCount:Int = 0;
	var quitFont:FlxBitmapFont;

	public static var tongue:FireTongueEx;

	public function new()
	{
		super();
		try
		{
			trace("=== Main.new() starting ===");
			tongue = new FireTongueEx();

			var savedOptions = GameSaveManager.loadOptionsWithDefaults();
			var localeToUse = savedOptions.language;
			var volumeToUse = savedOptions.volume;

			trace("About to initialize FireTongue with locale: " + localeToUse);
			tongue.initialize({
				locale: localeToUse
			});
			trace("FireTongue initialized successfully");

	// #if js
	// try
	// {
	// 	NG.create("61009:R39LSic5");
	// 	trace("Newgrounds API initialized successfully with app ID 61009");
	// }
	// catch (e:Dynamic)
	// {
	// 	trace("Newgrounds API initialization warning: " + e);
	// }
	// #end

			ModLoader.init("mods", true);
			FlxG.signals.postStateSwitch.add(setupEscapeQuitText);
			addChild(new FlxGame(640, 480, LoadingState));

			#if FLX_SOUND_SYSTEM
			FlxG.signals.postStateSwitch.addOnce(function() {
				trace("Applying saved master volume: " + volumeToUse);
				FlxG.sound.muted = false;
				FlxG.sound.volume = volumeToUse;
				FlxG.sound.defaultSoundGroup.volume = volumeToUse;
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.volume = volumeToUse;
				}
			});
			#end

			#if FLX_SOUND_SYSTEM
			#if !android
			FlxG.sound.volumeUpKeys = null;
			FlxG.sound.volumeDownKeys = null;
			FlxG.sound.muteKeys = null;
			#end
			#end

			#if cpp
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			#end
		}
		catch (e:Dynamic)
		{
			trace("FATAL ERROR in Main constructor: " + e);
			trace("Stack: " + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
		}
	}

	function setupEscapeQuitText():Void
	{
		if (quitText != null && FlxG.state != null)
			FlxG.state.remove(quitText);

		var fontString = tongue.getFontData("pixel_operator", 16).name;
		var font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

		quitText = new FlxBitmapText(0, 0, Main.tongue.get("$GENERAL_QUITTING", "ui"), font);
		quitText.color = FlxColor.WHITE;
		quitText.scale.set(1, 1);
		quitText.updateHitbox();
		quitText.alpha = 0;

		FlxG.state.add(quitText);
	}

	function onKeyDown(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.BACKSPACE && !escapeHeld)
		{
			escapeHeld = true;
			escapeHoldTime = 0;
			quitDotCount = 0;
			quitDotTimer = 0;
			quitting = true;
			setupEscapeQuitText();
			if (quitText != null)
				quitText.alpha = 1;
		}
	}

	function onKeyUp(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.BACKSPACE)
		{
			escapeHeld = false;
			escapeHoldTime = 0;
			quitDotCount = 0;
			quitDotTimer = 0;
			quitting = false;
			if (quitText != null)
				quitText.alpha = 0;
		}
	}

	function onEnterFrame(_):Void
	{
		var dt = FlxG.elapsed;

		#if cpp
		if (escapeHeld)
		{
			escapeHoldTime += dt;
			quitDotTimer += dt;

			if (quitDotTimer >= 0.5)
			{
				quitDotTimer = 0;
				if (quitDotCount < 4)
					quitDotCount++;
			}

			if (quitDotCount == 4)
			{
				Sys.exit(0);
			}

			if (quitText != null)
			{
				var dots = "";
				for (i in 0...quitDotCount)
					dots += ".";
				quitText.text = Main.tongue.get("$GENERAL_QUITTING", "ui") + dots;
				quitText.alpha = Math.min(1, escapeHoldTime * 2);
			}
		}
		#end
	}
}
