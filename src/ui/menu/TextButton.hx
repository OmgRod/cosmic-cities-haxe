package ui.menu;

import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxButton;
import ui.style.ButtonStyle;

class TextButton extends FlxGroup
{
    public var playSound:Bool = true;
    private var userCallback:Void->Void = null;
    public var button:FlxButton;
    public var label:FlxBitmapText;

    public function new(x:Float, y:Float, text:String, font:Dynamic, width:Int = 150, height:Int = 40, style:ButtonStyleType = null)
    {
        super();

        button = new FlxButton(x, y, null);
        button.makeGraphic(width, height, 0x00000000);

        label = new FlxBitmapText(0, 0, text, font);
        label.scale.set(1.2, 1.2);
        label.color = 0xFFFFFFFF;
        label.updateHitbox();

        label.x = button.x + (width - label.frameWidth * label.scale.x) / 2;
        label.y = button.y + (height - label.frameHeight * label.scale.y) / 2;

        ButtonStyle.apply(button, style == null ? ButtonStyleType.YellowHover(label) : style);

        button.onUp.callback = () -> {
            if (playSound) playClickSound();
            if (userCallback != null) userCallback();
        };

        add(button);
        add(label);
    }

    public function setCallback(callback:Void->Void):Void
    {
        userCallback = callback;
    }

    private function playClickSound():Void
    {
        var sfx = new FlxSound();
        sfx.loadEmbedded("assets/sounds/sfx.blip." + (1 + Std.random(5)) + ".wav");
        if (sfx != null)
        {
            sfx.volume = 2;
            sfx.play();
        }
    }

    public function disableSound() playSound = false;
    public function enableSound() playSound = true;
}
