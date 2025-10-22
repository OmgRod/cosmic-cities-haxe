package gameplay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import managers.DialogueManager;
import managers.EventManager;
import managers.MusicManager;
import ui.NotesLayer;
import ui.Overlay;
import ui.dialog.DialogBox;
import utils.BMFont;
import utils.GameSaveManager;

class EvacuationIntro
{
	public var isActive:Bool = false;
	public var isComplete:Bool = false;
	public var isDialogueActive:Bool = false;
	
	private var timer:Float = 0.0;
	private var evacuationTimer:Float = 600.0;
	private var evacuationTimerDisplay:FlxBitmapText;
	private var timerBackgroundBg:FlxSprite;
	private var timerFont:FlxBitmapFont;
	private var alarmFlashTimer:Float = 0.0;
	private var alarmFlashInterval:Float = 2.5;
	private var dialogueShown:Bool = false;
	private var currentDialogue:Int = 0;
	private var dialogueEnded:Bool = false;
	private var hasPlayedOnce:Bool = false;
	private var musicTransitionStarted:Bool = false;
	private var musicFadeTimer:Float = 0.0;
	private var musicFadeDuration:Float = 0.5;
	private var timerExpired:Bool = false;
	
	private var chapterOverlay:Overlay;
	private var chapterText:FlxBitmapText;
	private var chapterShown:Bool = false;
	private var chapterFadeOutTimer:Float = 0.0;
	private var chapterFadingOut:Bool = false;
	private var chapterHitSound:FlxSound;

	private var redOverlay:Overlay;
	private var dialogBox:DialogBox;
	private var notesLayer:NotesLayer;
	private var letterPuzzles:Array<{x:Float, y:Float, data:String}> = [];

	private var dialogueManager:DialogueManager;
	private var eventManager:EventManager;
	
	public function new()
	{
		dialogueManager = DialogueManager.getInstance();
		eventManager = EventManager.getInstance();
		
		redOverlay = new Overlay(0xFFFF0000, 0);
		
		dialogBox = new DialogBox();
		timerFont = new BMFont("assets/fonts/pixel_operator/pixel_operator.fnt", "assets/fonts/pixel_operator/pixel_operator.png").getFont();

		timerBackgroundBg = new FlxSprite(0, 20);
		timerBackgroundBg.makeGraphic(140, 50, 0x00000000);
		timerBackgroundBg.alpha = 0.7;
		timerBackgroundBg.scrollFactor.set(0, 0);
		timerBackgroundBg.visible = false;

		evacuationTimerDisplay = new FlxBitmapText(0, 30, "5:00", timerFont);
		evacuationTimerDisplay.color = 0xFFFFFFFF;
		evacuationTimerDisplay.scrollFactor.set(0, 0);
		evacuationTimerDisplay.scale.set(1.0, 1.0);
		evacuationTimerDisplay.visible = false;

		chapterOverlay = new Overlay(0xFF000000, 1.0);

		chapterText = new FlxBitmapText(0, 0, Main.tongue.get("$CHAPTER_1_TITLE", "ui"), timerFont);
		chapterText.color = 0xFFFFFFFF;
		chapterText.scrollFactor.set(0, 0);
		chapterText.scale.set(1.5, 1.5);
		chapterText.updateHitbox();
		chapterText.x = Math.floor((FlxG.width - chapterText.frameWidth * 1.5) / 2);
		chapterText.y = Math.floor((FlxG.height - chapterText.frameHeight * 1.5) / 2);
		chapterText.visible = false;

		chapterHitSound = new FlxSound();
		chapterHitSound.loadEmbedded("assets/sounds/sfx.chapterhit.1.wav");
		chapterHitSound.volume = 1.0;
		chapterHitSound.autoDestroy = false;
		FlxG.sound.list.add(chapterHitSound);

		isActive = false;
		isComplete = false;
		isDialogueActive = true;
	}
	
	public function setObjectGroups(objectGroups:Map<String, Array<Dynamic>>):Void
	{
		trace("===== EvacuationIntro.setObjectGroups called =====");
		trace("Available object groups: " + [for (k in objectGroups.keys()) k].join(", "));

		letterPuzzles = [];
		
		if (objectGroups.exists("Interactions"))
		{
			trace("Found Interactions layer");
			var interactions = objectGroups.get("Interactions");
			
			trace("Total objects in Interactions: " + interactions.length);
			for (obj in interactions)
			{
				trace("  Object: " + obj.name);
				if (obj.name == "letter-puzzle")
				{
					var data = obj.properties.get("data");
					trace("    Found letter-puzzle with data: " + data);
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
			trace("Total letter puzzles found: " + letterPuzzles.length);
		}
		else
		{
			trace("Interactions layer NOT FOUND");
		}
		trace("===== EvacuationIntro.setObjectGroups complete =====");
	}

	public function getLetterPuzzles():Array<{x:Float, y:Float, data:String}>
	{
		return letterPuzzles;
	}
	public function getRedOverlay():Overlay
	{
		return redOverlay;
	}

	public function getChapterOverlay():Overlay
	{
		return chapterOverlay;
	}

	public function getChapterText():FlxBitmapText
	{
		return chapterText;
	}

	public function getDialogBox():DialogBox
	{
		return dialogBox;
	}

	public function getTimerDisplay():FlxBitmapText
	{
		return evacuationTimerDisplay;
	}

	public function getTimerBackground():FlxSprite
	{
		return timerBackgroundBg;
	}

	public function isPauseBlocked():Bool
	{
		return isActive && !dialogueEnded;
	}
	
	public function start():Void
	{
		if (hasPlayedOnce)
			return;

		isActive = true;
		isComplete = false;
		isDialogueActive = true;
		timer = 0.0;
		evacuationTimer = 300.0;
		alarmFlashTimer = 0.0;
		dialogueShown = false;
		currentDialogue = 0;
		dialogueEnded = false;
		musicTransitionStarted = false;
		musicFadeTimer = 0.0;
		timerExpired = false;

		chapterShown = false;
		chapterFadeOutTimer = 0.0;
		chapterFadingOut = false;
		chapterOverlay.visible = true;
		chapterOverlay.alpha = 1.0;
		chapterText.visible = true;
		chapterText.alpha = 1.0;

		redOverlay.visible = false;
		redOverlay.alpha = 0;
		evacuationTimerDisplay.visible = false;
		timerBackgroundBg.visible = false;

		var timerWidth:Float = 140;
		var timerX:Float = (FlxG.width - timerWidth) / 2;
		timerBackgroundBg.x = timerX;
		evacuationTimerDisplay.x = timerX + 25;
	}

	public function reset():Void
	{
		hasPlayedOnce = false;
		isActive = false;
		isComplete = false;
		isDialogueActive = false;
		timer = 0.0;
		evacuationTimer = 300.0;
		alarmFlashTimer = 0.0;
		dialogueShown = false;
		currentDialogue = 0;
		dialogueEnded = false;
		musicTransitionStarted = false;
		musicFadeTimer = 0.0;
		timerExpired = false;
		chapterShown = false;
		chapterFadeOutTimer = 0.0;
		chapterFadingOut = false;
		redOverlay.visible = false;
		redOverlay.alpha = 0;
		evacuationTimerDisplay.visible = false;
		timerBackgroundBg.visible = false;
		chapterOverlay.visible = false;
		chapterOverlay.alpha = 0;
		chapterText.visible = false;
		chapterText.alpha = 0;
	}
	
	public function update(elapsed:Float):Void
	{
		if (!isActive)
		{
			trace("EvacuationIntro update: not active");
			return;
		}

		timer += elapsed;

		if (!chapterShown)
		{
			trace("Chapter showing for first time at timer: " + timer);
			chapterShown = true;
			chapterOverlay.visible = true;
			chapterText.visible = true;
			trace("Playback volume: " + FlxG.sound.volume + " | muted: " + FlxG.sound.muted);
			var musicVolumeInfo = FlxG.sound.music != null ? Std.string(FlxG.sound.music.volume) : "null";
			trace("soundGroup volume: " + FlxG.sound.defaultSoundGroup.volume + " | music volume: " + musicVolumeInfo);
			if (chapterHitSound != null)
			{
				chapterHitSound.stop();
				chapterHitSound.volume = 1.0;
				chapterHitSound.play(true);
				var groupVolumeInfo = chapterHitSound.group != null ? Std.string(chapterHitSound.group.volume) : "null";
				trace("Chapterhit sound triggered successfully, actual volume: " + chapterHitSound.volume + " | group vol: " + groupVolumeInfo);
			}
			else
			{
				trace("Chapterhit sound failed to load!");
			}
			trace("Chapter intro displayed at timer: " + timer + ", sound played");
		}
		else if (chapterShown && !chapterFadingOut && timer >= 5.0)
		{
			chapterFadingOut = true;
			chapterFadeOutTimer = 0.0;
			trace("Starting chapter fade out");
		}

		if (chapterFadingOut)
		{
			chapterFadeOutTimer += elapsed;
			var fadeProgress = Math.min(chapterFadeOutTimer / 0.5, 1.0);
			chapterOverlay.alpha = 1.0 - fadeProgress;
			chapterText.alpha = 1.0 - fadeProgress;

			if (fadeProgress >= 1.0)
			{
				chapterOverlay.visible = false;
				chapterText.visible = false;
				showEvacuationSequence();
			}
		}

		if (chapterFadingOut || (chapterShown && timer >= 5.0))
		{
			updateAlarmFlash(elapsed);

			if (!dialogueShown)
			{
				showInitialDialogue();
			}

			if (dialogueShown && !dialogueEnded && dialogBox != null)
			{
				isDialogueActive = dialogBox.isActive;
			}

			if (dialogueEnded && !timerExpired)
			{
				updateTimer(elapsed);
			}
		}
	}

	private function updateAlarmFlash(elapsed:Float):Void
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
	}

	private function updateTimer(elapsed:Float):Void
	{
		evacuationTimer -= elapsed;

		if (evacuationTimer < 0)
			evacuationTimer = 0;
		
		updateTimerDisplay();
		
		if (evacuationTimer <= 0)
		{
			timerExpired = true;
			trace("EVACUATION TIMER EXPIRED!");
			eventManager.emit("evacuation_timer_expired", {});
		}
	}
	
	private function updateTimerDisplay():Void
	{
		var minutes:Int = Std.int(Math.floor(evacuationTimer / 60));
		var seconds:Int = Std.int(Math.floor(evacuationTimer % 60));

		if (minutes < 0)
			minutes = 0;
		if (seconds < 0)
			seconds = 0;
		
		var minStr = (minutes < 5 ? "0" : "") + Std.string(minutes);
		var secStr = (seconds < 5 ? "0" : "") + Std.string(seconds);
		evacuationTimerDisplay.text = minStr + ":" + secStr;
	}

	private function showEvacuationSequence():Void
	{
		redOverlay.visible = true;
		redOverlay.alpha = 0.6;
	}
	
	private function showInitialDialogue():Void
	{
		dialogueShown = true;
		startFirstDialogue();
	}
	
	private function startFirstDialogue():Void
	{
		currentDialogue = 0;
		var text = Main.tongue.get("$EVACUATION_EVACUATE", "dialog");
		dialogBox.show("SYSTEM", text, () -> advanceDialogue());
	}
	
	private function advanceDialogue():Void
	{
		currentDialogue++;
		
		if (currentDialogue == 1)
		{
			var playerName:String = GameSaveManager.currentData != null ? GameSaveManager.currentData.username : "Nova";
			var template = Main.tongue.get("$EVACUATION_GATHER_NOTES", "dialog");
			var text = StringTools.replace(template, "{player}", playerName);
			dialogBox.show("SYSTEM", text, () -> completeDialogue());
		}
		else
		{
			completeDialogue();
		}
	}

	private function completeDialogue():Void
	{
		dialogueEnded = true;
		dialogBox.hide();
		isDialogueActive = false;
		isComplete = true;
		hasPlayedOnce = true;
		evacuationTimerDisplay.visible = true;
		timerBackgroundBg.visible = true;

		MusicManager.play("geton");
	}
	
	public function destroy():Void
	{
		if (redOverlay != null) redOverlay.destroy();
		if (dialogBox != null)
			dialogBox.destroy();
		if (notesLayer != null)
			notesLayer.destroy();
		if (chapterHitSound != null)
		{
			chapterHitSound.destroy();
			chapterHitSound = null;
		}
	}
}
