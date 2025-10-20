package entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite {
	public var debugHitbox:Bool = false;
	private var debugSprite:FlxSprite;
	
    public function new(x:Float, y:Float) {
        super(x, y);

        makeGraphic(32, 32, FlxColor.RED);
        
		var hitboxSize = 28;
		setSize(hitboxSize, hitboxSize);
		
		var centerOffset = (32 - hitboxSize) / 2;
		offset.set(centerOffset, centerOffset);
		origin.set(16, 16);
        
		drag.set(0, 0);
		maxVelocity.set(150, 150);
		
		solid = true;
		immovable = false;
		moves = false;

		debugSprite = new FlxSprite();
		debugSprite.makeGraphic(Std.int(hitboxSize), Std.int(hitboxSize), 0x8000FF00);
		debugSprite.visible = false;
	}
    
	override public function update(elapsed:Float):Void
	{
		if (debugSprite != null)
		{
			debugSprite.x = x;
			debugSprite.y = y;
			debugSprite.visible = debugHitbox;
			debugSprite.update(elapsed);
		}
    }
	
	override public function draw():Void
	{
		super.draw();

		if (debugSprite != null && debugSprite.visible)
		{
			debugSprite.draw();
		}
	}
}
