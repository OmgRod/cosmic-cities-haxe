package gameplay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import managers.DialogueManager;
import managers.MusicManager;
import utils.BMFont;
import utils.GameSaveManager;

class EvacuationIntro
{
	public var isActive:Bool = false;
	public var isComplete:Bool = false;
	public var isDialogueActive:Bool = false;
	
	private var timer:Float = 0.0;
	private var alarmFlashTimer:Float = 0.0;
	private var alarmFlashInterval:Float = 0.5;
	private var dialogueShown:Bool = false;
	private var currentDialogue:Int = 0;
	private var musicTransitionStarted:Bool = false;
	private var musicFadeTimer:Float = 0.0;
	private var musicFadeDuration:Float = 0.5;
	
	private var redOverlay:FlxSprite;
	private var dialogBox:FlxSprite;
	private var dialogueText:FlxBitmapText;
	private var speakerText:FlxBitmapText;
	private var skipHintText:FlxBitmapText;
	
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
		
		dialogBox = new FlxSprite(20, FlxG.height - 140);
		dialogBox.makeGraphic(FlxG.width - 40, 120, 0xFF1a1a1a);
		dialogBox.scrollFactor.set(0, 0);
		group.add(dialogBox);
		
		var font = new BMFont("assets/fonts/pixel_operator/pixel_operator.fnt", "assets/fonts/pixel_operator/pixel_operator.png").getFont();
		
		speakerText = new FlxBitmapText(40, FlxG.height - 125, "CAPTAIN RAY:", font);
		speakerText.color = 0xFFFFFF00;
		speakerText.scrollFactor.set(0, 0);
		speakerText.scale.set(0.8, 0.8);
		group.add(speakerText);
		
		dialogueText = new FlxBitmapText(40, FlxG.height - 105, "", font);
		dialogueText.color = 0xFFFFFFFF;
		dialogueText.scrollFactor.set(0, 0);
		dialogueText.scale.set(0.7, 0.7);
		group.add(dialogueText);
		
        skipHintText = new FlxBitmapText(40, FlxG.height - 60, "Press ENTER to continue", font);
        skipHintText.color = 0xFF888888;
        skipHintText.scrollFactor.set(0, 0);
        skipHintText.scale.set(0.6, 0.6);
        skipHintText.visible = false;
        group.add(skipHintText);
		
		isActive = false;
		isComplete = false;
	}
	
	public function start():Void
	{
		isActive = true;
		isComplete = false;
		isDialogueActive = false;
		timer = 0.0;
		alarmFlashTimer = 0.0;
		dialogueShown = false;
		currentDialogue = 0;
		isTypewriterComplete = false;
		currentCharIndex = 0;
		musicTransitionStarted = false;
		musicFadeTimer = 0.0;
	}
	
	public function update(elapsed:Float):Void
	{
		if (!isActive) return;
		
		timer += elapsed;
		alarmFlashTimer += elapsed;
		
		// Red flash effect - always update for visual effect (continues even after music starts)
		if (alarmFlashTimer >= alarmFlashInterval)
		{
			alarmFlashTimer = 0.0;
			// Only play alarm sound if music transition hasn't started
			if (!musicTransitionStarted)
			{
				FlxG.sound.play("assets/sounds/sfx.blip.1.wav", 0.6);
			}
			// Always update visual
			if (redOverlay.visible)
			{
				redOverlay.alpha = 0.6;
			}
		}
		else if (alarmFlashTimer > alarmFlashInterval * 0.4)
		{
			// Fade out the red flash
			if (redOverlay.visible)
			{
				redOverlay.alpha = 0.6 * (1 - ((alarmFlashTimer - alarmFlashInterval * 0.4) / (alarmFlashInterval * 0.6)));
			}
		}
		
		if (!dialogueShown && timer >= 1.0)
		{
			dialogueShown = true;
			startFirstDialogue();
		}
		
		if (dialogueShown && !isTypewriterComplete && dialogBox.visible)
		{
			isDialogueActive = true;
			updateTypewriter(elapsed);
			
			#if !android
			if (FlxG.keys.justPressed.ENTER)
			{
				if (!isTypewriterComplete)
				{
					displayedText = fullText;
					currentCharIndex = fullText.length;
					isTypewriterComplete = true;
				}
			}
			#end
		}
		else if (dialogueShown && isTypewriterComplete && dialogBox.visible)
		{
			isDialogueActive = true;
			#if !android
			if (FlxG.keys.justPressed.ENTER)
			{
				advanceDialogue();
			}
			#end
		}
		else
		{
			isDialogueActive = false;
			
			if (!musicTransitionStarted && dialogueShown && currentDialogue > 1)
			{
				musicTransitionStarted = true;
				musicFadeTimer = 0.0;
				MusicManager.play("geton");
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
		
		dialogueText.text = displayedText;
		
		if (currentCharIndex >= fullText.length)
		{
			isTypewriterComplete = true;
			if (currentDialogue < 2)
			{
				skipHintText.visible = true;
			}
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
		skipHintText.visible = false;
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
			skipHintText.visible = false;
		}
		else
		{
			dialogBox.visible = false;
			speakerText.visible = false;
			dialogueText.visible = false;
			skipHintText.visible = false;
		}
	}
	
	private function showDialogue():Void
	{
		var line1 = "EVERYONE EVACUATE THE SHIP";
		dialogueText.text = line1;
		
		new flixel.util.FlxTimer().start(3.0, function(_) {
			var line2 = "Captain Nova, please gather all the notes around the\nship to get the code to escape. You have 10 minutes.";
			dialogueText.text = line2;
		});
	}
	
	public function destroy():Void
	{
		if (redOverlay != null) redOverlay.destroy();
		if (dialogBox != null) dialogBox.destroy();
		if (dialogueText != null) dialogueText.destroy();
		if (speakerText != null) speakerText.destroy();
		if (group != null) group.destroy();
	}
}
