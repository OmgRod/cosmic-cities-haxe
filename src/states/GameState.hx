package states;

import ase.Ase;
import entities.Player;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.util.FlxDirectionFlags;
import gameplay.GameplayManager;
import haxe.io.Bytes;
import managers.DialogueBuilder;
import managers.DialogueManager;
import managers.EventManager;
import managers.GameManager;
import managers.InteractionManager;
import managers.MusicManager;
import managers.NoteInventory;
import managers.StoryManager;
import modding.ModHookContext;
import modding.ModHookEvents;
import modding.ModHooks;
import openfl.display.BitmapData;
import states.LevelSelectState;
import ui.NotesLayer;
import ui.Overlay;
import ui.PauseMenu;
import ui.backgrounds.Starfield;
import ui.dialog.DialogBox;
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
	var notesLayer:NotesLayer;
	var mapWidth:Int = 0;
	var mapHeight:Int = 0;
	var walls:Array<FlxSprite>;
	var wallsGroup:FlxGroup;
	
	var roomSwapGroup:FlxGroup;
	var roomSwapDataArr:Array<Dynamic> = [];
	var mapOffsetX:Float = 0;
	var mapOffsetY:Float = 0;
	var spawnX:Float = 0.0;
	var spawnY:Float = 0.0;
	var spawnFound:Bool = false;
	var playerFrozen:Bool = false;
	var cameraTarget:FlxSprite;
	var cameraYOffset:Float = 8;

	var pauseMenu:PauseMenu;
	var debugHitboxes:Bool = false;
	var noteInventory:NoteInventory;
	var touchingNoteData:String = "";

	var boundingBox:FlxSprite;
	var touchingBoundingBox:Bool = false;
	var blackOverlay:Overlay;
	var orangeOverlay:Overlay;
	var shipExplosionSprite:FlxSprite;
	var dialogBox:DialogBox;
	var isDialogueActive:Bool = false;
	var dialogCooldown:Float = 0.0;
	var enterPressedInBoundingBox:Bool = false;

	var idleTime:Float = 0.0;
	var idleThreshold:Float = 10.0;
	var hasShownIdleMessage:Bool = false;

	var controlBindings:utils.GameSaveManager.ControlsData;

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
		ModHooks.run(ModHookEvents.GAMESTATE_CREATE_PRE, new ModHookContext(this));

		var starfield = new Starfield();
		add(starfield);

		controlBindings = GameSaveManager.getControls();
		trace("Loaded controls: moveLeft=" + controlBindings.moveLeft + " moveRight=" + controlBindings.moveRight);

		// var progressBar = new ProgressBar((FlxG.width / 2) - (460 / 2), 32, 460);
		// add(progressBar);

		MusicManager.stop("intro");
		FlxG.sound.music?.stop();
		FlxG.sound.music = null;

		gameManager = GameManager.getInstance();
		eventManager = EventManager.getInstance();
		storyManager = StoryManager.getInstance();
		dialogueManager = DialogueManager.getInstance();
		interactionManager = InteractionManager.getInstance();
		gameplayManager = GameplayManager.getInstance();
		noteInventory = NoteInventory.getInstance();

		DialogueBuilder.buildAllDialogues();

		var username = (GameSaveManager.currentData != null) ? GameSaveManager.currentData.username : "Player";
		gameManager.startNewGame(username);

		setupEventListeners();

		storyManager.setChapter("chapter_1");
		storyManager.setScene("ship_intro");

		dialogueManager.startDialogue("tutorial");

		var mapPath = MapSelectState.selectedMap;
		var tilesetPath = MapSelectState.selectedTileset;
		gameplayManager.initParsing();
		
		loadMap(mapPath, tilesetPath, null, null);

		gameplayManager.init(this);
		blackOverlay = new Overlay(0xFF000000, 0);
		add(blackOverlay);

		orangeOverlay = new Overlay(0xFFFF8800, 0);
		add(orangeOverlay);

		shipExplosionSprite = createShipExplosionSprite();
		if (shipExplosionSprite != null)
		{
			add(shipExplosionSprite);
		}

		dialogBox = new DialogBox();
		add(dialogBox);
		
		pauseMenu = new PauseMenu(() -> {}, () -> gameManager.saveGame());
		add(pauseMenu);

		gameplayManager.startEvacuationSequence();

		var postPayload = {
			player: player,
			mapGroup: mapGroup,
			wallsGroup: wallsGroup,
			noteInventory: noteInventory,
			dialogBox: dialogBox,
			blackOverlay: blackOverlay,
			orangeOverlay: orangeOverlay,
			pauseMenu: pauseMenu,
			gameplayManager: gameplayManager,
			eventManager: eventManager
		};
		ModHooks.run(ModHookEvents.GAMESTATE_CREATE_POST, new ModHookContext(this, postPayload));
	}

	private function loadMap(tmxPath:String, tilesetPath:String, playerX:Null<Float>, playerY:Null<Float>):Void
	{
		// Reset spawnFound for this map load — each map should indicate whether
		// it contains an explicit player-spawn object.
		spawnFound = false;
		// Destroy previous map group and children to avoid leftover sprites affecting the new map
		if (mapGroup != null)
		{
			try
			{
				remove(mapGroup);
				mapGroup.destroy();
			}
			catch (e:Dynamic) {}
			mapGroup = null;
		}
		if (wallsGroup != null)
		{
			try
			{
				remove(wallsGroup);
				wallsGroup.destroy();
			}
			catch (e:Dynamic) {}
			wallsGroup = null;
		}
		if (walls != null)
		{
			walls = [];
		}
		hitboxes = [];
		
		if (roomSwapGroup != null)
		{
			try
			{
				remove(roomSwapGroup);
				roomSwapGroup.destroy();
			}
			catch (e:Dynamic) {}
			roomSwapGroup = null;
		}

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

		gameplayManager.setMapObjectGroups(result.objectGroups);
		// Debug: list object groups parsed from TMX
		try
		{
			var keys = [];
			for (k in result.objectGroups.keys())
				keys.push(k);
			trace("[TMX DEBUG] objectGroups keys: " + Std.string(keys));
		}
		catch (e:Dynamic) {}

		var spawnPxX = 0.0;
		var spawnPxY = 0.0;

		if (result.objectGroups.exists("Metadata"))
		{
			var metadataObjects = result.objectGroups.get("Metadata");
			// Debug: show metadataObjects contents
			try
			{
				for (m in metadataObjects)
				{
					trace("[TMX DEBUG] Metadata object: name=" + Std.string(m.name) + " x=" + Std.string(m.x) + " y=" + Std.string(m.y));
				}
			}
			catch (e:Dynamic) {}
			for (obj in metadataObjects)
			{
				if (obj.name == "player-spawn")
				{
					spawnPxX = obj.x;
					spawnPxY = obj.y;
					// store into the class-level flag so other methods/closures
					// can observe whether a spawn point existed in the map.
					spawnFound = true;
					trace("Found player spawn point at (" + spawnPxX + ", " + spawnPxY + ")");
					break;
				}
			}
		}
		else
		{
			trace("[TMX DEBUG] Metadata group not found in TMX objectGroups");
		}
		loadBoundingBox(result.objectGroups);

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

		notesLayer = new NotesLayer();
		add(notesLayer);

		if (gameplayManager != null)
		{
			var letterPuzzles = gameplayManager.getLetterPuzzles();
			if (letterPuzzles != null && letterPuzzles.length > 0)
			{
				var availableNotes = [];
				for (puzzle in letterPuzzles)
				{
					if (!noteInventory.hasNote(puzzle.data))
					{
						availableNotes.push(puzzle);
					}
				}

				if (availableNotes.length > 0)
				{
					notesLayer.loadNotes(availableNotes);
				}
			}
		}

		spawnX = spawnPxX;
		spawnY = spawnPxY;
		// If no spawn was found in the TMX, try a roomSwap fallback or center on map
		if (!spawnFound)
		{
			// Prefer a roomSwap that targets 'ship-main' or similar, otherwise pick center
			var foundFallback:Bool = false;
			for (rs in roomSwapDataArr)
			{
				if (rs == null)
					continue;
				// Only use roomSwap target if it lies within this map's pixel bounds.
				if (rs.targetX != null && rs.targetY != null)
				{
					var tx = rs.targetX;
					var ty = rs.targetY;
					if (tx >= 0 && tx <= mapWidth && ty >= 0 && ty <= mapHeight)
					{
						spawnX = tx;
						spawnY = ty;
						foundFallback = true;
						trace("[SPAWN DEBUG] Using roomSwap fallback spawn -> ("
							+ spawnX
							+ ", "
							+ spawnY
							+ ") roomFilename="
							+ Std.string(rs.roomFilename));
						break;
					}
					else
					{
						trace("[SPAWN DEBUG] Ignoring roomSwap target (" + Std.string(tx) + ", " + Std.string(ty) + ") outside map bounds ("
							+ Std.string(mapWidth) + "," + Std.string(mapHeight) + ")");
					}
				}
			}
			if (!foundFallback)
			{
				// Default to map center (pixel coords)
				spawnX = Std.int(mapWidth / 2);
				spawnY = Std.int(mapHeight / 2);
				trace("[SPAWN DEBUG] No spawn or roomSwap fallback found; centering player at (" + spawnX + ", " + spawnY + ")");
			}
		}

		player = new Player(spawnX, spawnY);
		add(player);
		trace("[SPAWN DEBUG] Player created at player.x=" + Std.string(player.x) + " player.y=" + Std.string(player.y) + " spawnFound="
			+ Std.string(spawnFound));
		if (playerX != null && playerY != null)
		{
			player.x = playerX;
			player.y = playerY;
		}

		if (cameraTarget != null)
		{
			remove(cameraTarget);
			cameraTarget.destroy();
		}
		
		// Ensure camera target is centered on player's body to avoid 0,0 snap
		cameraTarget = new FlxSprite(player.x + player.width / 2, player.y + player.height / 2 - cameraYOffset);
		cameraTarget.makeGraphic(1, 1, 0x00000000);
		cameraTarget.visible = false;
		add(cameraTarget);
		FlxG.camera.follow(cameraTarget);
		FlxG.camera.setScrollBoundsRect(0, 0, mapWidth, mapHeight);
		try
		{
			trace("[CAMERA DEBUG] cameraTarget initial=(" + Std.string(cameraTarget.x) + ", " + Std.string(cameraTarget.y) + ") mapW="
				+ Std.string(mapWidth) + " mapH=" + Std.string(mapHeight));
		}
		catch (e:Dynamic) {}
		// Emit a one-time warning if player or camera are at origin which previously caused 'stuck' symptoms
		try
		{
			if ((player != null && player.x == 0 && player.y == 0) || (cameraTarget != null && cameraTarget.x == 0 && cameraTarget.y == 0))
			{
				trace('[SPAWN WARNING] player or camera at (0,0) after load - spawnFound=' + Std.string(spawnFound));
			}
		}
		catch (e:Dynamic) {}
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
		eventManager.on("evacuation_timer_expired", _ ->
		{
			trace("Timer expired! Playing ship explosion animation");
			
			if (orangeOverlay != null)
			{
				orangeOverlay.visible = false;
			}

			// Hide any red alarm overlay that may be frozen (added by EvacuationIntro)
			try
			{
				for (m in this.members)
				{
					if (Std.isOfType(m, Overlay))
					{
						var ov:Overlay = cast m;
						// 0xFFFF0000 is the red overlay used by the evacuation alarm
						if (ov != null && ov.color == 0xFFFF0000)
						{
							ov.visible = false;
							ov.alpha = 0;
						}
					}
				}
			}
			catch (e:Dynamic)
			{
				trace('[UI] Error hiding red overlays: ' + Std.string(e));
			}

			// Stop any ongoing SFX (like the alarm) so they don't overlap the explosion
			try
			{
				for (snd in FlxG.sound.list.members)
				{
					if (snd != null && snd != FlxG.sound.music)
					{
						try
						{
							snd.stop();
						}
						catch (e:Dynamic) {}
					}
				}
			}
			catch (e:Dynamic)
			{
				trace('[SFX] Error while stopping sounds: ' + Std.string(e));
			}

			if (shipExplosionSprite != null)
			{
				shipExplosionSprite.visible = true;
				// Prevent the player from moving while the explosion and subsequent
				// dialogue sequence runs. Freeze immediately and zero velocity so
				// the player cannot move or slide during the explosion.
				if (player != null)
				{
					player.moves = false;
					player.velocity.set(0, 0);
					playerFrozen = true;
				}
				shipExplosionSprite.animation.play("explode");

				trace('[SFX] Global volume=' + Std.string(FlxG.sound.volume) + ' defaultGroup=' + Std.string(FlxG.sound.defaultSoundGroup.volume)
					+ ' muted=' + Std.string(FlxG.sound.muted));
				var prevMaster = FlxG.sound.volume;
				var prevGroup = FlxG.sound.defaultSoundGroup.volume;
				var wasMuted = FlxG.sound.muted;
				if (wasMuted)
					FlxG.sound.muted = false;
				if (FlxG.sound.volume < 0.6)
					FlxG.sound.volume = 0.8;
				if (FlxG.sound.defaultSoundGroup.volume < 0.6)
					FlxG.sound.defaultSoundGroup.volume = 0.8;
				try
				{
					var s = FlxG.sound.play("assets/sounds/sfx.explosion.2.wav", 1.0);
					if (s != null)
					{
						trace('[SFX] FlxG.sound.play returned sound object, vol=' + Std.string(s.volume));
					}
					else
					{
						trace('[SFX] FlxG.sound.play returned null, attempting fallback load');
						var explosionSound:flixel.sound.FlxSound = new flixel.sound.FlxSound();
						explosionSound.loadStream("assets/sounds/sfx.explosion.2.wav", false);
						explosionSound.volume = 1.0;
						explosionSound.autoDestroy = true;
						FlxG.sound.list.add(explosionSound);
						explosionSound.play(false);
						trace('[SFX] fallback explosionSound.play called, vol=' + Std.string(explosionSound.volume));
					}
				}
				catch (e:Dynamic)
				{
					trace('[SFX] Exception while attempting to play explosion SFX: ' + Std.string(e));
				}

				haxe.Timer.delay(function()
				{
					FlxG.sound.volume = prevMaster;
					FlxG.sound.defaultSoundGroup.volume = prevGroup;
					FlxG.sound.muted = wasMuted;
					trace('[SFX] Restored global sound volume and mute state');
				}, 1000);

				var cur = MusicManager.getCurrent();
				if (cur != null)
				{
					trace('[MUSIC] Fading music to silence over 3s (target=0.0)');
					MusicManager.fadeToVolume(cur, 0.0, 3.0);
				}

				shipExplosionSprite.animation.onFinish.add(function(name:String)
				{
					trace("Ship explosion animation finished!");
					// ensure the black overlay is on top so the fade is visible
					try
					{
						if (blackOverlay != null)
						{
							remove(blackOverlay);
							add(blackOverlay);
							blackOverlay.alpha = 0.0;
							blackOverlay.visible = true;
						}
					}
					catch (e:Dynamic)
					{
						trace('[UI] Failed to re-add blackOverlay: ' + Std.string(e));
					}
					FlxTween.tween(blackOverlay, {alpha: 1.0}, 1.0, (({
						onComplete: function():Void
						{
							trace("Overlay faded to black, performing reset activities...");

							// Now that the screen is fully black, hide the explosion sprite
							// so it does not show through. Also freeze the player during
							// the reset and subsequent fade back in.
							try
							{
								if (shipExplosionSprite != null)
								{
									shipExplosionSprite.visible = false;
									shipExplosionSprite.animation.stop();
									shipExplosionSprite.animation.frameIndex = 0;
								}
							}
							catch (e:Dynamic)
							{
								trace('[UI] Error hiding explosion sprite: ' + Std.string(e));
							}
							playerFrozen = true;

							if (noteInventory != null)
							{
								noteInventory.reset();
							}
							if (notesLayer != null)
							{
								remove(notesLayer);
								notesLayer.destroy();
							}
							notesLayer = new NotesLayer();
							add(notesLayer);

							if (gameplayManager != null)
							{
								var letterPuzzles = gameplayManager.getLetterPuzzles();
								if (letterPuzzles != null && letterPuzzles.length > 0)
								{
									var availableNotes = [];
									for (puzzle in letterPuzzles)
									{
										if (!noteInventory.hasNote(puzzle.data))
										{
											availableNotes.push(puzzle);
										}
									}
									if (availableNotes.length > 0)
									{
										notesLayer.loadNotes(availableNotes);
									}
								}
							}

							if (player != null)
							{
								// If the current map didn't contain an explicit
								// player-spawn point, try to fall back to a
								// room-swap target that points back to the main
								// room (common for multi-room ship maps). If we
								// still don't have coordinates, leave the player
								// at the parsed spawnX/spawnY.
								if (!spawnFound)
								{
									// Try to find a roomSwap that points to the
									// 'ship-main' room and use its target as the spawn
									for (rs in roomSwapDataArr)
									{
										if (rs != null && rs.roomFilename != null && rs.roomFilename.indexOf("ship-main") >= 0)
										{
											spawnX = rs.targetX;
											spawnY = rs.targetY;
											trace("Fallback spawn from roomSwap -> (" + spawnX + ", " + spawnY + ") using roomFilename=" + rs.roomFilename);
											break;
										}
									}
									// If still not found, try loading ship-main.tmx directly and
									// read its player-spawn metadata.
									if (!spawnFound)
									{
										try
										{
											var mainMap = TmxSimple.load("assets/maps/ship-main.tmx", "assets/sprites/CC_shipSheet_001.png");
											if (mainMap.objectGroups.exists("Metadata"))
											{
												var md = mainMap.objectGroups.get("Metadata");
												for (mobj in md)
												{
													if (mobj.name == "player-spawn")
													{
														spawnX = mobj.x;
														spawnY = mobj.y;
														trace("Fallback spawn loaded from ship-main.tmx -> (" + spawnX + ", " + spawnY + ")");
														break;
													}
												}
											}
										}
										catch (e:Dynamic)
										{
											trace('[SPAWN] Error reading ship-main.tmx fallback: ' + Std.string(e));
										}
									}
								}

								player.x = spawnX;
								player.y = spawnY;
								// Also update cameraTarget to follow player's center immediately
								try
								{
									if (cameraTarget != null)
									{
										cameraTarget.x = player.x + player.width / 2;
										cameraTarget.y = player.y + player.height / 2 - cameraYOffset;
									}
								}
								catch (e:Dynamic) {}
							}

							FlxTween.tween(blackOverlay, {alpha: 0.0}, 1.0, (({
								onComplete: function():Void
								{
									trace("Fade back in complete; restarting music if available");
									var musicId = MusicManager.getCurrent();
									if (musicId != null)
									{
										MusicManager.play(musicId);
									}

									// restart evacuation timer sequence so the round resumes
									try
									{
										if (gameplayManager != null)
										{
											gameplayManager.restartEvacuationSequence();
										}
										// Listen for the evacuation dialogue complete event and re-enable
										// player movement when it finishes.
										try
										{
											eventManager.on("evacuation_dialogue_complete", _ ->
											{
												if (player != null)
													player.moves = true;
											});
										}
										catch (e:Dynamic) {}
										// hide the black overlay again to restore normal rendering order
										if (blackOverlay != null)
										{
											blackOverlay.visible = false;
											blackOverlay.alpha = 0;
										}
									}
									catch (e:Dynamic)
									{
										trace('[UI] Error restarting evacuation sequence: ' + Std.string(e));
									}
								}
							}) : Dynamic));
						}
					}) : Dynamic));
				});
			}
		});
	}

	private function showDialogue(speaker:String, text:String):Void
	{
		isDialogueActive = true;
		dialogBox.show(speaker, text, () ->
		{
			isDialogueActive = false;
		});
	}

	override public function update(elapsed:Float):Void
	{
		ModHooks.run(ModHookEvents.GAMESTATE_UPDATE_PRE, new ModHookContext(this, {elapsed: elapsed}));

		if (dialogCooldown > 0)
		{
			dialogCooldown -= elapsed;
		}

		#if !android
		if (FlxG.keys.justPressed.H)
		{
			toggleHitboxVisibility();
			trace("Debug hitboxes: " + (debugHitboxes ? "ON" : "OFF"));
		}

		if (FlxG.keys.justPressed.ESCAPE && !dialogBox.isActive && !gameplayManager.isPauseBlocked())
		{
			pauseMenu.toggle();
		}
		#end

		if (pauseMenu.isPauseActive())
		{
			pauseMenu.update(elapsed);
			super.update(elapsed);
			ModHooks.run(ModHookEvents.GAMESTATE_UPDATE_POST, new ModHookContext(this, {elapsed: elapsed, paused: true}));
			return;
		}

		gameplayManager.update(elapsed);
		super.update(elapsed);

		var speed = 200;
		var moveX = 0.0;
		var moveY = 0.0;

		#if !android
		if (!gameplayManager.isDialogueActive() && !dialogBox.isActive && !playerFrozen)
		{
			if (FlxG.keys.pressed.X)
			{
				speed = 250;
			}
			else
			{
				speed = 150;
			}

			var pressLeft = isKeyPressed(controlBindings.moveLeft);
			var pressRight = isKeyPressed(controlBindings.moveRight);
			var pressUp = isKeyPressed(controlBindings.moveUp);
			var pressDown = isKeyPressed(controlBindings.moveDown);

			if (pressLeft && !pressRight)
			{
				moveX = -speed * elapsed;
			}
			else if (pressRight && !pressLeft)
			{
				moveX = speed * elapsed;
			}

			if (pressUp && !pressDown)
			{
				moveY = -speed * elapsed;
			}
			else if (pressDown && !pressUp)
			{
				moveY = speed * elapsed;
			}
		}
		#end

		// If the player is frozen (explosion in progress), ensure movement is disabled
		if (player != null && playerFrozen)
		{
			player.moves = false;
		}

		var hasMovementInput = isKeyPressed(controlBindings.moveLeft)
			|| isKeyPressed(controlBindings.moveRight)
			|| isKeyPressed(controlBindings.moveUp)
			|| isKeyPressed(controlBindings.moveDown);
		if (hasMovementInput)
		{
			idleTime = 0.0;
			hasShownIdleMessage = false;
		}
		else if (!gameplayManager.isDialogueActive() && !dialogBox.isActive)
		{
			idleTime += elapsed;
			if (idleTime >= idleThreshold && !hasShownIdleMessage)
			{
				hasShownIdleMessage = true;
				showMovementTutorial();
			}
		}

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

		if (notesLayer != null)
		{
			checkNoteCollision();
		}

		if (boundingBox != null)
		{
			checkBoundingBoxCollision();
		}

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
						{
							collectNote(noteData);
						}
						break;
					}
				}
				break;
			}
		}
	}

	private function collectNote(noteData:String):Void
	{
		if (noteInventory.addNote(noteData))
		{
			var blipNum = FlxG.random.int(1, 5);
			FlxG.sound.play("assets/sounds/sfx.blip." + blipNum + ".wav", 0.7);

			notesLayer.collectNote(noteData);

			var count = noteInventory.getCount();
			var template = Main.tongue.get("$NOTE_COLLECTED", "dialog");
			var dialogueText:String = untyped (template);

			if (dialogueText.indexOf("{count}") >= 0)
			{
				dialogueText = StringTools.replace(dialogueText, "{count}", Std.string(count));
			}

			showDialogue("SYSTEM", dialogueText);
		}
		touchingNoteData = "";
	}

	private function checkBoundingBoxCollision():Void
	{
		touchingBoundingBox = false;

		if (boundingBox == null)
		{
			return;
		}

		if (player.overlaps(boundingBox))
		{
			if (!FlxG.keys.pressed.ENTER)
			{
				enterPressedInBoundingBox = false;
			}

			if (!noteInventory.isFull())
			{
				if (FlxG.keys.justPressed.ENTER && !enterPressedInBoundingBox && !isDialogueActive && !dialogBox.isActive && dialogCooldown <= 0)
				{
					enterPressedInBoundingBox = true;
					var blipNum = FlxG.random.int(1, 5);
					FlxG.sound.play("assets/sounds/sfx.blip." + blipNum + ".wav", 0.7);
					var dialogueText = Main.tongue.get("$COLLECT_ALL_NOTES", "dialog");
					showDialogue("SYSTEM", dialogueText);
					dialogCooldown = 0.5;
				}
				return;
			}

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
					{
						MusicManager.fadeToVolume(currentMusic, 0.05, fadeDuration);
					}
				}
				dialogCooldown = 0.5;
			}
		}
		else
		{
			enterPressedInBoundingBox = false;
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
		if (boundingBox != null)
		{
			boundingBox.visible = debugHitboxes;
		}
	}

	override public function destroy():Void
	{
		var payload = {
			player: player,
			gameplayManager: gameplayManager,
			pauseMenu: pauseMenu,
			dialogBox: dialogBox
		};
		ModHooks.run(ModHookEvents.GAMESTATE_DESTROY_PRE, new ModHookContext(this, payload));
		MusicManager.stop("geton");
		super.destroy();
		ModHooks.run(ModHookEvents.GAMESTATE_DESTROY_POST, new ModHookContext(this, payload));
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
		{
			dialogBox.show("System", tutorialMessage, null);
		}
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
	private function loadBoundingBox(objectGroups:Map<String, Array<Dynamic>>):Void
	{
		if (boundingBox != null)
		{
			remove(boundingBox);
			boundingBox.destroy();
			boundingBox = null;
		}

		touchingBoundingBox = false;

		if (objectGroups.exists("Interactions"))
		{
			var interactions = objectGroups.get("Interactions");
			for (obj in interactions)
			{
				if (obj.name == "bounding-box")
				{
					boundingBox = new FlxSprite(obj.x, obj.y);
					boundingBox.makeGraphic(Std.int(obj.width), Std.int(obj.height), 0x80FF00FF);
					boundingBox.immovable = true;
					boundingBox.moves = false;
					boundingBox.visible = debugHitboxes;
					boundingBox.setSize(Std.int(obj.width), Std.int(obj.height));
					boundingBox.updateHitbox();

					add(boundingBox);
					break;
				}
			}
		}
	}

	private function isKeyPressed(keyName:String):Bool
	{
		if (keyName == null)
			return false;

		return switch (keyName.toUpperCase())
		{
			case "LEFT": FlxG.keys.pressed.LEFT;
			case "RIGHT": FlxG.keys.pressed.RIGHT;
			case "UP": FlxG.keys.pressed.UP;
			case "DOWN": FlxG.keys.pressed.DOWN;
			case "X": FlxG.keys.pressed.X;
			case "ENTER": FlxG.keys.pressed.ENTER;
			case "SPACE": FlxG.keys.pressed.SPACE;
			case "ESCAPE": FlxG.keys.pressed.ESCAPE;
			case "P": FlxG.keys.pressed.P;
			case "BACKSPACE": FlxG.keys.pressed.BACKSPACE;
			case "TAB": FlxG.keys.pressed.TAB;
			case "SHIFT": FlxG.keys.pressed.SHIFT;
			case "ALT": FlxG.keys.pressed.ALT;
			case "1": FlxG.keys.pressed.ONE;
			case "2": FlxG.keys.pressed.TWO;
			case "3": FlxG.keys.pressed.THREE;
			case "4": FlxG.keys.pressed.FOUR;
			case "5": FlxG.keys.pressed.FIVE;
			case "6": FlxG.keys.pressed.SIX;
			case "7": FlxG.keys.pressed.SEVEN;
			case "8": FlxG.keys.pressed.EIGHT;
			case "9": FlxG.keys.pressed.NINE;
			case "0": FlxG.keys.pressed.ZERO;
			case "A": FlxG.keys.pressed.A;
			case "B": FlxG.keys.pressed.B;
			case "C": FlxG.keys.pressed.C;
			case "D": FlxG.keys.pressed.D;
			case "E": FlxG.keys.pressed.E;
			case "F": FlxG.keys.pressed.F;
			case "G": FlxG.keys.pressed.G;
			case "H": FlxG.keys.pressed.H;
			case "I": FlxG.keys.pressed.I;
			case "J": FlxG.keys.pressed.J;
			case "K": FlxG.keys.pressed.K;
			case "L": FlxG.keys.pressed.L;
			case "M": FlxG.keys.pressed.M;
			case "N": FlxG.keys.pressed.N;
			case "O": FlxG.keys.pressed.O;
			case "Q": FlxG.keys.pressed.Q;
			case "R": FlxG.keys.pressed.R;
			case "S": FlxG.keys.pressed.S;
			case "T": FlxG.keys.pressed.T;
			case "U": FlxG.keys.pressed.U;
			case "V": FlxG.keys.pressed.V;
			case "W": FlxG.keys.pressed.W;
			case "Y": FlxG.keys.pressed.Y;
			case "Z": FlxG.keys.pressed.Z;
			case "F1": FlxG.keys.pressed.F1;
			case "F2": FlxG.keys.pressed.F2;
			case "F3": FlxG.keys.pressed.F3;
			case "F4": FlxG.keys.pressed.F4;
			case "F5": FlxG.keys.pressed.F5;
			case "F6": FlxG.keys.pressed.F6;
			case "F7": FlxG.keys.pressed.F7;
			case "F8": FlxG.keys.pressed.F8;
			case "F9": FlxG.keys.pressed.F9;
			case "F10": FlxG.keys.pressed.F10;
			case "F11": FlxG.keys.pressed.F11;
			case "F12": FlxG.keys.pressed.F12;
			case ",": FlxG.keys.pressed.COMMA;
			case ".": FlxG.keys.pressed.PERIOD;
			case ";": FlxG.keys.pressed.SEMICOLON;
			case "'": FlxG.keys.pressed.QUOTE;
			case "[": FlxG.keys.pressed.LBRACKET;
			case "]": FlxG.keys.pressed.RBRACKET;
			case "\\": FlxG.keys.pressed.BACKSLASH;
			case "/": FlxG.keys.pressed.SLASH;
			case "-": FlxG.keys.pressed.MINUS;
			case _: false;
		};
	}
	private function createShipExplosionSprite():FlxSprite
	{
		try
		{
			var aseBytes = openfl.Assets.getBytes("assets/animsprites/CC_shipExplosion_001.ase");
			var aseData = Ase.fromBytes(aseBytes);

			trace("ASE file loaded: " + aseData.width + "x" + aseData.height + ", " + aseData.frames.length + " frames");

			var sprite = new FlxSprite(0, 0);
			var frameArray:Array<Int> = [];

			var sheetWidth = aseData.width * aseData.frames.length;
			var sheetHeight = aseData.height;
			var sheet = new BitmapData(sheetWidth, sheetHeight, true, 0x00000000);

			for (frameIndex in 0...aseData.frames.length)
			{
				var frame = aseData.frames[frameIndex];
				var frameBitmap = new BitmapData(aseData.width, aseData.height, true, 0x00000000);

				for (layerIndex in 0...aseData.layers.length)
				{
					var layer = aseData.layers[layerIndex];
					if (!layer.visible)
						continue;

					var cel = frame.cel(layerIndex);
					if (cel == null)
						continue;

					var celPixels = cel.pixelData;
					var celX = cel.xPosition;
					var celY = cel.yPosition;

					for (y in 0...cel.height)
					{
						for (x in 0...cel.width)
						{
							var pixelIndex = (y * cel.width + x) * 4;
							if (pixelIndex + 3 < celPixels.length)
							{
								var r = celPixels.get(pixelIndex);
								var g = celPixels.get(pixelIndex + 1);
								var b = celPixels.get(pixelIndex + 2);
								var a = celPixels.get(pixelIndex + 3);

								if (a > 0)
								{
									var color = (a << 24) | (r << 16) | (g << 8) | b;
									var px = celX + x;
									var py = celY + y;
									if (px >= 0 && px < aseData.width && py >= 0 && py < aseData.height)
									{
										frameBitmap.setPixel32(px, py, color);
									}
								}
							}
						}
					}
				}

				var destX = frameIndex * aseData.width;
				sheet.copyPixels(frameBitmap, new openfl.geom.Rectangle(0, 0, aseData.width, aseData.height), new openfl.geom.Point(destX, 0));
				frameArray.push(frameIndex);
			}

			var graphic = FlxGraphic.fromBitmapData(sheet, false, "shipExplosion_sheet");
			sprite.loadGraphic(graphic, true, aseData.width, aseData.height);

			sprite.scale.set(8, 8);
			sprite.updateHitbox();

			sprite.x = (FlxG.width - sprite.width) / 2;
			sprite.y = (FlxG.height - sprite.height) / 2;
			sprite.scrollFactor.set(0, 0);

			sprite.animation.add("explode", frameArray, 8, false);
			sprite.visible = false;

			trace("Ship explosion sprite created successfully!");
			return sprite;
		}
		catch (e:Dynamic)
		{
			trace("Error loading ship explosion: " + e);
			return null;
		}
	}
}
