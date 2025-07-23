package states;

import cpp.ConstCharStar;
import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.sound.FlxSound;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import openfl.Assets;
import ui.backgrounds.Starfield;

class MainMenu extends FlxState
{

	var font:FlxBitmapFont;

	override public function create()
	{
		super.create();

        var starfield = new Starfield();
        add(starfield);

		var music = new FlxSound();
		music.loadStream("assets/sounds/music.intro.wav", true);
		music.play();
		FlxG.sound.list.add(music);

		var vw = FlxG.width;
		var vh = FlxG.height;

		var logo = new FlxSprite();
		logo.loadGraphic("assets/sprites/CC_titleLogo_001.png");

		var logoScale = (vw * 0.8) / logo.width;
		logo.setGraphicSize(Std.int(logo.width * logoScale), Std.int(logo.height * logoScale));
		logo.updateHitbox();
		logo.x = vw * 0.1;
		logo.y = vh * 0.15;
		add(logo);

		var fontBitmap = Assets.getBitmapData("assets/fonts/pixel_operator.png");
		var fontData = Assets.getText("assets/fonts/pixel_operator.fnt");
		font = FlxBitmapFont.fromAngelCode(fontBitmap, fontData);
		if (font == null)
		{
			throw "Failed to load bitmap font assets!";
		}
		var copyrightText = new FlxBitmapText(0, 0, "© OmgRod 2025 - All Rights Reserved", font);
		copyrightText.color = 0xFFFFFFFF;
		copyrightText.scale.set(0.65, 0.65);
		copyrightText.updateHitbox();
		copyrightText.x = 12;
		copyrightText.y = FlxG.height - (copyrightText.height * copyrightText.scale.y) - 12;
		add(copyrightText);

        final discordPresence = new DiscordRichPresence();
		discordPresence.largeImageText = "Cosmic Cities";
        discordPresence.details = "Browsing menus...";
		discordPresence.state = "Main Menu";
		discordPresence.largeImageKey = "logo";

		Discord.UpdatePresence(RawConstPointer.addressOf(discordPresence));
	}

	override public function update(dt:Float):Void
	{
		super.update(dt);
	}
}
