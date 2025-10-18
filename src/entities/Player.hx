package entities;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

class Player extends FlxSprite {
	public var debugHitbox:Bool = false;
	private var debugSprite:FlxSprite;
	
    public function new(x:Float, y:Float) {
        super(x, y);

        makeGraphic(32, 32, FlxColor.RED);
        
		var spriteSize = 32;
		var octagonSize = 24;
		var cornerCut = 7;
        
		setSize(octagonSize, octagonSize);
        
		var centerOffset = (spriteSize - octagonSize) / 2;
		offset.set(centerOffset, centerOffset);
        
		origin.set(spriteSize / 2, spriteSize / 2);
        
		drag.set(1200, 1200);
		
		// Create debug sprite for hitbox visualization
		debugSprite = new FlxSprite();
		debugSprite.makeGraphic(Std.int(octagonSize), Std.int(octagonSize), 0x8000FF00); // Semi-transparent green
		debugSprite.visible = false;
	}
    
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        
		if (velocity.x != 0 && velocity.y != 0)
		{
			velocity.x *= 0.7071;
			velocity.y *= 0.7071;
		}
		
		// Update debug sprite position to match actual hitbox
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
		
		// Draw debug hitbox overlay
		if (debugSprite != null && debugSprite.visible)
		{
			debugSprite.draw();
		}
	}
}
