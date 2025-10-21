package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxDirectionFlags;

class NotesLayer extends FlxGroup
{
	private var noteSpriteMap:Map<String, FlxSprite> = new Map();
	public var noteBoundsMap:Map<String, FlxSprite> = new Map();
	
	public function new()
	{
		super();
	}
	
	public function loadNotes(letterPuzzles:Array<{x:Float, y:Float, data:String}>):Void
	{
		clear();
		noteSpriteMap.clear();
		noteBoundsMap.clear();

		trace("===== NotesLayer.loadNotes called =====");
		trace("Number of puzzles to load: " + letterPuzzles.length);
		
		for (puzzle in letterPuzzles)
		{
			trace("  Loading puzzle: " + puzzle.data + " at (" + puzzle.x + ", " + puzzle.y + ")");
			try
			{
				var noteSprite = new FlxSprite(puzzle.x, puzzle.y);
				var graphicPath = "assets/sprites/notes/" + puzzle.data + ".png";
				trace("    Loading graphic from: " + graphicPath);
				noteSprite.loadGraphic(graphicPath);
				noteSprite.scrollFactor.set(1, 1);
				noteSprite.immovable = true;

				add(noteSprite);
				noteSpriteMap.set(puzzle.data, noteSprite);
				
				var bounds = new FlxSprite(puzzle.x, puzzle.y);
				bounds.makeGraphic(Std.int(noteSprite.width), Std.int(noteSprite.height), 0x00000000);
				bounds.scrollFactor.set(1, 1);
				bounds.immovable = true;
				bounds.allowCollisions = FlxDirectionFlags.ANY;

				add(bounds);
				noteBoundsMap.set(puzzle.data, bounds);

				trace("    Successfully loaded " + puzzle.data + " with bounds " + Std.int(bounds.width) + "x" + Std.int(bounds.height));
			}
			catch (e:Dynamic)
			{
				trace("    ERROR loading note sprite: " + puzzle.data + " - " + e);
			}
		}
		trace("===== NotesLayer.loadNotes complete =====");
	}
	
	public function getNoteByData(data:String):Null<FlxSprite>
	{
		return noteSpriteMap.get(data);
	}
	
	public function getNoteSprites():Array<FlxSprite>
	{
		return [for (sprite in noteSpriteMap) sprite];
	}

	public function getNoteBounds():Array<FlxSprite>
	{
		return [for (sprite in noteBoundsMap) sprite];
	}

	public function getNoteBoundsMap():Map<String, FlxSprite>
	{
		return noteBoundsMap;
	}

	public function collectNote(data:String):Bool
	{
		var sprite = noteSpriteMap.get(data);
		var bounds = noteBoundsMap.get(data);

		if (sprite != null && bounds != null)
		{
			remove(sprite);
			remove(bounds);
			sprite.destroy();
			bounds.destroy();
			noteSpriteMap.remove(data);
			noteBoundsMap.remove(data);
			return true;
		}
		return false;
	}
	
	public function hideNote(data:String):Void
	{
		var sprite = noteSpriteMap.get(data);
		if (sprite != null)
		{
			sprite.visible = false;
		}
	}
	
	public function showNote(data:String):Void
	{
		var sprite = noteSpriteMap.get(data);
		if (sprite != null)
		{
			sprite.visible = true;
		}
	}
	
	override public function destroy():Void
	{
		clear();
		noteSpriteMap.clear();
		noteBoundsMap.clear();
		super.destroy();
	}
}
