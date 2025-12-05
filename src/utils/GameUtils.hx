package utils;

import ase.Ase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.util.FlxDirectionFlags;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import utils.TmxSimple;

/**
 * Utility functions for game logic: collision detection, key input mapping,
 * ASE sprite creation, and map loading helpers.
 */
class GameUtils
{
	/**
	 * Check if a rectangle collides with any hitbox in the provided array.
	 */
	public static function checkCollision(testX:Float, testY:Float, testWidth:Float, testHeight:Float, hitboxes:Array<{x:Float, y:Float, width:Float, height:Float}>):Bool
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

	/**
	 * Test if two axis-aligned rectangles overlap.
	 */
	public static inline function rectsOverlap(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Bool
	{
		return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
	}

	/**
	 * Convert a key name string to a boolean indicating if it's currently pressed.
	 */
	public static function isKeyPressed(keyName:String):Bool
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

	/**
	 * Create a FlxSprite from an ASE (Aseprite) file.
	 * Returns a sprite with animation frames loaded.
	 */
	public static function createShipExplosionSprite():FlxSprite
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

	/**
	 * Load a TMX map and create collision walls and room swaps from it.
	 * Returns a structure containing the loaded data.
	 */
	public static function loadMapData(tmxPath:String, tilesetPath:String):Null<{
		mapGroup:FlxGroup,
		walls:Array<FlxSprite>,
		wallsGroup:FlxGroup,
		hitboxes:Array<{x:Float, y:Float, width:Float, height:Float}>,
		roomSwaps:Array<{sprite:FlxSprite, data:Dynamic}>,
		roomSwapGroup:FlxGroup,
		mapWidth:Int,
		mapHeight:Int,
		spawnPoint:{x:Float, y:Float, found:Bool},
		boundingBoxes:Array<FlxSprite>
	}>
	{
		var result = TmxSimple.load(tmxPath, tilesetPath);
		var mapGroup = new FlxGroup();
		var walls:Array<FlxSprite> = [];
		var wallsGroup = new FlxGroup();
		var hitboxes:Array<{x:Float, y:Float, width:Float, height:Float}> = [];
		var roomSwapGroup = new FlxGroup();
		var roomSwaps:Array<{sprite:FlxSprite, data:Dynamic}> = [];
		var boundingBoxes:Array<FlxSprite> = [];

		// Create map group from tileset layers
		for (layer in result.layers)
		{
			layer.immovable = true;
			mapGroup.add(layer);
		}

		var mapWidth = result.pixelWidth;
		var mapHeight = result.pixelHeight;

		// Create collision walls from hitboxes
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
			wall.makeGraphic(Std.int(hb.width), Std.int(hb.height), 0x00FFFFFF);
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
		trace("=== CREATED " + walls.length + " WALLS ===");

		// Create room swap (door) triggers
		for (rs in result.roomSwaps)
		{
			var swap = new FlxSprite(rs.x, rs.y);
			swap.makeGraphic(Std.int(rs.width), Std.int(rs.height), 0x800000FF);
			swap.immovable = true;
			swap.moves = false;
			swap.visible = false;
			swap.ID = roomSwapGroup.length;
			swap.setGraphicSize(Std.int(rs.width), Std.int(rs.height));
			swap.updateHitbox();
			roomSwapGroup.add(swap);
			roomSwaps.push({sprite: swap, data: rs});
		}

		// Find player spawn point
		var spawnX = 0.0;
		var spawnY = 0.0;
		var spawnFound = false;

		if (result.objectGroups.exists("Metadata"))
		{
			var metadataObjects = result.objectGroups.get("Metadata");
			for (obj in metadataObjects)
			{
				if (obj.name == "player-spawn")
				{
					spawnX = obj.x;
					spawnY = obj.y;
					spawnFound = true;
					trace("Found player spawn point at (" + spawnX + ", " + spawnY + ")");
					break;
				}
			}
		}

		// If no explicit spawn, use fallback logic
		if (!spawnFound)
		{
			var foundFallback:Bool = false;
			for (rs in result.roomSwaps)
			{
				if (rs == null)
					continue;
				var tx = rs.targetX;
				var ty = rs.targetY;
				if (tx >= 0 && tx <= mapWidth && ty >= 0 && ty <= mapHeight)
				{
					spawnX = tx;
					spawnY = ty;
					foundFallback = true;
					trace("[SPAWN DEBUG] Using roomSwap fallback spawn -> (" + spawnX + ", " + spawnY + ")");
					break;
				}
			}
			if (!foundFallback)
			{
				spawnX = Std.int(mapWidth / 2);
				spawnY = Std.int(mapHeight / 2);
				trace("[SPAWN DEBUG] No spawn found; centering player at (" + spawnX + ", " + spawnY + ")");
			}
		}

		// Load bounding boxes (interactive areas)
		if (result.objectGroups.exists("Interactions"))
		{
			var interactions = result.objectGroups.get("Interactions");
			for (obj in interactions)
			{
				if (obj.name == "bounding-box")
				{
					var bbox = new FlxSprite(obj.x, obj.y);
					bbox.makeGraphic(Std.int(obj.width), Std.int(obj.height), 0x80FF00FF);
					bbox.immovable = true;
					bbox.moves = false;
					bbox.visible = false;
					bbox.setSize(Std.int(obj.width), Std.int(obj.height));
					bbox.updateHitbox();
					boundingBoxes.push(bbox);
				}
			}
		}

		return {
			mapGroup: mapGroup,
			walls: walls,
			wallsGroup: wallsGroup,
			hitboxes: hitboxes,
			roomSwaps: roomSwaps,
			roomSwapGroup: roomSwapGroup,
			mapWidth: mapWidth,
			mapHeight: mapHeight,
			spawnPoint: {x: spawnX, y: spawnY, found: spawnFound},
			boundingBoxes: boundingBoxes
		};
	}
}
