package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import managers.ModManager;
import ui.backgrounds.Starfield;
import ui.menu.TextButton;
import utils.BMFont;

class ModsState extends FlxState
{
	var font:FlxBitmapFont;
	var modsList:Array<ModInfo>;
	var selectedIndex:Int = 0;
	var modInfoDisplay:FlxGroup;
	var scrollOffset:Int = 0;
	var maxVisibleMods:Int = 5;

	override public function create()
	{
		super.create();

		var starfield = new Starfield();
		add(starfield);

		var fontString = Main.tongue.getFontData("pixel_operator", 16).name;
		font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

		var scaleBig = 1.3;
		var title = new FlxBitmapText(0, 0, Main.tongue.get("$MODS_TITLE", "ui"), font);
		title.scale.set(scaleBig, scaleBig);
		title.updateHitbox();
		title.x = Math.floor((FlxG.width - title.frameWidth * scaleBig) / 2);
		title.y = 30;
		add(title);

		var modManager = ModManager.getInstance();
		var allMods = modManager.getAllMods();

		modsList = [];
		for (modId in allMods.keys())
		{
			var modData = allMods.get(modId);
			modsList.push({
				id: modId,
				title: modData.title,
				description: modData.description,
				version: modData.version,
				author: modData.author,
				enabled: modManager.isModEnabled(modId)
			});
		}

		var listStartY = title.y + title.frameHeight + 30;
		var listStartX = 30;
		var lineHeight = 50;

		modInfoDisplay = new FlxGroup();
		add(modInfoDisplay);

		for (i in 0...maxVisibleMods)
		{
			var modIndex = scrollOffset + i;
			if (modIndex < modsList.length)
			{
				var mod = modsList[modIndex];
				createModEntry(modIndex, listStartX, listStartY + i * lineHeight, lineHeight);
			}
		}

		var backButton = new TextButton(30, FlxG.height - 60, Main.tongue.get("$GENERAL_BACK", "ui"), font, 100, 40);
		backButton.setCallback(() -> FlxG.switchState(() -> new MainMenuState()));
		add(backButton);

		var infoText = new FlxBitmapText(0, 0, Main.tongue.get("$MODS_INSTRUCTIONS", "ui"), font);
		infoText.scale.set(0.7, 0.7);
		infoText.updateHitbox();
		infoText.x = 30;
		infoText.y = FlxG.height - 30;
		add(infoText);
	}

	private function createModEntry(modIndex:Int, x:Float, y:Float, height:Float):Void
	{
		var mod = modsList[modIndex];
		var modManager = ModManager.getInstance();

		var bg = new FlxSprite(x, y);
		bg.makeGraphic(Std.int(FlxG.width - 60), Std.int(height), selectedIndex == modIndex ? 0xFF2196F3 : 0xFF333333);
		modInfoDisplay.add(bg);

		var titleText = new FlxBitmapText(x + 10, y + 5, mod.title + (mod.enabled ? " " + Main.tongue.get("$MODS_STATUS_ON", "ui") : " " + Main.tongue.get("$MODS_STATUS_OFF", "ui")), font);
		titleText.scale.set(0.9, 0.9);
		titleText.color = 0xFFFFFFFF;
		modInfoDisplay.add(titleText);

		var descText = new FlxBitmapText(x + 10, y + 18, mod.description, font);
		descText.scale.set(0.65, 0.65);
		descText.color = 0xFFCCCCCC;
		modInfoDisplay.add(descText);

		var infoText = new FlxBitmapText(x + 10, y + 32, "v" + mod.version + " by " + mod.author, font);
		infoText.scale.set(0.6, 0.6);
		infoText.color = 0xFF999999;
		modInfoDisplay.add(infoText);
	}

	private function updateDisplay():Void
	{
		modInfoDisplay.clear();

		var listStartY = 120;
		var listStartX = 30;
		var lineHeight = 50;

		for (i in 0...maxVisibleMods)
		{
			var modIndex = scrollOffset + i;
			if (modIndex < modsList.length)
			{
				createModEntry(modIndex, listStartX, listStartY + i * lineHeight, lineHeight);
			}
		}
	}

	override public function update(dt:Float):Void
	{
		super.update(dt);

		if (modsList.length == 0)
			return;

		if (FlxG.keys.justPressed.UP)
		{
			selectedIndex--;
			if (selectedIndex < 0)
				selectedIndex = modsList.length - 1;

			if (selectedIndex < scrollOffset)
				scrollOffset = selectedIndex;

			updateDisplay();
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			selectedIndex++;
			if (selectedIndex >= modsList.length)
				selectedIndex = 0;

			if (selectedIndex >= scrollOffset + maxVisibleMods)
				scrollOffset = selectedIndex - maxVisibleMods + 1;

			updateDisplay();
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			var mod = modsList[selectedIndex];
			var modManager = ModManager.getInstance();

			if (mod.enabled)
			{
				modManager.disableMod(mod.id);
				mod.enabled = false;
			}
			else
			{
				modManager.enableMod(mod.id);
				mod.enabled = true;
			}

			updateDisplay();
		}
	}
}

typedef ModInfo = {
	var id:String;
	var title:String;
	var description:String;
	var version:String;
	var author:String;
	var enabled:Bool;
}
