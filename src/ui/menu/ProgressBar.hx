package ui.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxSliceSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;

class ProgressBar extends FlxSpriteGroup
{
	public function new(x:Float = 0, y:Float = 0, targetWidth:Float = 460)
	{
		super(x, y);

		var gfx:FlxGraphic = FlxG.bitmap.add("assets/sprites/CC_progressBar_001.png");
		if (gfx == null)
		{
			trace("ERROR: Could not load CC_progressBar_001.png");
			return;
		}

		if (gfx.width <= 64)
		{
			trace("ERROR: Image too small for slicing, using fallback.");
			var fallback = new FlxSprite(0, 0).loadGraphic("assets/sprites/CC_progressBar_001.png");
			add(fallback);
			return;
		}

		var sliceRect = new FlxRect(32, 0, gfx.width - 64, gfx.height);

		try
		{
			var slice = new FlxSliceSprite(gfx, sliceRect, targetWidth, gfx.height);
			slice.stretchCenter = true;
			add(slice);
			trace("ProgressBar slice created successfully!");
		}
		catch (e:Dynamic)
		{
			trace("ERROR creating FlxSliceSprite: " + e);
			var fallback = new FlxSprite(0, 0).loadGraphic("assets/sprites/CC_progressBar_001.png");
			add(fallback);
		}
	}
}
