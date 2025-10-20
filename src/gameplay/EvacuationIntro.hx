package gameplay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import managers.DialogueManager;
import managers.MusicManager;
import ui.NotesLayer;
import ui.dialog.DialogBox;
import utils.GameSaveManager;

class EvacuationIntro
{
	public var isActive:Bool = false;
	public var isComplete:Bool = false;
	public var isDialogueActive:Bool = false;
	
	private var timer:Float = 0.0;
	private var alarmFlashTimer:Float = 0.0;
	private var alarmFlashInterval:Float = 2.5;
	private var dialogueShown:Bool = false;
	private var currentDialogue:Int = 0;
	private var dialogueEnded:Bool = false;
	private var hasPlayedOnce:Bool = false;
	private var musicTransitionStarted:Bool = false;
	private var musicFadeTimer:Float = 0.0;
	private var musicFadeDuration:Float = 0.5;
	
	private var redOverlay:FlxSprite;
	private var dialogBox:DialogBox;
	private var notesLayer:NotesLayer;
	
	private var group:FlxGroup;
	private var dialogueManager:DialogueManager;
	
	private var fullText:String = "";
	private var displayedText:String = "";
	private var typewriterTimer:Float = 0.0;
	private var typewriterSpeed:Float = 0.05;
	private var currentCharIndex:Int = 0;
	private var isTypewriterComplete:Bool = false;
	
	public function new(parent:FlxGroup)
	{
		group = new FlxGroup();
		parent.add(group);
		
		dialogueManager = DialogueManager.getInstance();
		
		redOverlay = new FlxSprite(0, 0);
		redOverlay.makeGraphic(FlxG.width, FlxG.height, 0xFFFF0000);
		redOverlay.alpha = 0;
		redOverlay.scrollFactor.set(0, 0);
		group.add(redOverlay);
		
		dialogBox = new DialogBox();
		group.add(dialogBox);

		isActive = false;
		isComplete = false;
		isDialogueActive = true;
	}
	
	public function setObjectGroups(objectGroups:Map<String, Array<Dynamic>>):Void
	{
		if (objectGroups.exists("Interactions"))
		{
			var interactions = objectGroups.get("Interactions");
			var letterPuzzles:Array<{x:Float, y:Float, data:String}> = [];
			
			for (obj in interactions)
			{
				if (obj.name == "letter-puzzle")
				{
					var data = obj.properties.get("data");
					if (data != null)
					{
						letterPuzzles.push({
							x: obj.x,
							y: obj.y,
							data: data
						});
					}
				}
			}
			
			if (notesLayer != null)
				notesLayer.destroy();
			notesLayer = new NotesLayer();
			notesLayer.loadNotes(letterPuzzles);
			group.add(notesLayer);
		}
	}
	
	public function start():Void
	{
		if (hasPlayedOnce)
			return;

		isActive = true;
		isComplete = false;
		isDialogueActive = true;
		timer = 0.0;
		alarmFlashTimer = 0.0;
		dialogueShown = false;
		currentDialogue = 0;
		dialogueEnded = false;
		isTypewriterComplete = false;
		currentCharIndex = 0;
		musicTransitionStarted = false;
		musicFadeTimer = 0.0;
		redOverlay.visible = true;
	}

	public function reset():Void
	{
		hasPlayedOnce = false;
		isActive = false;
		isComplete = false;
		isDialogueActive = false;
		timer = 0.0;
		alarmFlashTimer = 0.0;
		dialogueShown = false;
		currentDialogue = 0;
		dialogueEnded = false;
		isTypewriterComplete = false;
		currentCharIndex = 0;
		musicTransitionStarted = false;
		musicFadeTimer = 0.0;
		redOverlay.visible = false;
		redOverlay.alpha = 0;
		fullText = "";
		displayedText = "";
		typewriterTimer = 0.0;
		currentCharIndex = 0;
	}
	
	public function update(elapsed:Float):Void
	{
		alarmFlashTimer += elapsed;

		if (alarmFlashTimer >= alarmFlashInterval)
		{
			alarmFlashTimer = 0.0;
			if (!dialogueEnded && isActive)
			{
				FlxG.sound.play("assets/sounds/sfx.alarm.1.wav", 0.6);
			}
			if (redOverlay.visible)
			{
				redOverlay.alpha = 0.6;
			}
		}
		else if (alarmFlashTimer > alarmFlashInterval * 0.4)
		{
			if (redOverlay.visible)
			{
				var newAlpha = 0.6 * (1 - ((alarmFlashTimer - alarmFlashInterval * 0.4) / (alarmFlashInterval * 0.6)));
				redOverlay.alpha = newAlpha;
			}
		}
		
		if (!isActive || hasPlayedOnce)
			return;

		timer += elapsed;

		if (!dialogueShown && !dialogueEnded && timer >= 1.0)
		{
			dialogueShown = true;
			startFirstDialogue();
		}
		
		if (dialogueShown && !isTypewriterComplete)
		{
			isDialogueActive = true;
			updateTypewriter(elapsed);

			if (FlxG.keys.justPressed.ENTER)
			{
				displayedText = fullText;
				currentCharIndex = fullText.length;
				isTypewriterComplete = true;
			}
		}
		else if (dialogueShown && isTypewriterComplete)
		{
			isDialogueActive = true;
			if (FlxG.keys.justPressed.ENTER)
			{
				advanceDialogue();
			}
		}
	}
	
	private function updateTypewriter(elapsed:Float):Void
	{
		if (isTypewriterComplete) return;
		
		typewriterTimer += elapsed;
		
		while (typewriterTimer >= typewriterSpeed && currentCharIndex < fullText.length)
		{
			typewriterTimer -= typewriterSpeed;
			displayedText += fullText.charAt(currentCharIndex);
			currentCharIndex++;
		}
		
		dialogBox.setDialogue(displayedText);
		
		if (currentCharIndex >= fullText.length)
		{
			isTypewriterComplete = true;
			if (currentDialogue < 2)
				dialogBox.showSkipHint(true);
		}
	}
	
	private function startFirstDialogue():Void
	{
		currentDialogue = 0;
		fullText = "EVERYONE EVACUATE THE SHIP";
		displayedText = "";
		currentCharIndex = 0;
		typewriterTimer = 0.0;
		isTypewriterComplete = false;
		dialogBox.show();
		dialogBox.showSkipHint(false);
	}
	
	private function advanceDialogue():Void
	{
		currentDialogue++;
		
		if (currentDialogue == 1)
		{
			var playerName:String = GameSaveManager.currentData != null ? GameSaveManager.currentData.username : "Nova";
			fullText = playerName + ", please gather all the notes around the\nship to get the code to escape. You have 10 minutes.";
			displayedText = "";
			currentCharIndex = 0;
			typewriterTimer = 0.0;
			isTypewriterComplete = false;
			dialogBox.showSkipHint(false);
		}
		else
		{
			dialogueShown = false;
			dialogueEnded = true;
			dialogBox.hide();
			isDialogueActive = false;
			isActive = false;
			isComplete = true;
			hasPlayedOnce = true;
			MusicManager.play("geton");
		}
	}
	
	public function destroy():Void
	{
		if (redOverlay != null) redOverlay.destroy();
		if (dialogBox != null)
			dialogBox.destroy();
		if (notesLayer != null)
			notesLayer.destroy();
		if (group != null) group.destroy();
	}
}
