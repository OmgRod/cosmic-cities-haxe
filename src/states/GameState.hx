package states;

import entities.Player;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import gameplay.ChapterRegistry;
import gameplay.GameplayContext;
import gameplay.GameplayMode;
import managers.MusicManager;
import modding.ModHookContext;
import modding.ModHookEvents;
import modding.ModHooks;
import states.LevelSelectState;
import ui.NotesLayer;
import ui.Overlay;
import ui.PauseMenu;
import ui.backgrounds.Starfield;
import ui.dialog.DialogBox;
import utils.GameSaveManager;
import utils.GameUtils;

/**
 * Main gameplay state for Cosmic Cities.
 * 
 * Responsibilities:
 * - Load and manage game maps
 * - Handle player input and movement
 * - Manage camera following
 * - Trigger room transitions
 * - Coordinate UI elements (pause menu, dialogue, overlays)
 * - Emit mod hooks for extensibility
 */
class GameState extends FlxState
{
	// Gameplay context
	public static var gameplayContext:GameplayContext;
	
	// Map and collision data
	var mapGroup:FlxGroup;
	var wallsGroup:FlxGroup;
	var roomSwapGroup:FlxGroup;
	var hitboxes:Array<
		{
			x:Float,
			y:Float,
			width:Float,
			height:Float
		}> = [];
	var roomSwaps:Array<{sprite:FlxSprite, data:Dynamic}> = [];
	var mapWidth:Int = 0;
	var mapHeight:Int = 0;

	// Entities
	var player:Player;
	var cameraTarget:FlxSprite;
	var cameraYOffset:Float = 8;

	// UI
	var notesLayer:NotesLayer;
	var pauseMenu:PauseMenu;
	var dialogBox:DialogBox;
	var blackOverlay:Overlay;
	var orangeOverlay:Overlay;
	var shipExplosionSprite:FlxSprite;
	var boundingBoxes:Array<FlxSprite> = [];

	// Game state
	var playerFrozen:Bool = false;
	var isDialogueActive:Bool = false;
	var dialogCooldown:Float = 0.0;
	var idleTime:Float = 0.0;
	var idleThreshold:Float = 10.0;
	var hasShownIdleMessage:Bool = false;
	var debugHitboxes:Bool = false;
	var touchingNoteData:String = "";
	var touchingBoundingBox:Bool = false;
	var enterPressedInBoundingBox:Bool = false;

	// Controls
	var controlBindings:Dynamic;

	override public function create()
	{
		super.create();
		ModHooks.run(ModHookEvents.GAMESTATE_CREATE_PRE, new ModHookContext(this));

		add(new Starfield());

		controlBindings = GameSaveManager.getControls();
		trace("Loaded controls: moveLeft=" + controlBindings.moveLeft + " moveRight=" + controlBindings.moveRight);


		// Initialize gameplay context if not already done
		if (gameplayContext == null) {
			gameplayContext = new GameplayContext();
			// Use map from MapSelectState or default chapter
			if (MapSelectState.selectedMap != null && MapSelectState.selectedMap != "") {
				gameplayContext.currentMap = MapSelectState.selectedMap;
				gameplayContext.currentTileset = MapSelectState.selectedTileset;
			}
		}

		// Load map from gameplay context
		loadMap(gameplayContext.currentMap, gameplayContext.currentTileset);

		// UI
		blackOverlay = new Overlay(0xFF000000, 0);
		add(blackOverlay);

		orangeOverlay = new Overlay(0xFFFF8800, 0);
		add(orangeOverlay);

		shipExplosionSprite = GameUtils.createShipExplosionSprite();
		if (shipExplosionSprite != null)
			add(shipExplosionSprite);

		dialogBox = new DialogBox();
		add(dialogBox);

		pauseMenu = new PauseMenu(() -> {}, () -> GameSaveManager.saveOptions(GameSaveManager.loadOptionsWithDefaults()));
		add(pauseMenu);

		var postPayload = {
			player: player,
			mapGroup: mapGroup,
			wallsGroup: wallsGroup,
			dialogBox: dialogBox,
			blackOverlay: blackOverlay,
			orangeOverlay: orangeOverlay,
			pauseMenu: pauseMenu
		};
		ModHooks.run(ModHookEvents.GAMESTATE_CREATE_POST, new ModHookContext(this, postPayload));
	}

	private function loadMap(tmxPath:String, tilesetPath:String):Void
	{
		// Clean up previous map
		if (mapGroup != null)
		{
			remove(mapGroup);
			mapGroup.destroy();
		}
		if (wallsGroup != null)
		{
			remove(wallsGroup);
			wallsGroup.destroy();
		}
		if (roomSwapGroup != null)
		{
			remove(roomSwapGroup);
			roomSwapGroup.destroy();
		}
		if (player != null)
		{
			remove(player);
			player.destroy();
		}
		if (notesLayer != null)
		{
			remove(notesLayer);
			notesLayer.destroy();
		}

		// Load new map data
		var mapData = GameUtils.loadMapData(tmxPath, tilesetPath);
		mapGroup = mapData.mapGroup;
		wallsGroup = mapData.wallsGroup;
		roomSwapGroup = mapData.roomSwapGroup;
		hitboxes = mapData.hitboxes;
		roomSwaps = mapData.roomSwaps;
		mapWidth = mapData.mapWidth;
		mapHeight = mapData.mapHeight;
		boundingBoxes = mapData.boundingBoxes;

		add(mapGroup);
		add(wallsGroup);
		add(roomSwapGroup);

		for (bbox in boundingBoxes)
		{
			add(bbox);
		}

		// Create player
		var spawn = mapData.spawnPoint;
		player = new Player(spawn.x, spawn.y);
		add(player);

		// Create camera target
		if (cameraTarget != null)
		{
			remove(cameraTarget);
			cameraTarget.destroy();
		}

		cameraTarget = new FlxSprite(player.x + player.width / 2, player.y + player.height / 2 - cameraYOffset);
		cameraTarget.makeGraphic(1, 1, 0x00000000);
		cameraTarget.visible = false;
		add(cameraTarget);
		FlxG.camera.follow(cameraTarget);
		FlxG.camera.setScrollBoundsRect(0, 0, mapWidth, mapHeight);

		// Create notes layer
		notesLayer = new NotesLayer();
		add(notesLayer);

		// Reset state
		idleTime = 0.0;
		hasShownIdleMessage = false;
		touchingNoteData = "";
		touchingBoundingBox = false;
		enterPressedInBoundingBox = false;
	}

	override public function update(elapsed:Float):Void
	{
		ModHooks.run(ModHookEvents.GAMESTATE_UPDATE_PRE, new ModHookContext(this, {elapsed: elapsed}));

		if (dialogCooldown > 0)
			dialogCooldown -= elapsed;

		#if !android
		if (FlxG.keys.justPressed.H)
		{
			debugHitboxes = !debugHitboxes;
			for (wall in wallsGroup.members)
			{
				var wallSprite = cast(wall, FlxSprite);
				if (debugHitboxes)
					wallSprite.makeGraphic(Std.int(wallSprite.width), Std.int(wallSprite.height), 0x80FF0000);
				else
					wallSprite.makeGraphic(Std.int(wallSprite.width), Std.int(wallSprite.height), 0x00FFFFFF);
			}
			for (swap in roomSwapGroup.members)
				swap.visible = debugHitboxes;
			for (bbox in boundingBoxes)
				bbox.visible = debugHitboxes;
			trace("Debug hitboxes: " + (debugHitboxes ? "ON" : "OFF"));
		}

		if (FlxG.keys.justPressed.ESCAPE && !dialogBox.isActive)
			pauseMenu.toggle();
		#end

		if (pauseMenu.isPauseActive())
		{
			pauseMenu.update(elapsed);
			super.update(elapsed);
			ModHooks.run(ModHookEvents.GAMESTATE_UPDATE_POST, new ModHookContext(this, {elapsed: elapsed, paused: true}));
			return;
		}

		super.update(elapsed);

		// Player movement
		var speed = 150;
		var moveX = 0.0;
		var moveY = 0.0;

		#if !android
		if (!dialogBox.isActive && !playerFrozen)
		{
			speed = FlxG.keys.pressed.X ? 250 : 150;

			var pressLeft = GameUtils.isKeyPressed(controlBindings.moveLeft);
			var pressRight = GameUtils.isKeyPressed(controlBindings.moveRight);
			var pressUp = GameUtils.isKeyPressed(controlBindings.moveUp);
			var pressDown = GameUtils.isKeyPressed(controlBindings.moveDown);

			if (pressLeft && !pressRight)
				moveX = -speed * elapsed;
			else if (pressRight && !pressLeft)
				moveX = speed * elapsed;

			if (pressUp && !pressDown)
				moveY = -speed * elapsed;
			else if (pressDown && !pressUp)
				moveY = speed * elapsed;
		}
		#end

		if (playerFrozen)
			player.moves = false;
		// Collision-aware movement
		var testX = player.x + moveX;
		if (!GameUtils.checkCollision(testX, player.y, 28, 28, hitboxes))
			player.x = testX;

		var testY = player.y + moveY;
		if (!GameUtils.checkCollision(player.x, testY, 28, 28, hitboxes))
			player.y = testY;

		// Update camera
		cameraTarget.x = player.x + player.width / 2;
		cameraTarget.y = player.y + player.height / 2 - cameraYOffset;

		// Track idle time for tutorial
		var hasMovementInput = GameUtils.isKeyPressed(controlBindings.moveLeft)
			|| GameUtils.isKeyPressed(controlBindings.moveRight)
			|| GameUtils.isKeyPressed(controlBindings.moveUp)
			|| GameUtils.isKeyPressed(controlBindings.moveDown);

		if (hasMovementInput)
		{
			idleTime = 0.0;
			hasShownIdleMessage = false;
		}
		else if (!dialogBox.isActive)
		{
			idleTime += elapsed;
			if (idleTime >= idleThreshold && !hasShownIdleMessage)
			{
				hasShownIdleMessage = true;
				showMovementTutorial();
			}
		}

		// Interaction checks
		if (notesLayer != null)
			checkNoteCollision();

		checkBoundingBoxCollision();

		// Room transitions
		for (roomSwap in roomSwaps)
		{
			if (player.overlaps(roomSwap.sprite))
			{
				var rs = roomSwap.data;
				FlxG.camera.fade(0xFF000000, 0.3, false, function()
				{
					loadMap(rs.roomFilename, "assets/sprites/CC_shipSheet_001.png");
					FlxG.camera.fade(0xFF000000, 0.3, true);
				});
				break;
			}
		}

		ModHooks.run(ModHookEvents.GAMESTATE_UPDATE_POST, new ModHookContext(this, {
			elapsed: elapsed,
			paused: false,
			moveX: moveX,
			moveY: moveY
		}));
	}

	private function checkNoteCollision():Void
	{
		var noteBounds = notesLayer.getNoteBounds();
		touchingNoteData = "";

		for (bounds in noteBounds)
		{
			if (player.overlaps(bounds))
			{
				var boundsMap = notesLayer.getNoteBoundsMap();
				for (noteData => noteBound in boundsMap)
				{
					if (noteBound == bounds)
					{
						touchingNoteData = noteData;
						if (FlxG.keys.justPressed.ENTER)
							collectNote(noteData);
						break;
					}
				}
				break;
			}
		}
	}

	private function collectNote(noteData:String):Void
	{
		var blipNum = FlxG.random.int(1, 5);
		FlxG.sound.play("assets/sounds/sfx.blip." + blipNum + ".wav", 0.7);

		notesLayer.collectNote(noteData);

		var template = Main.tongue.get("$NOTE_COLLECTED", "dialog");
		var dialogueText:String = untyped (template);

		if (dialogueText.indexOf("{count}") >= 0)
			dialogueText = StringTools.replace(dialogueText, "{count}", "1");

		showDialogue("SYSTEM", dialogueText);
		touchingNoteData = "";
	}

	private function checkBoundingBoxCollision():Void
	{
		touchingBoundingBox = false;

		for (bbox in boundingBoxes)
		{
			if (player.overlaps(bbox))
			{
				if (!FlxG.keys.pressed.ENTER)
					enterPressedInBoundingBox = false;

				touchingBoundingBox = true;

				if (FlxG.keys.justPressed.ENTER && !enterPressedInBoundingBox && !isDialogueActive && !dialogBox.isActive && dialogCooldown <= 0)
				{
					enterPressedInBoundingBox = true;
					var blipNum = FlxG.random.int(1, 5);
					FlxG.sound.play("assets/sounds/sfx.blip." + blipNum + ".wav", 0.7);

					if (blackOverlay != null)
					{
						var fadeDuration:Float = 3.0;
						FlxTween.tween(blackOverlay, {alpha: 1}, fadeDuration);
						var currentMusic = MusicManager.getCurrent();
						if (currentMusic != null)
							MusicManager.fadeToVolume(currentMusic, 0.05, fadeDuration);
					}
					dialogCooldown = 0.5;
				}
			}
			else
			{
				enterPressedInBoundingBox = false;
			}
		}
	}

	private function showDialogue(speaker:String, text:String):Void
	{
		isDialogueActive = true;
		dialogBox.show(speaker, text, () ->
		{
			isDialogueActive = false;
		});
	}

	private function showMovementTutorial():Void
	{
		var options = GameSaveManager.loadOptionsWithDefaults();
		var locale = options.language;
		var prevLocale = Main.tongue.locale;
		Main.tongue.initialize({locale: locale});
		var tutorialMessage = Main.tongue.get("$MOVEMENT_TUTORIAL", "dialog");
		Main.tongue.initialize({locale: prevLocale});

		if (tutorialMessage != null && tutorialMessage.length > 0)
			dialogBox.show("System", tutorialMessage, null);
	}

	override public function destroy():Void
	{
		var payload = {
			player: player,
			pauseMenu: pauseMenu,
			dialogBox: dialogBox
		};
		ModHooks.run(ModHookEvents.GAMESTATE_DESTROY_PRE, new ModHookContext(this, payload));
		MusicManager.stop("geton");
		super.destroy();
		ModHooks.run(ModHookEvents.GAMESTATE_DESTROY_POST, new ModHookContext(this, payload));
	}
}
