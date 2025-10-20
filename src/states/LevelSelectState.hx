package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import ui.backgrounds.Starfield;
import ui.menu.TextButton;
import utils.BMFont;
import utils.ModIntegration;

class LevelSelectState extends FlxState
{
	var font:FlxBitmapFont;
	var levels:Array<LevelInfo>;
	var selectedIndex:Int = 0;
	var levelButtons:Array<TextButton>;
	var descriptionText:FlxBitmapText;
	var authorText:FlxBitmapText;
	var selectionMarker:FlxSprite;

	override public function create()
	{
		super.create();

		var starfield = new Starfield();
		add(starfield);

		var fontString = Main.tongue.getFontData("pixel_operator", 16).name;
		font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

		var scaleBig = 1.3;
		var title = new FlxBitmapText(0, 0, "Select Level", font);
		title.scale.set(scaleBig, scaleBig);
		title.updateHitbox();
		title.x = Math.floor((FlxG.width - title.frameWidth * scaleBig) / 2);
		title.y = 30;
		add(title);

		loadAvailableLevels();

		if (levels.length == 0)
		{
			var noLevelsText = new FlxBitmapText(0, 0, "No levels found", font);
			noLevelsText.color = 0xFFFF0000;
			noLevelsText.updateHitbox();
			noLevelsText.x = Math.floor((FlxG.width - noLevelsText.frameWidth) / 2);
			noLevelsText.y = 100;
			add(noLevelsText);

			var backButton = new TextButton(30, FlxG.height - 60, Main.tongue.get("$BUTTON_BACK", "ui"), font, 100, 40);
			backButton.setCallback(() -> FlxG.switchState(() -> new MainMenuState()));
			add(backButton);

			return;
		}

		levelButtons = [];
		var buttonStartY = title.y + title.frameHeight + 40;
		var buttonHeight = 40;
		var buttonSpacing = 5;

		for (i in 0...levels.length)
		{
			var level = levels[i];
			var btn = new TextButton(60, buttonStartY + i * (buttonHeight + buttonSpacing), level.name, font, 200, buttonHeight);

			var levelIndex = i;
			btn.setCallback(() -> selectLevel(levelIndex));

			add(btn);
			levelButtons.push(btn);
		}

		selectionMarker = new FlxSprite(20, buttonStartY);
		selectionMarker.makeGraphic(30, 30, 0xFF2196F3);
		add(selectionMarker);

		var infoPanelY = buttonStartY + (levels.length * (buttonHeight + buttonSpacing)) + 30;

		var descLabel = new FlxBitmapText(40, infoPanelY, "Description:", font);
		descLabel.scale.set(0.8, 0.8);
		add(descLabel);

		descriptionText = new FlxBitmapText(40, infoPanelY + 20, "", font);
		descriptionText.scale.set(0.7, 0.7);
		descriptionText.color = 0xFFCCCCCC;
		add(descriptionText);

		authorText = new FlxBitmapText(40, infoPanelY + 60, "", font);
		authorText.scale.set(0.6, 0.6);
		authorText.color = 0xFF999999;
		add(authorText);

		var startButton = new TextButton(FlxG.width - 250, FlxG.height - 60, "Start Level", font, 100, 40);
		startButton.setCallback(() -> startSelectedLevel());
		add(startButton);

		var backButton = new TextButton(30, FlxG.height - 60, Main.tongue.get("$BUTTON_BACK", "ui"), font, 100, 40);
		backButton.setCallback(() -> FlxG.switchState(() -> new MainMenuState()));
		add(backButton);

		selectLevel(0);
	}

	private function loadAvailableLevels():Void
	{
		levels = [];

		levels.push({
			name: "Ship: Main",
			path: "assets/maps/ship-main.tmx",
			tileset: "assets/sprites/CC_shipSheet_001.png",
			description: "The main deck of the ship",
			author: "Game"
		});

		levels.push({
			name: "Ship: Cockpit",
			path: "assets/maps/ship-cockpit.tmx",
			tileset: "assets/sprites/CC_shipSheet_001.png",
			description: "The ship's control center",
			author: "Game"
		});

		levels.push({
			name: "Ship: Stairs",
			path: "assets/maps/ship-stairs.tmx",
			tileset: "assets/sprites/CC_shipSheet_001.png",
			description: "Connecting stairwell",
			author: "Game"
		});

		levels.push({
			name: "Ship: Top Floor",
			path: "assets/maps/ship-topfloor.tmx",
			tileset: "assets/sprites/CC_shipSheet_001.png",
			description: "The upper level of the ship",
			author: "Game"
		});

		var customMaps = ModIntegration.getAvailableCustomMaps();
		for (map in customMaps)
		{
			var mapPath = "mods/" + map.modId + "/maps/" + map.file;
			levels.push({
				name: map.name,
				path: mapPath,
				tileset: "assets/sprites/CC_shipSheet_001.png",
				description: "[From mod: " + map.modTitle + "]",
				author: "Mod"
			});
		}
	}

	private function selectLevel(index:Int):Void
	{
		selectedIndex = index;
		updateLevelInfo();

		if (selectedIndex >= 0 && selectedIndex < levels.length)
		{
			var buttonStartY = 140;
			var buttonHeight = 40;
			var buttonSpacing = 5;
			var newY = buttonStartY + selectedIndex * (buttonHeight + buttonSpacing) + 5;
			selectionMarker.y = newY;
		}
	}

	private function updateLevelInfo():Void
	{
		if (selectedIndex >= 0 && selectedIndex < levels.length)
		{
			var level = levels[selectedIndex];
			descriptionText.text = level.description;
			authorText.text = "Author: " + level.author;
		}
	}

	private function startSelectedLevel():Void
	{
		if (selectedIndex >= 0 && selectedIndex < levels.length)
		{
			var level = levels[selectedIndex];
			MapSelectState.selectedMap = level.path;
			MapSelectState.selectedTileset = level.tileset;
			FlxG.switchState(() -> new GameState());
		}
	}

	override public function update(dt:Float):Void
	{
		super.update(dt);

		if (FlxG.keys.justPressed.UP)
		{
			selectLevel(Std.int(Math.max(0, selectedIndex - 1)));
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			selectLevel(Std.int(Math.min(levels.length - 1, selectedIndex + 1)));
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			startSelectedLevel();
		}
	}
}

typedef LevelInfo = {
	var name:String;
	var path:String;
	var tileset:String;
	var description:String;
	var author:String;
}

class MapSelectState
{
	public static var selectedMap:String = "assets/maps/ship-main.tmx";
	public static var selectedTileset:String = "assets/sprites/CC_shipSheet_001.png";
}
