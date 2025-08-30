package states.options;

import firetongue.FireTongue;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import haxe.ds.StringMap;
import states.OptionsState;
import ui.backgrounds.Starfield;
import ui.menu.TextButton;
import utils.BMFont;

class LanguageOptionsState extends FlxState
{
    var buttonGroup:FlxGroup;
	var font:FlxBitmapFont;
    var pageIndex:Int = 0;
    var buttonsPerPage:Int = 5;

    var pageButtons:Array<TextButton> = [];
    var nextBtn:TextButton;
    var prevBtn:TextButton;
    var backBtn:TextButton;

    var locales:Array<String>;
	var titleText:FlxBitmapText;

	var fontCache:StringMap<FlxBitmapFont> = new StringMap();

    override public function create():Void
    {
        super.create();

        add(new Starfield());

		locales = Main.tongue.locales.copy();
		locales.sort((a, b) -> Reflect.compare(displayNameFor(a), displayNameFor(b)));

		buttonGroup = new FlxGroup();
		add(buttonGroup);

		font = getFontForLocale(Main.tongue.locale);
		loadFontAndTexts();

		backBtn = new TextButton((FlxG.width - 150) / 2, FlxG.height - 50, Main.tongue.get("$GENERAL_BACK", "ui"), font, 150, 40);
        backBtn.setCallback(() -> FlxG.switchState(() -> new OptionsState()));
        add(backBtn);

		createPageButtons();
		addNavigationButtons();
	}

	function getFontForLocale(locale:String):FlxBitmapFont
	{
		var prevLocale = Main.tongue.locale;

		Main.tongue.initialize({locale: locale});

		var fontData = Main.tongue.getFontData("pixel_operator", 16);
		var f = new BMFont("assets/fonts/"
			+ fontData.name
			+ "/"
			+ fontData.name
			+ ".fnt",
			"assets/fonts/"
			+ fontData.name
			+ "/"
			+ fontData.name
			+ ".png").getFont();

		Main.tongue.initialize({locale: prevLocale});

		return f;
	}

	function loadFontAndTexts():Void
	{
		font = getFontForLocale(Main.tongue.locale);

		if (titleText != null)
			remove(titleText);
		var scaleBig = 1.3;
		titleText = new FlxBitmapText(0, 0, Main.tongue.get("$SETTING_LANGUAGES", "ui"), font);
		titleText.scale.set(scaleBig, scaleBig);
		titleText.updateHitbox();
		titleText.x = Math.floor((FlxG.width - titleText.frameWidth * scaleBig) / 2);
		titleText.y = 20;
		add(titleText);

		for (btn in [prevBtn, nextBtn, backBtn])
		{
			if (btn != null)
			{
				if (btn == prevBtn)
					btn.label.text = Main.tongue.get("$GENERAL_PREV", "ui");
				if (btn == nextBtn)
					btn.label.text = Main.tongue.get("$GENERAL_NEXT", "ui");
				if (btn == backBtn)
					btn.label.text = Main.tongue.get("$GENERAL_BACK", "ui");
				btn.label.font = font;
				btn.label.updateHitbox();
			}
		}
    }

	function displayNameFor(id:String):String
	{
        var prev = Main.tongue.locale;
		Main.tongue.initialize({locale: id});
		var lang = Main.tongue.get("$LANGUAGE_NAME", "ui");
		var reg = Main.tongue.get("$LANGUAGE_REGION", "ui");
		Main.tongue.initialize({locale: prev});

		if (reg != "" && reg != "$LANGUAGE_REGION")
			return lang + " (" + reg + ")";
		return lang;
    }

    function createPageButtons():Void
    {
		for (btn in pageButtons)
			buttonGroup.remove(btn, true);
        pageButtons = [];

        var startX = 50;
        var startY = 100;
		var buttonWidth = FlxG.width - 100;
        var buttonHeight = 40;
        var buttonSpacing = 10;

        var start = pageIndex * buttonsPerPage;
		var end = Std.int(Math.min(start + buttonsPerPage, locales.length));
        var currentY = startY;

		for (i in start...end)
        {
            var id = locales[i];
            var label = displayNameFor(id);
			var btnFont = getFontForLocale(id);

			var btn = new TextButton(startX, currentY, label, btnFont, buttonWidth, buttonHeight);
            var capturedId = id;
			btn.setCallback(() ->
			{
				trace("Selected locale: " + capturedId);
				if (Reflect.hasField(Main.tongue, "setLocale"))
					Reflect.callMethod(Main.tongue, Reflect.field(Main.tongue, "setLocale"), [capturedId]);
                else
					Main.tongue.initialize({locale: capturedId});

				loadFontAndTexts();
            });

            pageButtons.push(btn);
            buttonGroup.add(btn);
            currentY += buttonHeight + buttonSpacing;
        }

        updateNavigationButtons();
    }

    function addNavigationButtons():Void
    {
        var btnWidth = 100;
        var btnHeight = 35;
        var y = FlxG.height - 100;

		prevBtn = new TextButton(50, y, Main.tongue.get("$GENERAL_PREV", "ui"), font, btnWidth, btnHeight);
		prevBtn.setCallback(() ->
		{
			if (pageIndex > 0)
            {
                pageIndex--;
                createPageButtons();
            }
        });
        add(prevBtn);

		nextBtn = new TextButton(FlxG.width - 50 - btnWidth, y, Main.tongue.get("$GENERAL_NEXT", "ui"), font, btnWidth, btnHeight);
		nextBtn.setCallback(() ->
		{
			if ((pageIndex + 1) * buttonsPerPage < locales.length)
            {
                pageIndex++;
                createPageButtons();
            }
        });
        add(nextBtn);

        updateNavigationButtons();
    }

    function updateNavigationButtons():Void
    {
		if (prevBtn != null)
		{
			prevBtn.visible = pageIndex > 0;
			prevBtn.active = pageIndex > 0;
		}
		if (nextBtn != null)
		{
			nextBtn.visible = (pageIndex + 1) * buttonsPerPage < locales.length;
			nextBtn.active = (pageIndex + 1) * buttonsPerPage < locales.length;
		}
    }
}
