package states;

#if (!disable_discord && cpp && !android)
import Sys;
import cpp.RawConstPointer;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import managers.MusicManager;
import states.CreditsState;
import states.GameState;
import states.ModsState;
import states.OptionsState;
import ui.SplashTextData;
import ui.SplashTextUI;
import ui.backgrounds.Starfield;
import ui.menu.TextButton;
import utils.BMFont;

class MainMenuState extends FlxState
{
	var font:FlxBitmapFont;
	var buttonCallbacks:Map<String, Void->Void>;

	override public function create()
	{
		super.create();

		buttonCallbacks = new Map();
		buttonCallbacks.set("start", () -> FlxG.switchState(() -> new SaveSelectState()));
		buttonCallbacks.set("options", () -> FlxG.switchState(() -> new OptionsState()));
		buttonCallbacks.set("mods", () -> FlxG.switchState(() -> new ModsState()));
		buttonCallbacks.set("credits", () -> FlxG.switchState(() -> new CreditsState()));

		#if cpp
		buttonCallbacks.set("exit", () -> Sys.exit(0));
		#end

		var starfield = new Starfield();
		add(starfield);

		MusicManager.play("intro");

		var vw = FlxG.width;
		var vh = FlxG.height;

		var logo = new FlxSprite();
		logo.loadGraphic("assets/sprites/CC_titleLogo_001.png");
		var logoScale = (vw * 0.8) / logo.width;
		logo.setGraphicSize(Std.int(logo.width * logoScale), Std.int(logo.height * logoScale));
		logo.updateHitbox();
		logo.x = vw * 0.1;
		logo.y = vh * 0.15;
		logo.scrollFactor.set(0, 0);
		add(logo);

		var fontString = Main.tongue.getFontData("pixel_operator", 16).name;
		font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

		var copyrightText = new FlxBitmapText(0, 0, Main.tongue.get("$COPYRIGHT_NOTICE", "ui"), font);
		copyrightText.color = 0xFFFFFFFF;
		copyrightText.scale.set(0.65, 0.65);
		copyrightText.updateHitbox();
		copyrightText.x = 12;
		copyrightText.y = FlxG.height - (copyrightText.height * copyrightText.scale.y) - 12;
		add(copyrightText);

		var buttonGroup = new FlxGroup();
		add(buttonGroup);

		var buttons = [
			{id: "start", label: Main.tongue.get("$MENU_START_BUTTON", "ui")},
			{id: "options", label: Main.tongue.get("$MENU_OPTIONS_BUTTON", "ui")},
			{id: "mods", label: "Mods"},
			{id: "credits", label: Main.tongue.get("$MENU_CREDITS_BUTTON", "ui")}
		];

		#if cpp
		buttons.push({id: "exit", label: Main.tongue.get("$MENU_EXIT_BUTTON", "ui")});
		#end

		var buttonWidth = 150;
		var buttonHeight = 40;
		var buttonSpacing = 10;
		var totalHeight = buttons.length * buttonHeight + (buttons.length - 1) * buttonSpacing;
		var startX = (FlxG.width - buttonWidth) / 2;
		var availableHeight = copyrightText.y - (logo.y + logo.height);
		var startY = logo.y + logo.height + (availableHeight - totalHeight) / 2;

		for (i in 0...buttons.length)
		{
			var btnData = buttons[i];

			var btn = new TextButton(startX, startY + i * (buttonHeight + buttonSpacing), btnData.label, font, buttonWidth, buttonHeight);

			btn.setCallback(() ->
			{
				var callback = buttonCallbacks.get(btnData.id);
				if (callback != null)
					callback();
			});

			buttonGroup.add(btn);
		}

		#if (!disable_discord && cpp && !android)
		final discordPresence = new DiscordRichPresence();
		discordPresence.largeImageText = "Cosmic Cities";
		discordPresence.details = "Browsing menus...";
		discordPresence.state = "Main Menu";
		discordPresence.largeImageKey = "logo";
		Discord.UpdatePresence(RawConstPointer.addressOf(discordPresence));
		#end
		var splash = new SplashText(logo, font);
		add(splash);
	}

	override public function update(dt:Float):Void
	{
		super.update(dt);
	}
}
