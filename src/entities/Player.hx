package entities;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite {
    public function new(x:Float, y:Float) {
        super(x, y);
        
        
        makeGraphic(32, 32, FlxColor.RED);
        
        
        
        var octW = 24;
        var octH = 24;
        var chamfer = 6;
        
        
        var offsetX = (32 - octW) / 2;
        var offsetY = (32 - octH) / 2;
        
        setSize(octW, octH);
        offset.set(offsetX + chamfer, offsetY);
        
        
        
        
        
        origin.set(16, 16);
    }
}
