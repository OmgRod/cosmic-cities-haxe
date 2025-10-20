package ui.dialog;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import utils.BMFont;

class DialogBox extends FlxGroup
{
	public var dialogBox:FlxSprite;
	public var speakerText:FlxBitmapText;
	public var dialogueText:FlxBitmapText;
	public var skipHintText:FlxBitmapText;

	private var font:FlxBitmapFont;

	public function new()
	{
		super();

		try
		{
			var fontString = "pixel_operator";
			font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

			dialogBox = new FlxSprite(20, FlxG.height - 140);
			dialogBox.makeGraphic(FlxG.width - 40, 120, 0xFF1a1a1a);
			dialogBox.scrollFactor.set(0, 0);
			dialogBox.visible = false;
			add(dialogBox);

			speakerText = new FlxBitmapText(40, FlxG.height - 125, "CAPTAIN RAY:", font);
			speakerText.color = 0xFFFFFF00;
			speakerText.scrollFactor.set(0, 0);
			speakerText.scale.set(0.8, 0.8);
			speakerText.visible = false;
			add(speakerText);

			dialogueText = new FlxBitmapText(40, FlxG.height - 105, "", font);
			dialogueText.color = 0xFFFFFFFF;
			dialogueText.scrollFactor.set(0, 0);
			dialogueText.scale.set(0.7, 0.7);
			dialogueText.visible = false;
			add(dialogueText);

			skipHintText = new FlxBitmapText(40, FlxG.height - 60, "Press ENTER to continue", font);
			skipHintText.color = 0xFF888888;
			skipHintText.scrollFactor.set(0, 0);
			skipHintText.scale.set(0.6, 0.6);
			skipHintText.visible = false;
			add(skipHintText);
		}
		catch (e:Dynamic)
		{
			trace("ERROR creating DialogBox: " + e);
			throw e;
		}
	}

	override public function set_visible(value:Bool):Bool
	{
		if (dialogBox != null)
			dialogBox.visible = value;
		if (speakerText != null)
			speakerText.visible = value;
		if (dialogueText != null)
			dialogueText.visible = value;
		if (skipHintText != null && !value)
		{
			skipHintText.visible = false;
		}
		return super.set_visible(value);
	}

	public function setSpeaker(speaker:String):Void
	{
		speakerText.text = speaker;
	}

	public function setDialogue(dialogue:String):Void
	{
		dialogueText.text = dialogue;
	}

	public function showSkipHint(show:Bool):Void
	{
		skipHintText.visible = show;
	}

	public function hide():Void
	{
		dialogBox.visible = false;
		speakerText.visible = false;
		dialogueText.visible = false;
		skipHintText.visible = false;
	}

	public function show():Void
	{
		dialogBox.visible = true;
		speakerText.visible = true;
		dialogueText.visible = true;
	}
}
