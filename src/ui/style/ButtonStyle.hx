package ui.style;

import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxButton;

enum ButtonStyleType {
	NoBackground;
	YellowHover(text:FlxBitmapText);
}

class ButtonStyle {
	public static function apply(button:FlxButton, style:ButtonStyleType):Void {
		switch (style) {
			case NoBackground:
				var bg = new FlxSprite();
				bg.makeGraphic(Std.int(button.width), Std.int(button.height), 0x00000000);
				button.loadGraphic(bg.pixels, true, Std.int(button.width), Std.int(button.height));
				button.label.visible = false;

			case YellowHover(text):
				button.onOver.callback = () -> text.color = 0xFFFFFF00;
				button.onOut.callback = () -> text.color = 0xFFFFFFFF;
				button.onDown.callback = () -> text.color = 0xFFA0A000;
				button.onUp.callback = () -> text.color = 0xFFFFFF00;
		}
	}
}
