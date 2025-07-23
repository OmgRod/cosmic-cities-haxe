package states;

#if cpp
import Sys;
import cpp.ConstCharStar;
import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxButton;
import manager.MusicManager;
import openfl.Assets;
import states.GameState;
import ui.backgrounds.Starfield;

class MainMenuState extends FlxState
{
	var font:FlxBitmapFont;
	var buttonCallbacks:Map<String,Void->Void>;

	override public function create()
	{
		super.create();

		buttonCallbacks = new Map();

		buttonCallbacks.set("Start", () ->
		{
			// trace("Start pressed");
			FlxG.switchState(() -> new GameState());
		});

		buttonCallbacks.set("Options", () ->
		{
			// trace("Options pressed");
		});

		buttonCallbacks.set("Credits", () ->
		{
			// trace("Credits pressed");
		});

		#if cpp
		buttonCallbacks.set("Exit", () ->
		{
			// trace("Exit pressed");
			Sys.exit(0);
		});
		#end

		var starfield = new Starfield();
		add(starfield);

		MusicManager.playIntroMusic();

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

		var buttonGroup = new FlxGroup();
		var textGroup = new FlxGroup();
		add(buttonGroup);
		add(textGroup);

		var buttonLabels = ["Start", "Options", "Credits"];
		#if cpp
		buttonLabels.push("Exit");
		#end
		var buttonWidth = 150;
		var buttonHeight = 40;
		var buttonSpacing = 10;

		var totalHeight = buttonLabels.length * buttonHeight + (buttonLabels.length - 1) * buttonSpacing;
		var startX = (FlxG.width - buttonWidth) / 2;
		var availableHeight = copyrightText.y - (logo.y + logo.height);
		var startY = logo.y + logo.height + (availableHeight - totalHeight) / 2;

		for (i in 0...buttonLabels.length)
		{
			var label = buttonLabels[i];

			var btn = new FlxButton(0, 0, "");
			var bg = new FlxSprite();
			bg.makeGraphic(buttonWidth, buttonHeight, 0x00FFFFFF);
			btn.loadGraphic(bg.pixels, true, buttonWidth, buttonHeight);
			btn.label.visible = false;

			btn.x = startX;
			btn.y = startY + i * (buttonHeight + buttonSpacing);

			var txt = new FlxBitmapText(0, 0, label, font);
			txt.scale.set(1.2, 1.2);
			txt.color = 0xFFFFFFFF;
			txt.updateHitbox();

			txt.x = btn.x + (buttonWidth - txt.width * txt.scale.x) / 2;
			txt.y = btn.y + (buttonHeight - txt.height * txt.scale.y) / 2;

			btn.onOver.callback = () -> txt.color = 0xFFFFFF00;
			btn.onOut.callback = () -> txt.color = 0xFFFFFFFF;
			btn.onDown.callback = () -> txt.color = 0xFFA0A000;
			btn.onUp.callback = () ->
			{
				txt.color = 0xFFFFFF00;
				trace('$label clicked');

				var callback = buttonCallbacks.get(label);
				var sfx = new FlxSound();
				sfx.loadEmbedded("assets/sounds/sfx.blip." + (1 + Std.random(5)) + ".wav");
				if (sfx != null)
					sfx.volume = 2;
					sfx.play();

				if (callback != null)
					callback();
			};

			buttonGroup.add(btn);
			textGroup.add(txt);
		}

		#if cpp
		final discordPresence = new DiscordRichPresence();
		discordPresence.largeImageText = "Cosmic Cities";
		discordPresence.details = "Browsing menus...";
		discordPresence.state = "Main Menu";
		discordPresence.largeImageKey = "logo";

		Discord.UpdatePresence(RawConstPointer.addressOf(discordPresence));
		#end
	}

	override public function update(dt:Float):Void
	{
		super.update(dt);
	}
}
