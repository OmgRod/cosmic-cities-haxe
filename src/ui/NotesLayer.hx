package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class NotesLayer extends FlxGroup
{
	private var noteSpriteMap:Map<String, FlxSprite> = new Map();
	
	public function new()
	{
		super();
	}
	
	public function loadNotes(letterPuzzles:Array<{x:Float, y:Float, data:String}>):Void
	{
		clear();
		noteSpriteMap.clear();
		
		for (puzzle in letterPuzzles)
		{
			var spritePath = 'assets/sprites/notes/${puzzle.data}.png';
			
			try
			{
				var noteSprite = new FlxSprite(puzzle.x, puzzle.y);
				noteSprite.loadGraphic(spritePath);
				noteSprite.scrollFactor.set(1, 1);
				add(noteSprite);
				noteSpriteMap.set(puzzle.data, noteSprite);
				
				trace("Loaded note: " + puzzle.data + " at (" + puzzle.x + ", " + puzzle.y + ")");
			}
			catch (e:Dynamic)
			{
				trace("Error loading note sprite: " + spritePath + " - " + e);
			}
		}
	}
	
	public function getNoteByData(data:String):Null<FlxSprite>
	{
		return noteSpriteMap.get(data);
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
		super.destroy();
	}
}
