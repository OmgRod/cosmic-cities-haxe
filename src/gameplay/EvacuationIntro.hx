package gameplay;

import StringTools;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
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
	// Interval between alarm pulses (seconds). Default increased to be less frequent/annoying.
	private var alarmFlashInterval:Float = 2.5;
	// Deterministic flash state for the red alarm overlay.
	private var redFlashRemaining:Float = 0.0;
	// Visual flash parameters
	private var redFlashDuration:Float = 0.35; // seconds for a single flash to fade
	private var redFlashPeak:Float = 0.75; // peak alpha when flash triggers
	private var dialogueShown:Bool = false;
	private var currentDialogue:Int = 0;
	private var dialogueEnded:Bool = false;
	private var hasPlayedOnce:Bool = false;
	private var musicTransitionStarted:Bool = false;
	private var musicFadeTimer:Float = 0.0;
	private var musicFadeDuration:Float = 0.5;
	private var timerExpired:Bool = false;

	private var pauseTimerUntilResume:Bool = false;

	private var chapterOverlay:Overlay;
	private var chapterText:FlxBitmapText;
	private var chapterShown:Bool = false;
	private var chapterFadeOutTimer:Float = 0.0;
	private var chapterFadingOut:Bool = false;
	private var chapterHitSound:FlxSound;
	private var alarmSound:FlxSound;
	private var alarmLoadedEmbedded:Bool = false;
	private var alarmBaseVolume:Float = 0.6;

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

		alarmSound = new FlxSound();
		try
		{
			alarmSound.loadEmbedded("assets/sounds/sfx.alarm.1.wav");
			alarmLoadedEmbedded = true;
		}
		catch (e:Dynamic)
		{
			alarmSound.loadStream("assets/sounds/sfx.alarm.1.wav", true);
			alarmLoadedEmbedded = false;
		}
		alarmSound.volume = alarmBaseVolume;
		alarmSound.autoDestroy = false;
		FlxG.sound.list.add(alarmSound);

		isActive = false;
		isComplete = false;
		isDialogueActive = true;
	}

	/**
	 * Adjust the interval between alarm pulses at runtime.
	 * Use larger values to make the alarm less frequent.
	 */
	public function setAlarmInterval(seconds:Float):Void
	{
		if (seconds > 0)
			alarmFlashInterval = seconds;
	}

	/**
	 * Retrieve the current alarm interval (seconds).
	 */
	public function getAlarmInterval():Float
	{
		return alarmFlashInterval;
	}

	public function setObjectGroups(objectGroups:Map<String, Array<Dynamic>>):Void
	{
		letterPuzzles = [];
		if (objectGroups.exists("Interactions"))
		{
			var interactions = objectGroups.get("Interactions");
			for (obj in interactions)
			{
				if (obj.name == "letter-puzzle")
				{
					var data = obj.properties.get("data");
					if (data != null)
						letterPuzzles.push({x: obj.x, y: obj.y, data: data});
				}
			}
		}
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
		evacuationTimer = 10.0;
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

	public function startAtDialogue():Void
	{
		isActive = true;
		isComplete = false;
		isDialogueActive = true;
		timer = 5.0;
		dialogueShown = false;
		currentDialogue = 0;
		dialogueEnded = false;
		alarmFlashTimer = 0.0;
		redFlashRemaining = 0.0;

		chapterOverlay.visible = false;
		chapterOverlay.alpha = 0;
		chapterText.visible = false;
		chapterText.alpha = 0;

		evacuationTimerDisplay.visible = false;
		timerBackgroundBg.visible = false;

		showInitialDialogue();
	}

	public function reset():Void
	{
		hasPlayedOnce = false;
		isActive = false;
		isComplete = false;
		isDialogueActive = false;
		timer = 0.0;
		evacuationTimer = 10.0;
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
			return;

		timer += elapsed;

		if (!chapterShown)
		{
			chapterShown = true;
			chapterOverlay.visible = true;
			chapterText.visible = true;
			if (chapterHitSound != null)
			{
				chapterHitSound.stop();
				chapterHitSound.volume = 1.0;
				chapterHitSound.play(true);
			}
		}
		else if (chapterShown && !chapterFadingOut && timer >= 5.0)
		{
			chapterFadingOut = true;
			chapterFadeOutTimer = 0.0;
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
				showInitialDialogue();
			if (dialogueShown && !dialogueEnded && dialogBox != null)
				isDialogueActive = dialogBox.isActive;
			if (dialogueEnded && !timerExpired)
				updateTimer(elapsed);
		}
	}

	private function updateTimer(elapsed:Float):Void
	{
		// If the timer is paused (waiting for a screen-fade to finish), do not
		// advance the evacuation countdown.
		if (pauseTimerUntilResume)
			return;

		evacuationTimer -= elapsed;
		if (evacuationTimer < 0)
			evacuationTimer = 0;
		updateTimerDisplay();

		if (evacuationTimer <= 0 && !timerExpired)
		{
			timerExpired = true;
			if (alarmSound != null)
				try
				{
					alarmSound.stop();
				}
				catch (e:Dynamic) {}
			if (redOverlay != null)
			{
				redOverlay.visible = false;
				redOverlay.alpha = 0;
			}
			alarmFlashTimer = 0.0;
			if (eventManager != null)
				eventManager.emit('evacuation_timer_expired', {});
		}
	}

	// Called by external code when restarting the game after the explosion
	// effect. This will put the EvacuationIntro into the post-intro state
	// (skip chapter + dialogue) and optionally pause the countdown until
	// the screen fade completes. Call resumeTimerAfterFade() after the
	// fade-in to actually start the timer and music.
	public function startAfterExplosion(waitForFade:Bool = true):Void
	{
		// Mark as played so start() won't re-run the intro sequence.
		hasPlayedOnce = true;
		isActive = true;
		isComplete = true;
		dialogueEnded = true;
		isDialogueActive = false;
		// Reset timers to the beginning of the countdown.
		timer = 0.0;
		evacuationTimer = 10.0;
		alarmFlashTimer = 0.0;

		// Hide chapter intro assets and ensure the evacuation UI is visible.
		chapterOverlay.visible = false;
		chapterOverlay.alpha = 0;
		chapterText.visible = false;
		chapterText.alpha = 0;

		redOverlay.visible = false;
		redOverlay.alpha = 0;
		evacuationTimerDisplay.visible = true;
		timerBackgroundBg.visible = true;

		// Pause the timer until resume is called (if requested).
		pauseTimerUntilResume = waitForFade;

		// If we are not waiting for the fade, start music immediately.
		if (!waitForFade)
		{
			MusicManager.play("geton");
		}
	}
	// Resume the evacuation timer after an external fade-in has completed.
	// This also starts the evacuation music. Call this when the screen is
	// fully visible again.
	public function resumeTimerAfterFade():Void
	{
		pauseTimerUntilResume = false;
		MusicManager.play("geton");
	}

	public function updateAlarmFlash(elapsed:Float):Void
	{
		// Timer that triggers when the periodic alarm should flash.
		alarmFlashTimer += elapsed;

		if (alarmFlashTimer >= alarmFlashInterval)
		{
			alarmFlashTimer = 0.0;
			if (isActive && !timerExpired)
			{
				// Start a deterministic flash sequence (we track remaining time
				// and compute alpha as a function of remaining / duration). This
				// avoids relying on other parts of the code to toggle visibility.
				redFlashRemaining = redFlashDuration;
				// Force the overlay to the peak alpha immediately so visuals are
				// synced with the SFX play. This prevents other code from
				// accidentally hiding it before the sound plays.
				if (redOverlay != null)
				{
					redOverlay.alpha = redFlashPeak;
					redOverlay.visible = true;
				}
				if (alarmSound != null)
				{
					var musicPlaying = MusicManager.getCurrent() != null;
					alarmSound.volume = musicPlaying ? alarmBaseVolume * 0.5 : alarmBaseVolume;
					// Avoid overlapping plays by stopping any currently-playing instance
					try
					{
						alarmSound.stop();
					}
					catch (e:Dynamic) {}
					try
					{
						// play(false) ensures it does not loop; we rely on alarmFlashInterval to retrigger
						alarmSound.play(false);
					}
					catch (e:Dynamic) {}
				}
				else
				{
					var musicPlaying = MusicManager.getCurrent() != null;
					// Use a single FlxG.sound.play call; do not play multiple overlapping instances
					FlxG.sound.play("assets/sounds/sfx.alarm.1.wav", alarmBaseVolume * (musicPlaying ? 0.5 : 1));
				}
			}
		}

		// If we are in an active flash, compute alpha from remaining time.
		if (redFlashRemaining > 0)
		{
			redFlashRemaining = Math.max(0, redFlashRemaining - elapsed);
			// alpha ramps down linearly from peak to 0 over redFlashDuration
			var progress = 1.0 - (redFlashRemaining / redFlashDuration);
			if (redOverlay != null)
			{
				redOverlay.alpha = redFlashPeak * (1.0 - progress);
				redOverlay.visible = redOverlay.alpha > 0;
			}
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
		evacuationTimerDisplay.text = (minutes < 10 ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
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
			completeDialogue();
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
		// Notify any listeners that the evacuation dialogue sequence has completed
		if (eventManager != null)
		{
			eventManager.emit('evacuation_dialogue_complete', {});
		}
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
