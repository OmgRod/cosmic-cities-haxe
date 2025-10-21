package states.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import haxe.ds.StringMap;
import states.OptionsState;
import ui.backgrounds.Starfield;
import ui.menu.TextButton;
import utils.BMFont;
import utils.GameSaveManager;

class ControlsSettingsState extends FlxState
{
	var scrollContainer:FlxSpriteGroup;
	var scrollContainerMask:FlxSprite;
	var font:FlxBitmapFont;
	var titleText:FlxBitmapText;
	var backBtn:TextButton;
	var resetBtn:TextButton;
	
	var controlButtons:Array<ControlButton> = [];
	var currentlyRebinding:Null<ControlButton> = null;
	
	var controls:Array<String> = ["moveLeft", "moveRight", "moveUp", "moveDown", "skipDialog", "advanceDialog", "pause", "quit"];
	var controlLabels:StringMap<String> = new StringMap();
	var controlBindings:StringMap<String> = new StringMap();
	var originalBindings:StringMap<String> = new StringMap();
	
	var scrollY:Float = 0;
	var maxScrollY:Float = 0;
	var scrollSpeed:Float = 50;

	override public function create():Void
	{
		super.create();

		add(new Starfield());

		var fontData = Main.tongue.getFontData("pixel_operator", 16);
		var fontString = fontData.name;
		font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();
		
		controlLabels.set("moveLeft", Main.tongue.get("$CONTROLS_MOVE_LEFT", "ui"));
		controlLabels.set("moveRight", Main.tongue.get("$CONTROLS_MOVE_RIGHT", "ui"));
		controlLabels.set("moveUp", Main.tongue.get("$CONTROLS_MOVE_UP", "ui"));
		controlLabels.set("moveDown", Main.tongue.get("$CONTROLS_MOVE_DOWN", "ui"));
		controlLabels.set("skipDialog", Main.tongue.get("$CONTROLS_SKIP_DIALOG", "ui"));
		controlLabels.set("advanceDialog", Main.tongue.get("$CONTROLS_ADVANCE_DIALOG", "ui"));
		controlLabels.set("pause", Main.tongue.get("$CONTROLS_PAUSE_MENU", "ui"));
		controlLabels.set("quit", Main.tongue.get("$CONTROLS_QUIT_GAME", "ui"));
		
		var currentControls = GameSaveManager.getControls();
		controlBindings.set("moveLeft", currentControls.moveLeft != null ? currentControls.moveLeft : "LEFT");
		controlBindings.set("moveRight", currentControls.moveRight != null ? currentControls.moveRight : "RIGHT");
		controlBindings.set("moveUp", currentControls.moveUp != null ? currentControls.moveUp : "UP");
		controlBindings.set("moveDown", currentControls.moveDown != null ? currentControls.moveDown : "DOWN");
		controlBindings.set("skipDialog", currentControls.skipDialog != null ? currentControls.skipDialog : "X");
		controlBindings.set("advanceDialog", currentControls.advanceDialog != null ? currentControls.advanceDialog : "ENTER");
		controlBindings.set("pause", currentControls.pause != null ? currentControls.pause : "P");
		controlBindings.set("quit", currentControls.quit != null ? currentControls.quit : "BACKSPACE");
		
		for (key in controlBindings.keys())
			originalBindings.set(key, controlBindings.get(key));

		scrollContainer = new FlxSpriteGroup();
		add(scrollContainer);

		scrollContainerMask = new FlxSprite(0, 100);
		scrollContainerMask.makeGraphic(FlxG.width, FlxG.height - 200, 0xFF000000);
		scrollContainerMask.alpha = 0;
		
		loadFontAndTexts();
		createControlButtons();
		addNavigationButtons();
	}

	function loadFontAndTexts():Void
	{
		if (titleText != null)
			remove(titleText);
		var scaleBig = 1.3;
		titleText = new FlxBitmapText(0, 0, Main.tongue.get("$CONTROLS_TITLE", "ui"), font);
		titleText.scale.set(scaleBig, scaleBig);
		titleText.updateHitbox();
		titleText.x = Math.floor((FlxG.width - titleText.frameWidth * scaleBig) / 2);
		titleText.y = 20;
		add(titleText);
	}

	public function updateFont():Void
	{
		var fontData = Main.tongue.getFontData("pixel_operator", 16);
		var fontString = fontData.name;
		font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();
		
		loadFontAndTexts();
		
		createControlButtons();
		
		if (resetBtn != null)
			remove(resetBtn);
		if (backBtn != null)
			remove(backBtn);
		addNavigationButtons();
	}

	function createControlButtons():Void
	{
		for (btn in controlButtons)
			scrollContainer.remove(btn, true);
		controlButtons = [];

		var startX = 50;
		var startY = 100;
		var buttonWidth = FlxG.width - 100;
		var buttonHeight = 40;
		var buttonSpacing = 10;
		var currentY = startY;

		for (controlName in controls)
		{
			var label = controlLabels.get(controlName);
			var binding = controlBindings.get(controlName);
			var btn = new ControlButton(startX, currentY, label, binding, font, buttonWidth, buttonHeight, controlName);
			btn.setScrollContainer(scrollContainer);
			
			btn.setCallback(() ->
			{
				if (currentlyRebinding != null)
				{
					currentlyRebinding.stopRebinding();
					currentlyRebinding.setBinding(originalBindings.get(currentlyRebinding.controlName));
					controlBindings.set(currentlyRebinding.controlName, originalBindings.get(currentlyRebinding.controlName));
				}
				currentlyRebinding = btn;
				btn.startRebinding();
			});
			
			controlButtons.push(btn);
			scrollContainer.add(btn);
			currentY += buttonHeight + buttonSpacing;
		}
		
		maxScrollY = Math.max(0, currentY - (FlxG.height - 200));
	}

	function addNavigationButtons():Void
	{
		var btnWidth = 100;
		var btnHeight = 35;
		var y = FlxG.height - 100;

		resetBtn = new TextButton(50, y, Main.tongue.get("$CONTROLS_RESET", "ui"), font, btnWidth, btnHeight);
		resetBtn.setCallback(() ->
		{
			controlBindings = new StringMap();
			var defaults = GameSaveManager.getDefaultControls();
			controlBindings.set("moveLeft", defaults.moveLeft);
			controlBindings.set("moveRight", defaults.moveRight);
			controlBindings.set("moveUp", defaults.moveUp);
			controlBindings.set("moveDown", defaults.moveDown);
			controlBindings.set("skipDialog", defaults.skipDialog);
			controlBindings.set("advanceDialog", defaults.advanceDialog);
			controlBindings.set("pause", defaults.pause);
			controlBindings.set("quit", defaults.quit);
			createControlButtons();
		});
		add(resetBtn);

		backBtn = new TextButton((FlxG.width - 150) / 2, FlxG.height - 50, Main.tongue.get("$CONTROLS_BACK", "ui"), font, 150, 40);
		backBtn.setCallback(() ->
		{
			var controls:utils.GameSaveManager.ControlsData = {
				moveLeft: controlBindings.get("moveLeft"),
				moveRight: controlBindings.get("moveRight"),
				moveUp: controlBindings.get("moveUp"),
				moveDown: controlBindings.get("moveDown"),
				skipDialog: controlBindings.get("skipDialog"),
				advanceDialog: controlBindings.get("advanceDialog"),
				pause: controlBindings.get("pause"),
				quit: controlBindings.get("quit")
			};
			GameSaveManager.saveControls(controls);
			FlxG.switchState(() -> new OptionsState());
		});
		add(backBtn);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.wheel != 0)
		{
			scrollY -= FlxG.mouse.wheel * scrollSpeed;
			scrollY = Math.max(0, Math.min(scrollY, maxScrollY));
		}

		scrollContainer.y = -scrollY;

		if (currentlyRebinding != null)
		{
			var binding:Null<String> = null;
			
			if (FlxG.keys.justPressed.LEFT) binding = "LEFT";
			else if (FlxG.keys.justPressed.RIGHT) binding = "RIGHT";
			else if (FlxG.keys.justPressed.UP) binding = "UP";
			else if (FlxG.keys.justPressed.DOWN) binding = "DOWN";
			else if (FlxG.keys.justPressed.X) binding = "X";
			else if (FlxG.keys.justPressed.ENTER) binding = "ENTER";
			else if (FlxG.keys.justPressed.SPACE) binding = "SPACE";
			else if (FlxG.keys.justPressed.ESCAPE) binding = "ESCAPE";
			else if (FlxG.keys.justPressed.P) binding = "P";
			else if (FlxG.keys.justPressed.BACKSPACE) binding = "BACKSPACE";
			else if (FlxG.keys.justPressed.TAB) binding = "TAB";
			else if (FlxG.keys.justPressed.SHIFT) binding = "SHIFT";
			else if (FlxG.keys.justPressed.ALT) binding = "ALT";
			else if (FlxG.keys.justPressed.ONE) binding = "1";
			else if (FlxG.keys.justPressed.TWO) binding = "2";
			else if (FlxG.keys.justPressed.THREE) binding = "3";
			else if (FlxG.keys.justPressed.FOUR) binding = "4";
			else if (FlxG.keys.justPressed.FIVE) binding = "5";
			else if (FlxG.keys.justPressed.SIX) binding = "6";
			else if (FlxG.keys.justPressed.SEVEN) binding = "7";
			else if (FlxG.keys.justPressed.EIGHT) binding = "8";
			else if (FlxG.keys.justPressed.NINE) binding = "9";
			else if (FlxG.keys.justPressed.ZERO) binding = "0";
			else if (FlxG.keys.justPressed.A) binding = "A";
			else if (FlxG.keys.justPressed.B) binding = "B";
			else if (FlxG.keys.justPressed.C) binding = "C";
			else if (FlxG.keys.justPressed.D) binding = "D";
			else if (FlxG.keys.justPressed.E) binding = "E";
			else if (FlxG.keys.justPressed.F) binding = "F";
			else if (FlxG.keys.justPressed.G) binding = "G";
			else if (FlxG.keys.justPressed.H) binding = "H";
			else if (FlxG.keys.justPressed.I) binding = "I";
			else if (FlxG.keys.justPressed.J) binding = "J";
			else if (FlxG.keys.justPressed.K) binding = "K";
			else if (FlxG.keys.justPressed.L) binding = "L";
			else if (FlxG.keys.justPressed.M) binding = "M";
			else if (FlxG.keys.justPressed.N) binding = "N";
			else if (FlxG.keys.justPressed.O) binding = "O";
			else if (FlxG.keys.justPressed.Q) binding = "Q";
			else if (FlxG.keys.justPressed.R) binding = "R";
			else if (FlxG.keys.justPressed.S) binding = "S";
			else if (FlxG.keys.justPressed.T) binding = "T";
			else if (FlxG.keys.justPressed.U) binding = "U";
			else if (FlxG.keys.justPressed.V) binding = "V";
			else if (FlxG.keys.justPressed.W) binding = "W";
			else if (FlxG.keys.justPressed.Y) binding = "Y";
			else if (FlxG.keys.justPressed.Z) binding = "Z";
			else if (FlxG.keys.justPressed.F1) binding = "F1";
			else if (FlxG.keys.justPressed.F2) binding = "F2";
			else if (FlxG.keys.justPressed.F3) binding = "F3";
			else if (FlxG.keys.justPressed.F4) binding = "F4";
			else if (FlxG.keys.justPressed.F5) binding = "F5";
			else if (FlxG.keys.justPressed.F6) binding = "F6";
			else if (FlxG.keys.justPressed.F7) binding = "F7";
			else if (FlxG.keys.justPressed.F8) binding = "F8";
			else if (FlxG.keys.justPressed.F9) binding = "F9";
			else if (FlxG.keys.justPressed.F10) binding = "F10";
			else if (FlxG.keys.justPressed.F11) binding = "F11";
			else if (FlxG.keys.justPressed.F12) binding = "F12";
			else if (FlxG.keys.justPressed.COMMA) binding = ",";
			else if (FlxG.keys.justPressed.PERIOD) binding = ".";
			else if (FlxG.keys.justPressed.SEMICOLON) binding = ";";
			else if (FlxG.keys.justPressed.QUOTE) binding = "'";
			else if (FlxG.keys.justPressed.LBRACKET) binding = "[";
			else if (FlxG.keys.justPressed.RBRACKET) binding = "]";
			else if (FlxG.keys.justPressed.BACKSLASH) binding = "\\";
			else if (FlxG.keys.justPressed.SLASH) binding = "/";
			else if (FlxG.keys.justPressed.MINUS) binding = "-";
			
			if (binding != null)
			{
				currentlyRebinding.setBinding(binding);
				controlBindings.set(currentlyRebinding.controlName, binding);
				currentlyRebinding.stopRebinding();
				currentlyRebinding = null;
			}
		}
	}
}

class ControlButton extends flixel.group.FlxSpriteGroup
{
	public var controlName:String;
	var labelText:FlxBitmapText;
	var bindingText:FlxBitmapText;
	var isRebinding:Bool = false;
	var callback:Void->Void;
	var buttonX:Float;
	var buttonY:Float;
	var buttonWidth:Float;
	var buttonHeight:Float;
	var flashTimer:Float = 0;
	var scrollContainer:FlxSpriteGroup;

	public function new(x:Float, y:Float, label:String, binding:String, font:FlxBitmapFont, width:Float, height:Float, name:String = "")
	{
		super(x, y);
		buttonX = x;
		buttonY = y;
		buttonWidth = width;
		buttonHeight = height;
		controlName = name;

		var bg = new flixel.FlxSprite(0, 0);
		bg.makeGraphic(Std.int(width), Std.int(height), 0xFF333333);
		add(bg);

		labelText = new FlxBitmapText(10, Std.int(height / 2 - 8), label, font);
		labelText.color = 0xFFFFFFFF;
		add(labelText);

		bindingText = new FlxBitmapText(Std.int(width - 150), Std.int(height / 2 - 8), binding, font);
		bindingText.color = 0xFF4a52e1;
		add(bindingText);
	}
	
	public function setScrollContainer(container:FlxSpriteGroup):Void
	{
		scrollContainer = container;
	}

	public function setCallback(cb:Void->Void):Void
	{
		callback = cb;
	}

	public function startRebinding():Void
	{
		isRebinding = true;
		bindingText.text = Main.tongue.get("$CONTROLS_PRESS_ANY_KEY", "ui");
		bindingText.color = 0xFFFFFF00;
		flashTimer = 0;
	}

	public function stopRebinding():Void
	{
		isRebinding = false;
		bindingText.color = 0xFF4a52e1;
	}

	public function setBinding(key:String):Void
	{
		bindingText.text = key;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (isRebinding)
		{
			flashTimer += elapsed;
			if (flashTimer > 0.5)
			{
				bindingText.visible = !bindingText.visible;
				flashTimer = 0;
			}
		}
		else
		{
			bindingText.visible = true;
		}

		var mouseX = FlxG.mouse.x;
		var mouseY = FlxG.mouse.y;
		var screenY = buttonY + (scrollContainer != null ? scrollContainer.y : 0);
		
		if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
			mouseY >= screenY && mouseY <= screenY + buttonHeight)
		{
			if (FlxG.mouse.justPressed)
			{
				if (callback != null)
					callback();
			}
		}
	}
}
