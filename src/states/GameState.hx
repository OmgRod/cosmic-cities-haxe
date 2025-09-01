package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxSliceSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import manager.MusicManager;
import ui.backgrounds.Starfield;

class GameState extends FlxState
{
	override public function create()
    {
        super.create();

        var starfield = new Starfield();
        add(starfield);

		var gfx:FlxGraphic = FlxG.bitmap.add("assets/sprites/CC_progressBar_001.png");
		if (gfx == null)
		{
			trace("ERROR: Could not load CC_progressBar_001.png");
			return;
		}
		trace("gfx size: " + gfx.width + "x" + gfx.height);
		if (gfx.width <= 64)
		{
			trace("ERROR: Image is too small for 32px caps, using fallback sprite");
			var fallback = new FlxSprite(0, 0).loadGraphic("assets/images/CC_progressBar_001.png");
			add(fallback);
			return;
		}
		var sliceRect = new FlxRect(32, 0, gfx.width - 64, gfx.height);
		var slice:FlxSliceSprite = null;
		try
		{
			slice = new FlxSliceSprite(gfx, sliceRect, 460, gfx.height);
			slice.x = (FlxG.width / 2) - (slice.width / 2);
			slice.y = 32;
			slice.stretchCenter = true;
			add(slice);
			trace("Slice created successfully!");
		}
		catch (e:Dynamic)
		{
			trace("ERROR creating FlxSliceSprite: " + e);
			var fallback = new FlxSprite(0, 0).loadGraphic("assets/images/CC_progressBar_001.png");
			add(fallback);
		}

		MusicManager.stop("intro");
    }
}
