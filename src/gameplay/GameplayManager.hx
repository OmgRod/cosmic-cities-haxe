package gameplay;

import flixel.FlxG;
import flixel.group.FlxGroup;
import gameplay.EvacuationIntro;

class GameplayManager
{
	private static var instance:GameplayManager;

	private var evacuationIntro:EvacuationIntro;
	
	private var currentSequence:String = "";
	private var isSequencePlaying:Bool = false;
	
	public static function getInstance():GameplayManager
	{
		if (instance == null)
		{
			instance = new GameplayManager();
		}
		return instance;
	}
	
	public function new()
	{
	}
	
	public function initParsing():Void
	{
		if (evacuationIntro != null)
		{
			evacuationIntro.destroy();
		}
		
		evacuationIntro = new EvacuationIntro();
		
		currentSequence = "";
		isSequencePlaying = false;
	}

	public function init(parent:FlxGroup):Void
	{
		if (evacuationIntro == null)
		{
			evacuationIntro = new EvacuationIntro();
		}
		
		parent.add(evacuationIntro.getChapterOverlay());
		parent.add(evacuationIntro.getChapterText());

		parent.add(evacuationIntro.getRedOverlay());
		parent.add(evacuationIntro.getDialogBox());
		parent.add(evacuationIntro.getTimerBackground());
		parent.add(evacuationIntro.getTimerDisplay());
		
		currentSequence = "";
		isSequencePlaying = false;
	}
	
	public function setMapObjectGroups(objectGroups:Map<String, Array<Dynamic>>):Void
	{
		if (evacuationIntro != null)
		{
			evacuationIntro.setObjectGroups(objectGroups);
		}
	}
	
	public function startEvacuationSequence():Void
	{
		if (evacuationIntro != null)
		{
			currentSequence = "evacuation";
			isSequencePlaying = true;
			evacuationIntro.start();
		}
	}
	
	public function update(elapsed:Float):Void
	{
		if (evacuationIntro != null)
		{
			evacuationIntro.update(elapsed);
			
			if (evacuationIntro.isComplete)
			{
				isSequencePlaying = false;
				currentSequence = "";
			}
		}
	}
	
	public function isPlaying():Bool
	{
		return isSequencePlaying;
	}
	
	public function isDialogueActive():Bool
	{
		if (evacuationIntro != null)
		{
			return evacuationIntro.isDialogueActive;
		}
		return false;
	}

	public function isPauseBlocked():Bool
	{
		if (evacuationIntro != null)
		{
			return evacuationIntro.isPauseBlocked();
		}
		return false;
	}
	
	public function getCurrentSequence():String
	{
		return currentSequence;
	}
	
	public function getLetterPuzzles():Array<{x:Float, y:Float, data:String}>
	{
		if (evacuationIntro != null)
		{
			return evacuationIntro.getLetterPuzzles();
		}
		return [];
	}

	public function getEvacuationTimerDisplay():flixel.text.FlxBitmapText
	{
		if (evacuationIntro != null)
		{
			return evacuationIntro.getTimerDisplay();
		}
		return null;
	}

	public function bringToFront(parent:FlxGroup):Void
	{
		if (evacuationIntro != null)
		{
			parent.remove(evacuationIntro.getRedOverlay());
			parent.remove(evacuationIntro.getDialogBox());
			parent.add(evacuationIntro.getRedOverlay());
			parent.add(evacuationIntro.getDialogBox());
		}
	}
	
	public function destroy():Void
	{
		if (evacuationIntro != null)
		{
			evacuationIntro.destroy();
		}
	}
	public function restartEvacuationSequence():Void
	{
		if (evacuationIntro != null)
		{
			evacuationIntro.reset();
			evacuationIntro.startAtDialogue();
			currentSequence = "evacuation";
			isSequencePlaying = true;
		}
	}
}
