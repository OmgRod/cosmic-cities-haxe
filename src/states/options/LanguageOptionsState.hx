package states.options;

import firetongue.FireTongue;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import states.OptionsState;
import ui.backgrounds.Starfield;
import ui.menu.TextButton;
import utils.BMFont;

class LanguageOptionsState extends FlxState
{
    var buttonGroup:FlxGroup;
    var font:Dynamic;

    var pageIndex:Int = 0;
    var buttonsPerPage:Int = 5;

    var pageButtons:Array<TextButton> = [];
    var nextBtn:TextButton;
    var prevBtn:TextButton;
    var backBtn:TextButton;

    var locales:Array<String>;

    override public function create():Void
    {
        super.create();

        add(new Starfield());

        font = new BMFont("assets/fonts/pixel_operator.fnt", "assets/fonts/pixel_operator.png").getFont();

        var scaleBig = 1.3;
        var title = new FlxBitmapText(0, 0, Main.tongue.get("$SETTING_LANGUAGES", "ui"), font);
        title.scale.set(scaleBig, scaleBig);
        title.updateHitbox();
        title.x = Math.floor((FlxG.width - title.frameWidth * scaleBig) / 2);
        title.y = 20;
        add(title);

        backBtn = new TextButton((FlxG.width - 150) / 2, FlxG.height - 50, Main.tongue.get("$GENERAL_BACK", "ui"), font, 150, 40);
        backBtn.setCallback(() -> FlxG.switchState(() -> new OptionsState()));
        add(backBtn);

        locales = Main.tongue.locales.copy();
        locales.sort((a, b) -> Reflect.compare(displayNameFor(a), displayNameFor(b)));
        trace("FireTongue locales found: " + locales.length);

        locales.sort((a, b) -> Reflect.compare(displayNameFor(a), displayNameFor(b)));

        buttonGroup = new FlxGroup();
        add(buttonGroup);

        createPageButtons();
        addNavigationButtons();
    }

    function displayNameFor(id:String):String {
        var prev = Main.tongue.locale;
        Main.tongue.initialize({
            locale: id
        });

        var lang = Main.tongue.get("$LANGUAGE_NAME", "ui");
        var reg  = Main.tongue.get("$LANGUAGE_REGION", "ui");

        Main.tongue.initialize({
            locale: prev
        });

        if (reg != "" && reg != "$LANGUAGE_REGION") {
            return lang + " (" + reg + ")";
        } else {
            return lang;
        }
    }

    function createPageButtons():Void
    {
        for (btn in pageButtons) buttonGroup.remove(btn, true);
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
            var btn = new TextButton(startX, currentY, label, font, buttonWidth, buttonHeight);
            var capturedId = id;
            btn.setCallback(() -> {
                trace('Selected locale: ' + capturedId);
                if (Reflect.hasField(Main.tongue, "setLocale"))
                    Reflect.callMethod(Main.tongue, Reflect.field(Main.tongue, "setLocale"), [capturedId]);
                else
                    Main.tongue.initialize({ locale: capturedId });
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
        prevBtn.setCallback(() -> {
            if (pageIndex > 0)
            {
                pageIndex--;
                createPageButtons();
            }
        });
        add(prevBtn);

        nextBtn = new TextButton(FlxG.width - 50 - btnWidth, y, Main.tongue.get("$GENERAL_NEXT", "ui"), font, btnWidth, btnHeight);
        nextBtn.setCallback(() -> {
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
