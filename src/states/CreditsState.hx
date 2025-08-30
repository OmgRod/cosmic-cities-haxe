package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.sound.FlxSound;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxButton;
import ui.backgrounds.Starfield;
import ui.style.ButtonStyle;
import utils.BMFont;

class CreditsState extends FlxState
{
    override public function create()
    {
        var starfield = new Starfield();
        add(starfield);

		var fontString = Main.tongue.getFontData("pixel_operator", 16).name;
		var font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

		var scaleBig = 1.3;
		var title = new FlxBitmapText(0, 0, Main.tongue.get("$CREDITS_TITLE", "ui"), font);
		title.scale.set(scaleBig, scaleBig);
		title.updateHitbox();
		title.x = Math.floor((FlxG.width - title.frameWidth * scaleBig) / 2);
		title.y = 50;
		add(title);

		var backBtn = new FlxButton(0, 0, "");
		backBtn.width = 150;
		backBtn.height = 40;
		ButtonStyle.apply(backBtn, ButtonStyleType.NoBackground);

		backBtn.x = (FlxG.width - backBtn.width) / 2;
		backBtn.y = FlxG.height - backBtn.height - 10;

		var backText = new FlxBitmapText(0, 0, Main.tongue.get("$GENERAL_BACK", "ui"), font);
		backText.scale.set(1.2, 1.2);
		backText.color = 0xFFFFFFFF;
		backText.updateHitbox();

		backText.x = backBtn.x + (backBtn.width - backText.textWidth * backText.scale.x) / 2;
		backText.y = backBtn.y + (backBtn.height - backText.textHeight * backText.scale.y) / 2;

		ButtonStyle.apply(backBtn, ButtonStyleType.YellowHover(backText));

		backBtn.onUp.callback = () ->
		{
			backText.color = 0xFFFFFF00;

			var sfx = new FlxSound();
			sfx.loadEmbedded("assets/sounds/sfx.blip." + (1 + Std.random(5)) + ".wav");
			if (sfx != null)
			{
				sfx.volume = 2;
				sfx.play();
			}

			FlxG.switchState(() -> new MainMenuState());
		};

		add(backBtn);
		add(backText);
    }
}