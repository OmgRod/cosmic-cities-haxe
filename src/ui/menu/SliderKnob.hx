package ui.menu;

import flixel.FlxG;
import flixel.FlxSprite;

class SliderKnob extends FlxSprite {
    var knobWidth:Int;
    var knobHeight:Int;

    public function new(width:Int = 20, height:Int = 20) {
        super();
        knobWidth = width;
        knobHeight = height;
        makeGraphic(width, height, 0xFFFFFFFF);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
		#if !android
        if (FlxG.mouse.overlaps(this))
            makeGraphic(knobWidth, knobHeight, 0xFFFFFF00);
        else
            makeGraphic(knobWidth, knobHeight, 0xFFFFFFFF);
		#end
    }
}
