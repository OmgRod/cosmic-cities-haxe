package gameplay;

import flixel.FlxG;
import flixel.group.FlxGroup;
import gameplay.EvacuationIntro;

class GameplayManager
{
	private static var instance:GameplayManager;
	
	private var group:FlxGroup;
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
		group = new FlxGroup();
	}
	
	public function init(parent:FlxGroup):Void
	{
		if (group != null)
		{
			parent.remove(group);
		}
		
		group = new FlxGroup();
		parent.add(group);
		
		evacuationIntro = new EvacuationIntro(group);
		
		currentSequence = "";
		isSequencePlaying = false;
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
		if (evacuationIntro != null && evacuationIntro.isActive)
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
	
	public function getCurrentSequence():String
	{
		return currentSequence;
	}
	
	public function destroy():Void
	{
		if (evacuationIntro != null)
		{
			evacuationIntro.destroy();
		}
		if (group != null)
		{
			group.destroy();
		}
	}
}
