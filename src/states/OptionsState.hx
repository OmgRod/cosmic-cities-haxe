package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import managers.MusicManager;
import states.options.LanguageOptionsState;
import ui.backgrounds.Starfield;
import ui.menu.SliderKnob;
import ui.menu.TextButton;
import utils.BMFont;
import utils.GameSaveManager;

class OptionsState extends FlxState
{
    var volumeText:FlxBitmapText;
    var sliderBar:FlxSprite;
    var sliderKnob:FlxSprite;
    var dragging:Bool = false;
    var minX:Float;
    var maxX:Float;

	public static var returnState:Class<FlxState> = null;

    override public function create()
    {
        super.create();

        var starfield = new Starfield();
        add(starfield);

		var fontString = Main.tongue.getFontData("pixel_operator", 16).name;
		var font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

        var scaleBig = 1.3;
		var title = new FlxBitmapText(0, 0, Main.tongue.get("$SETTING_TITLE", "ui"), font);
        title.scale.set(scaleBig, scaleBig);
        title.updateHitbox();
        title.x = Math.floor((FlxG.width - title.frameWidth * scaleBig) / 2);
        title.y = 50;
        add(title);

		var label = new FlxBitmapText(0, 0, Main.tongue.get("$SETTING_VOLUME", "ui"), font);
        label.scale.set(1.0, 1.0);
        label.updateHitbox();
        label.x = Math.floor((FlxG.width - label.frameWidth) / 2);
        label.y = title.y + title.frameHeight + 30;
        add(label);

        sliderBar = new FlxSprite().makeGraphic(300, 8, 0xFF444444);
        sliderBar.x = Math.floor((FlxG.width - sliderBar.width) / 2);
        sliderBar.y = label.y + label.frameHeight + 20;
        add(sliderBar);

        sliderKnob = new SliderKnob();
        sliderKnob.y = sliderBar.y - 6;
        add(sliderKnob);

        minX = sliderBar.x;
        maxX = sliderBar.x + sliderBar.width - sliderKnob.width;

        var initialX = minX + (maxX - minX) * FlxG.sound.volume;
        sliderKnob.x = initialX;

        volumeText = new FlxBitmapText(sliderBar.x + sliderBar.width + 15, sliderKnob.y, "", font);
        volumeText.text = Std.string(Math.round(FlxG.sound.volume * 100)) + "%";
        add(volumeText);

		var langBtn = new TextButton((FlxG.width - 200) / 2, sliderBar.y + sliderBar.height + 30, Main.tongue.get("$SETTING_LANGUAGES", "ui"), font, 200, 40);
		langBtn.setCallback(() ->
		{
			FlxG.switchState(() -> new LanguageOptionsState());
		});
		add(langBtn);

		var backBtn = new TextButton((FlxG.width - 150) / 2, FlxG.height - 50, Main.tongue.get("$GENERAL_BACK", "ui"), font, 150, 40);
		backBtn.setCallback(() ->
		{
			if (returnState != null)
			{
				var targetState = returnState;
				returnState = null;
				FlxG.switchState(Type.createInstance.bind(targetState, []));
			}
			else
			{
				FlxG.switchState(() -> new MainMenuState());
			}
		});
		add(backBtn);
		var now = Date.now();
        var month = now.getMonth();
        var sprite = new FlxSprite();

        switch (month) {
            case 0: sprite.loadGraphic("assets/sprites/CC_januaryIcon_001.png");
            case 1: sprite.loadGraphic("assets/sprites/CC_februaryIcon_001.png");
            case 2: sprite.loadGraphic("assets/sprites/CC_marchIcon_001.png");
            case 3: sprite.loadGraphic("assets/sprites/CC_aprilIcon_001.png");
            case 4: sprite.loadGraphic("assets/sprites/CC_mayIcon_001.png");
            case 5: sprite.loadGraphic("assets/sprites/CC_juneIcon_001.png");
            case 6: sprite.loadGraphic("assets/sprites/CC_julyIcon_001.png");
            case 7: sprite.loadGraphic("assets/sprites/CC_augustIcon_001.png");
            case 8: sprite.loadGraphic("assets/sprites/CC_septemberIcon_001.png");
            case 9: sprite.loadGraphic("assets/sprites/CC_octoberIcon_001.png");
            case 10: sprite.loadGraphic("assets/sprites/CC_novemberIcon_001.png");
            case 11: sprite.loadGraphic("assets/sprites/CC_decemberIcon_001.png");
            default: sprite.makeGraphic(64, 64, 0xFFFFFFFF);
        }
        sprite.x = FlxG.width - sprite.width - 10;
        sprite.y = FlxG.height - sprite.height - 10;

		add(sprite);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		#if !android
        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(sliderKnob))
        {
            dragging = true;
        }
        else if (FlxG.mouse.justReleased)
        {
            dragging = false;
			saveCurrentOptions();
        }

        if (dragging)
        {
            sliderKnob.x = Math.max(minX, Math.min(maxX, FlxG.mouse.x - sliderKnob.width / 2));
            var newVolume = (sliderKnob.x - minX) / (maxX - minX);
            FlxG.sound.volume = newVolume;
            MusicManager.setGlobalVolume(newVolume);
            volumeText.text = Std.string(Math.round(newVolume * 100)) + "%";
        }
		#end

		static var wasDragging = false;
		if (wasDragging && !dragging)
		{

		}
		wasDragging = dragging;
    }
	function saveCurrentOptions():Void
	{
		var currentOptions = GameSaveManager.loadOptions();
		var language = currentOptions != null ? currentOptions.language : "en-US";
		GameSaveManager.saveOptions({language: language, volume: FlxG.sound.volume});
	}
}
