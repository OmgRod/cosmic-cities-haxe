package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxButton;
import ui.backgrounds.Starfield;
import ui.style.ButtonStyle;
import utils.BMFont;

class CreditsState extends FlxState
{
	var creditsGroup:FlxGroup;
	var itemData:Array<{item:flixel.FlxBasic, initialY:Float}> = [];
	var scrollSpeed:Float = 40;
	var scrollOffset:Float = 0;
	var totalHeight:Float = 0;
	var skipHint:FlxBitmapText;
	var fontString:String;
	var font:Dynamic;
	var fadeStarted:Bool = false;

	override public function create()
	{
		super.create();
		add(new Starfield());

		fontString = Main.tongue.getFontData("pixel_operator", 16).name;
		font = new BMFont('assets/fonts/' + fontString + '/' + fontString + '.fnt', 'assets/fonts/' + fontString + '/' + fontString + '.png').getFont();

		creditsGroup = new FlxGroup();
		add(creditsGroup);

		var logo = new flixel.FlxSprite(0, 0, "assets/sprites/CC_titleLogo_001.png");
		logo.scrollFactor.set(0, 0);
		var maxLogoWidth = FlxG.width * 0.8;
		var maxLogoHeight = 120;
		var scaleW = maxLogoWidth / logo.width;
		var scaleH = maxLogoHeight / logo.height;
		var scale = Math.min(Math.min(scaleW, scaleH), 1.0);
		logo.scale.set(scale, scale);
		logo.updateHitbox();
		logo.x = (FlxG.width - logo.width) / 2;
		logo.y = 0;
		creditsGroup.add(logo);
		itemData.push({item: logo, initialY: 0});

		var sectionSpacing = 48.0;
		var y = logo.height + 32;

		inline function addSectionTitle(text:String)
		{
			var t = makeSectionTitle(text);
			t.y = y;
			creditsGroup.add(t);
			itemData.push({item: t, initialY: y});
			y += t.height;
		}
		inline function addCreditItem(role:String, name:String)
		{
			var t = makeCreditItem(role, name);
			t.y = y;
			creditsGroup.add(t);
			itemData.push({item: t, initialY: y});
			y += t.height;
		}
		inline function addCenteredText(text:String, scale:Float = 0.8, color:Int = 0xFFFFFFFF)
		{
			var t = makeCenteredText(text, scale, color);
			t.y = y;
			creditsGroup.add(t);
			itemData.push({item: t, initialY: y});
			y += t.height;
		}
		inline function addSpacer(h:Float)
			y += h;

		addSectionTitle(Main.tongue.get("$CREDITS_SECTION_DEVELOPMENT", "ui"));
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_GAME_DIRECTOR", "ui"), "OmgRod");
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_LEAD_PROGRAMMER", "ui"), "OmgRod");
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_GAME_DESIGNER", "ui"), "OmgRod");
		addSpacer(sectionSpacing);

		addSectionTitle(Main.tongue.get("$CREDITS_SECTION_ART", "ui"));
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_LEAD_ARTIST", "ui"), "OmgRod");
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_SPRITE_DESIGN", "ui"), "OmgRod");
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_UI_DESIGN", "ui"), "OmgRod");
		addSpacer(sectionSpacing);

		addSectionTitle(Main.tongue.get("$CREDITS_SECTION_AUDIO", "ui"));
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_MUSIC_COMPOSER", "ui"), "PumpkinSmarty & OmgRod");
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_SOUND_DESIGN", "ui"), "OmgRod & Bfxr");
		addSpacer(sectionSpacing);

		addSectionTitle(Main.tongue.get("$CREDITS_SECTION_WRITING", "ui"));
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_STORY_WRITER", "ui"), "OmgRod");
		addCreditItem(Main.tongue.get("$CREDITS_ROLE_DIALOGUE_WRITER", "ui"), "OmgRod");
		addSpacer(sectionSpacing);

		addSectionTitle(Main.tongue.get("$CREDITS_SECTION_BACKERS", "ui"));
		addCenteredText(Main.tongue.get("John Doe", "ui"), 0.8, 0xFFFFFFFF);
		addCenteredText(Main.tongue.get("Jane Smith", "ui"), 0.8, 0xFFFFFFFF);
		addCenteredText(Main.tongue.get("Alex Johnson", "ui"), 0.8, 0xFFFFFFFF);
		addCenteredText(Main.tongue.get("Chris Lee", "ui"), 0.8, 0xFFFFFFFF);
		addCenteredText(Main.tongue.get("Pat Morgan", "ui"), 0.8, 0xFFFFFFFF);
		addCenteredText(Main.tongue.get("Taylor Kim", "ui"), 0.8, 0xFFFFFFFF);
		addSpacer(sectionSpacing);

		addSectionTitle(Main.tongue.get("$CREDITS_SECTION_TECHNOLOGY", "ui"));
		addCenteredText(Main.tongue.get("$CREDITS_TECH_HAXEFLIXEL", "ui"), 0.8, 0xFFAAAAAA);
		addCenteredText(Main.tongue.get("$CREDITS_TECH_HAXE_OPENFL", "ui"), 0.8, 0xFFAAAAAA);
		addSpacer(sectionSpacing);

		addSectionTitle(Main.tongue.get("$CREDITS_SECTION_THANKS", "ui"));
		addCenteredText(Main.tongue.get("$CREDITS_THANKS_COMMUNITY", "ui"), 0.8, 0xFFAAAAAA);
		addCenteredText("haxeflixel.com", 0.8, 0xFFAAAAAA);
		addSpacer(sectionSpacing);

		addSpacer(sectionSpacing);
		addCenteredText(Main.tongue.get("$CREDITS_THANK_YOU", "ui"), 1.0, 0xFFFFFF00);
		addSpacer(sectionSpacing);

		totalHeight = y;

		skipHint = new FlxBitmapText(0, 0, Main.tongue.get("$CREDITS_SKIP_HINT", "ui"), font);
		skipHint.scale.set(0.9, 0.9);
		skipHint.updateHitbox();
		skipHint.color = 0xFFFFFF;
		skipHint.alpha = 0.5;
		skipHint.x = (FlxG.width - skipHint.textWidth * skipHint.scale.x) / 2;
		skipHint.y = FlxG.height - skipHint.height - 24;
		skipHint.scrollFactor.set(0, 0);
		add(skipHint);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (fadeStarted)
			return;

		scrollOffset += scrollSpeed * elapsed;
		var offsetY = FlxG.height - scrollOffset;

		for (data in itemData)
		{
			if (Std.isOfType(data.item, flixel.FlxSprite))
			{
				var s:flixel.FlxSprite = cast data.item;
				s.y = offsetY + data.initialY;
				s.x = (FlxG.width - s.width) / 2;
			}
			else if (Std.isOfType(data.item, FlxBitmapText))
			{
				var t:FlxBitmapText = cast data.item;
				t.y = offsetY + data.initialY;
				t.x = (FlxG.width - t.textWidth * t.scale.x) / 2;
			}
		}

		if (offsetY + totalHeight < 0)
			startFadeToMenu();
		#if !android
		if (FlxG.keys.justPressed.ESCAPE)
			startFadeToMenu();
		#end
	}

	function startFadeToMenu()
	{
		if (fadeStarted)
			return;
		fadeStarted = true;
		FlxG.camera.fade(0xFF000000, 1.0, false, function() FlxG.switchState(() -> new MainMenuState()));
	}



	function makeSectionTitle(text:String):FlxBitmapText
	{
		var t = new FlxBitmapText(0, 0, text, font);
		t.scale.set(1.0, 1.0);
		t.updateHitbox();
		t.color = 0xFFFFFF00;
		return t;
	}

	function makeCreditItem(role:String, name:String):FlxBitmapText
	{
		var t = new FlxBitmapText(0, 0, role + "    " + name, font);
		t.scale.set(0.8, 0.8);
		t.updateHitbox();
		t.color = 0xFFFFFFFF;
		return t;
	}

	function makeCenteredText(text:String, scale:Float = 0.8, color:Int = 0xFFFFFFFF):FlxBitmapText
	{
		var t = new FlxBitmapText(0, 0, text, font);
		t.scale.set(scale, scale);
		t.updateHitbox();
		t.color = color;
		return t;
	}
}