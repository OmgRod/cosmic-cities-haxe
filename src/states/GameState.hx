package states;

import entities.Player;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxDirectionFlags;
import gameplay.GameplayManager;
import managers.DialogueManager;
import managers.EventManager;
import managers.GameManager;
import managers.InteractionManager;
import managers.MusicManager;
import managers.StoryManager;
import ui.PauseMenu;
import ui.backgrounds.Starfield;
// import ui.menu.ProgressBar;
import utils.GameSaveManager;
import utils.TmxSimple;

class GameState extends FlxState
{
	var gameManager:GameManager;
	var eventManager:EventManager;
	var storyManager:StoryManager;
	var dialogueManager:DialogueManager;
	var gameplayManager:GameplayManager;
	var interactionManager:InteractionManager;

	var mapGroup:FlxGroup;
	var player:Player;
	var mapWidth:Int = 0;
	var mapHeight:Int = 0;
	var walls:Array<FlxSprite>;
	var wallsGroup:FlxGroup;
	
	var roomSwapGroup:FlxGroup;
	var roomSwapDataArr:Array<Dynamic> = [];
	var mapOffsetX:Float = 0;
	var mapOffsetY:Float = 0;
	var cameraTarget:FlxSprite;
	var cameraYOffset:Float = 8;

	var pauseMenu:PauseMenu;
	var debugHitboxes:Bool = false;

	var hitboxes:Array<
		{
			x:Float,
			y:Float,
			width:Float,
			height:Float
		}> = [];

	override public function create()
    {
		super.create();

		var starfield = new Starfield();
		add(starfield);

		// var progressBar = new ProgressBar((FlxG.width / 2) - (460 / 2), 32, 460);
		// add(progressBar);

		MusicManager.stop("intro");

		gameManager = GameManager.getInstance();
		eventManager = EventManager.getInstance();
		storyManager = StoryManager.getInstance();
		dialogueManager = DialogueManager.getInstance();
		interactionManager = InteractionManager.getInstance();
		gameplayManager = GameplayManager.getInstance();

		setupEventListeners();

		var username = (GameSaveManager.currentData != null) ? GameSaveManager.currentData.username : "Player";
		gameManager.startNewGame(username);

		storyManager.setChapter("chapter_1");
		storyManager.setScene("ship_intro");

		dialogueManager.startDialogue("tutorial");

		loadMap("assets/maps/ship-main.tmx", "assets/sprites/CC_shipSheet_001.png", null, null);
		pauseMenu = new PauseMenu(() -> {}, () -> gameManager.saveGame());
		add(pauseMenu);
		gameplayManager.init(this);

		gameplayManager.startEvacuationSequence();
	}

	private function loadMap(tmxPath:String, tilesetPath:String, playerX:Null<Float>, playerY:Null<Float>):Void
	{
		if (mapGroup != null)
			remove(mapGroup);
		if (wallsGroup != null)
			remove(wallsGroup);
		if (walls != null)
		{
			walls = [];
		}
		hitboxes = [];
		
		if (roomSwapGroup != null)
			remove(roomSwapGroup);

		var result = TmxSimple.load(tmxPath, tilesetPath);

		mapGroup = new FlxGroup();
		for (layer in result.layers)
		{
			layer.immovable = true;
			mapGroup.add(layer);
		}
		add(mapGroup);

		mapWidth = result.pixelWidth;
		mapHeight = result.pixelHeight;

		walls = [];
		wallsGroup = new FlxGroup();
		hitboxes = [];
		trace("=== CREATING COLLISION WALLS ===");
		trace("Hitboxes from TMX: " + result.hitboxes.length);

		for (i in 0...result.hitboxes.length)
		{
			var hb = result.hitboxes[i];

			hitboxes.push({
				x: hb.x,
				y: hb.y,
				width: hb.width,
				height: hb.height
			});

			var wall = new FlxSprite(hb.x, hb.y);

			var color = debugHitboxes ? 0x80FF0000 : 0x00FFFFFF;
			wall.makeGraphic(Std.int(hb.width), Std.int(hb.height), color);

			wall.setSize(Std.int(hb.width), Std.int(hb.height));
			wall.updateHitbox();

			wall.immovable = true;
			wall.solid = true;
			wall.moves = false;
			wall.allowCollisions = FlxDirectionFlags.ANY;

			walls.push(wall);
			wallsGroup.add(wall);

			trace("  Wall " + i + ": pos=(" + wall.x + ", " + wall.y + ") size=" + wall.width + "x" + wall.height);
		}
		add(wallsGroup);
		trace("=== CREATED " + walls.length + " WALLS ===");

		roomSwapGroup = new FlxGroup();
		roomSwapDataArr = [];
		for (rs in result.roomSwaps)
		{
			var swap = new FlxSprite(rs.x, rs.y);
			swap.makeGraphic(Std.int(rs.width), Std.int(rs.height), 0x800000FF);
			swap.immovable = true;
			swap.moves = false;
			swap.visible = debugHitboxes;
			swap.ID = roomSwapGroup.length;
			swap.setGraphicSize(Std.int(rs.width), Std.int(rs.height));
			swap.updateHitbox();
			roomSwapDataArr.push(rs);
			roomSwapGroup.add(swap);
		}
		add(roomSwapGroup);

		var spawnPxX = 2382.0;
		var spawnPxY = 781.0;

		if (player == null)
		{
			player = new Player(spawnPxX, spawnPxY);
			add(player);
		}
		if (playerX != null && playerY != null)
		{
			player.x = playerX;
			player.y = playerY;
		}

		if (cameraTarget == null)
		{
			cameraTarget = new FlxSprite(player.x, player.y);
			cameraTarget.makeGraphic(1, 1, 0x00000000);
			cameraTarget.visible = false;
		}
		FlxG.camera.follow(cameraTarget);
		FlxG.camera.setScrollBoundsRect(0, 0, mapWidth, mapHeight);
	}

	function setupEventListeners():Void
	{
		eventManager.on("story:learned_destination", _ -> storyManager.setFlag("story:learned_destination", 1));

		eventManager.on("tutorial:completed", _ -> storyManager.setFlag("tutorial_done", 1));
		eventManager.on("tutorial:skipped", _ -> storyManager.setFlag("tutorial_skipped", 1));

		eventManager.on("relationship:captain_respected", _ ->
		{
			var lvl = storyManager.getFlag("relationship:captain_level", 0);
			storyManager.setFlag("relationship:captain_level", lvl + 1);
		});

		eventManager.on("interact:control_panel", _ -> trace("Control panel opened"));
		eventManager.on("read:captains_log", _ -> trace("Reading captain's log"));
	}

	override public function update(elapsed:Float):Void
	{
		gameplayManager.update(elapsed);

		super.update(elapsed);

		#if !android
		if (FlxG.keys.justPressed.H)
		{
			toggleHitboxVisibility();
			trace("Debug hitboxes: " + (debugHitboxes ? "ON" : "OFF"));
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			pauseMenu.toggle();
		}
		#end

		if (pauseMenu.isPauseActive())
		{
			pauseMenu.update(elapsed);
			return;
		}

		var speed = 150;
		var moveX = 0.0;
		var moveY = 0.0;

		#if !android
		if (!gameplayManager.isDialogueActive())
		{
			if (FlxG.keys.pressed.LEFT)
				moveX = -speed * elapsed;
			if (FlxG.keys.pressed.RIGHT)
				moveX = speed * elapsed;
			if (FlxG.keys.pressed.UP)
				moveY = -speed * elapsed;
			if (FlxG.keys.pressed.DOWN)
				moveY = speed * elapsed;
		}
		#end

		var playerWidth = 28;
		var playerHeight = 28;

		var testX = player.x + moveX;
		if (!checkCollision(testX, player.y, playerWidth, playerHeight))
		{
			player.x = testX;
		}

		var testY = player.y + moveY;
		if (!checkCollision(player.x, testY, playerWidth, playerHeight))
		{
			player.y = testY;
		}

		cameraTarget.x = player.x + player.width / 2;
		cameraTarget.y = player.y + player.height / 2 - cameraYOffset;

		for (swap in roomSwapGroup)
		{
			if (player.overlaps(swap))
			{
				var idx:Int = swap.ID;
				var rs = null;
				if (idx >= 0 && idx < roomSwapDataArr.length)
				{
					rs = roomSwapDataArr[idx];
				}
				if (rs == null)
				{
					trace('Warning: No roomSwapData for swap index ' + idx);
					continue;
				}
				FlxG.camera.fade(0xFF000000, 0.3, false, function()
				{
					loadMap(rs.roomFilename, "assets/sprites/CC_shipSheet_001.png", rs.targetX, rs.targetY);
					FlxG.camera.fade(0xFF000000, 0.3, true);
				});
				break;
			}
		}
	}

	private function toggleHitboxVisibility():Void
	{
		debugHitboxes = !debugHitboxes;

		for (wall in walls)
		{
			if (debugHitboxes)
			{
				wall.makeGraphic(Std.int(wall.width), Std.int(wall.height), 0x80FF0000);
			}
			else
			{
				wall.makeGraphic(Std.int(wall.width), Std.int(wall.height), 0x00FFFFFF);
			}
		}

		for (swap in roomSwapGroup.members)
		{
			swap.visible = debugHitboxes;
		}
	}

	override public function destroy():Void
	{
		MusicManager.stop("geton");
		super.destroy();
	}

	function checkCollision(testX:Float, testY:Float, testWidth:Float, testHeight:Float):Bool
	{
		for (hb in hitboxes)
		{
			if (rectsOverlap(testX, testY, testWidth, testHeight, hb.x, hb.y, hb.width, hb.height))
			{
				return true;
			}
		}
		return false;
	}

	inline function rectsOverlap(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Bool
	{
		return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
	}
}
