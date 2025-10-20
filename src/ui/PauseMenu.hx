package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import managers.MusicManager;
import states.GameState;
import states.MainMenuState;
import states.OptionsState;
import ui.menu.TextButton;
import utils.BMFont;

class PauseMenu extends FlxGroup
{
	var overlay:FlxSprite;
	var title:FlxBitmapText;
	var resumeBtn:TextButton;
	var optionsBtn:TextButton;
	var mainMenuBtn:TextButton;
	
	var isPaused:Bool = false;
	var onResume:Void->Void;
	var onSave:Void->Void;

	public function new(onResume:Void->Void, onSave:Void->Void)
	{
		super();
		
		this.onResume = onResume;
		this.onSave = onSave;
		
		overlay = new FlxSprite(0, 0);
		overlay.makeGraphic(FlxG.width, FlxG.height, 0x88000000);
		overlay.scrollFactor.set(0, 0);
		overlay.visible = false;
		add(overlay);
		
		var fontString = Main.tongue.getFontData("pixel_operator", 16).name;
		var font = new BMFont('assets/fonts/' + fontString + '/' + fontString + '.fnt', 'assets/fonts/' + fontString + '/' + fontString + '.png').getFont();
		
		title = new FlxBitmapText(0, 0, Main.tongue.get("$PAUSE_TITLE", "ui"), font);
		title.scale.set(1.2, 1.2);
		title.updateHitbox();
		title.x = (FlxG.width - title.textWidth * title.scale.x) / 2;
		title.y = 80;
		title.color = 0xFFFFFF00;
		title.scrollFactor.set(0, 0);
		title.visible = false;
		title.active = false;
		add(title);
		
		var btnWidth = 200;
		var btnHeight = 45;
		var btnX = (FlxG.width - btnWidth) / 2;
		var btnStartY = 160;
		var btnGap = 60;
		
		resumeBtn = new TextButton(btnX, btnStartY, Main.tongue.get("$PAUSE_RESUME", "ui"), font, btnWidth, btnHeight);
		resumeBtn.setCallback(() -> toggle());
		resumeBtn.setScrollFactor(0, 0);
		resumeBtn.visible = false;
		resumeBtn.active = false;
		add(resumeBtn);
		
		optionsBtn = new TextButton(btnX, btnStartY + btnGap, Main.tongue.get("$PAUSE_OPTIONS", "ui"), font, btnWidth, btnHeight);
		optionsBtn.setCallback(() -> {
			OptionsState.returnState = GameState;
			FlxG.switchState(() -> new OptionsState());
		});
		optionsBtn.setScrollFactor(0, 0);
		optionsBtn.visible = false;
		optionsBtn.active = false;
		add(optionsBtn);
		
		mainMenuBtn = new TextButton(btnX, btnStartY + btnGap * 2, Main.tongue.get("$PAUSE_MAIN_MENU", "ui"), font, btnWidth, btnHeight);
		mainMenuBtn.setCallback(() -> {
			if (onSave != null) onSave();
			FlxG.switchState(() -> new MainMenuState());
		});
		mainMenuBtn.setScrollFactor(0, 0);
		mainMenuBtn.visible = false;
		mainMenuBtn.active = false;
		add(mainMenuBtn);
	}

	public function toggle():Void {
		isPaused = !isPaused;
		setVisible(isPaused);
		
		if (isPaused)
		{
			MusicManager.pauseAll();
		}
		else
		{
			MusicManager.resumeAll();
			if (onResume != null)
			{
				onResume();
			}
		}
	}
	
	public function show():Void
	{
		isPaused = true;
		setVisible(true);
	}
	
	public function hide():Void
	{
		isPaused = false;
		setVisible(false);
		
		if (onResume != null) {
			onResume();
		}
	}
	
	function setVisible(visible:Bool):Void {
		overlay.visible = visible;
		title.visible = visible;
		title.active = visible;
		resumeBtn.visible = visible;
		resumeBtn.active = visible;
		optionsBtn.visible = visible;
		optionsBtn.active = visible;
		mainMenuBtn.visible = visible;
		mainMenuBtn.active = visible;
	}
	
	public function isPauseActive():Bool
	{
		return isPaused;
	}
}
