package ui;

import flixel.FlxG;
import flixel.FlxSprite;

class Overlay extends FlxSprite
{
	public function new(color:UInt = 0xFF000000, alpha:Float = 0)
	{
		super(0, 0);

		makeGraphic(Std.int(FlxG.width + 2), Std.int(FlxG.height + 2), color);
		this.alpha = alpha;
		scrollFactor.set(0, 0);
		x = -1;
		y = -1;
	}

	public function setColor(color:UInt):Void
	{
		this.color = color;
	}

	public function setAlpha(alpha:Float):Void
	{
		this.alpha = alpha;
	}

	public function show(instant:Bool = true):Void
	{
		visible = true;
		if (instant)
		{
			alpha = 1;
		}
	}

	public function hide(instant:Bool = true):Void
	{
		visible = false;
		if (instant)
		{
			alpha = 0;
		}
	}
}
