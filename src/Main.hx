package;

#if cpp
import Sys;
#end
import flixel.FlxG;
import flixel.FlxGame;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import states.LoadingState;

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
		tongue = new FireTongueEx();

		tongue.initialize({
			locale: "en-US"
		});

		FlxG.signals.postStateSwitch.add(setupEscapeQuitText);
		addChild(new FlxGame(640, 480, LoadingState));
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function setupEscapeQuitText():Void
	{
		var fontBitmap = Assets.getBitmapData("assets/fonts/pixel_operator.png");
		var fontData = Assets.getText("assets/fonts/pixel_operator.fnt");
		quitFont = FlxBitmapFont.fromAngelCode(fontBitmap, fontData);

		if (quitFont == null)
		{
			throw "Failed to load bitmap font for quitting text!";
		}

		quitText = new FlxBitmapText(5, 5, "", quitFont);
		quitText.color = FlxColor.WHITE;
		quitText.scale.set(1, 1);
		quitText.updateHitbox();
		quitText.alpha = 0;
		FlxG.state.add(quitText);
	}

	function onKeyDown(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.ESCAPE && !escapeHeld)
		{
			escapeHeld = true;
			escapeHoldTime = 0;
			quitDotCount = 0;
			quitDotTimer = 0;
			quitting = true;
			if (quitText != null)
				quitText.alpha = 1;
		}
	}

	function onKeyUp(e:KeyboardEvent):Void
	{
		if (e.keyCode == Keyboard.ESCAPE)
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
				#if cpp
				Sys.exit(0);
				#end
			}

			if (quitText != null)
			{
				var dots = "";
				for (i in 0...quitDotCount)
					dots += ".";
				quitText.text = "Quitting" + dots;
				quitText.alpha = Math.min(1, escapeHoldTime * 2);
			}
		}
	}
}
