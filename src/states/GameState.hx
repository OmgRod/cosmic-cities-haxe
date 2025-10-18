package states;

// import data.ExampleDialogue;
// import data.ExampleInteractables;
import entities.Player;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import manager.MusicManager;
import managers.DialogueManager;
import managers.EventManager;
import managers.GameManager;
import managers.InteractionManager;
import managers.StoryManager;
import ui.backgrounds.Starfield;
import ui.menu.ProgressBar;
import utils.GameSaveManager;
import utils.TmxSimple;



class GameState extends FlxState
{
	var gameManager:GameManager;
	var eventManager:EventManager;
	var storyManager:StoryManager;
	var dialogueManager:DialogueManager;
	var interactionManager:InteractionManager;

	var mapGroup:FlxGroup;
	var player:Player;
	var mapWidth:Int = 0;
	var mapHeight:Int = 0;
	var collisionGroup:FlxGroup;
	var mapOffsetX:Float = 0;
	var mapOffsetY:Float = 0;
	var cameraTarget:FlxSprite;
	var cameraYOffset:Float = 8; 

	override public function create()
    {
        super.create();

        var starfield = new Starfield();
        add(starfield);

		var progressBar = new ProgressBar((FlxG.width / 2) - (460 / 2), 32, 460);
		add(progressBar);

		MusicManager.stop("intro");

		gameManager = GameManager.getInstance();
		eventManager = EventManager.getInstance();
		storyManager = StoryManager.getInstance();
		dialogueManager = DialogueManager.getInstance();
		interactionManager = InteractionManager.getInstance();

		// dialogueManager.registerDialogue(ExampleDialogue.getTutorialTree());
		// dialogueManager.registerDialogue(ExampleDialogue.getShipCaptainTree());
		// dialogueManager.registerDialogue(ExampleDialogue.getCrewMemberTree());

		// ExampleInteractables.setupInteractions(interactionManager);

		setupEventListeners();

		var username = (GameSaveManager.currentData != null) ? GameSaveManager.currentData.username : "Player";
		gameManager.startNewGame(username);

		storyManager.setChapter("chapter_1");
		storyManager.setScene("ship_intro");

		dialogueManager.startDialogue("tutorial");

		var result = TmxSimple.load("assets/maps/ship-main.tmx", "assets/sprites/CC_shipSheet_001.png");

		mapGroup = new FlxGroup();
		for (layer in result.layers)
		{
			layer.immovable = true;
			mapGroup.add(layer);
		}
		add(mapGroup);

		mapWidth = result.pixelWidth;
		mapHeight = result.pixelHeight;

		collisionGroup = new FlxGroup();
		for (hb in result.hitboxes)
		{
			var box = new FlxSprite(hb.x, hb.y);

			box.makeGraphic(Std.int(hb.width), Std.int(hb.height), 0x00000000);
			box.immovable = true;
			box.moves = false;
			box.visible = false;
			collisionGroup.add(box);
		}
		add(collisionGroup);

		var spawnTileX = Std.int(result.mapWidth / 2);
		var spawnTileY = Std.int(result.mapHeight / 2);
		var spawnPxX = spawnTileX * result.tileWidth;
		var spawnPxY = spawnTileY * result.tileHeight;

		player = new Player(spawnPxX, spawnPxY);
		add(player);

		cameraTarget = new FlxSprite(player.x, player.y);
		cameraTarget.makeGraphic(1, 1, 0x00000000);
		cameraTarget.visible = false;

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
		var moveSpeed = 180;
		player.velocity.set(0, 0);
		if (FlxG.keys.pressed.LEFT)
			player.velocity.x = -moveSpeed;
		if (FlxG.keys.pressed.RIGHT)
			player.velocity.x = moveSpeed;
		if (FlxG.keys.pressed.UP)
			player.velocity.y = -moveSpeed;
		if (FlxG.keys.pressed.DOWN)
			player.velocity.y = moveSpeed;

		super.update(elapsed);

		FlxG.collide(player, collisionGroup);

		if (cameraTarget != null && player != null)
		{
			cameraTarget.x = player.x;
			cameraTarget.y = player.y + cameraYOffset;
		}
		if (FlxG.keys.justPressed.E)
		{
			for (obj in interactionManager.getInteractableObjects())
			{
				interactionManager.interact(obj.id);
				break;
			}
		}

		if (dialogueManager.isActive() && FlxG.keys.justPressed.SPACE)
		{
			dialogueManager.advance(null);
		}
	}

	override public function destroy():Void
	{
		super.destroy();
    }
}
