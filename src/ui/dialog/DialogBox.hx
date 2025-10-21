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
	public var dialogueLines:Array<FlxBitmapText>;
	public var skipHintText:FlxBitmapText;

	private var font:FlxBitmapFont;

	public var isActive:Bool = false;
	public var onClose:Void->Void;

	private var typewriterWrappedLines:Array<String> = [];
	private var typewriterWrappedWords:Array<Array<String>> = [];

	private var typewriterSpeed:Float = 0.05;
	private var typewriterTimer:Float = 0;
	private var typewriterText:String = "";
	private var typewriterFullText:String = "";
	private var typewriterCharIndex:Int = 0;
	private var isTypewriterComplete:Bool = false;
	private var autoAdvanceDelay:Float = 0;
	private var autoAdvanceEnabled:Bool = false;

	public function new()
	{
		super();

		try
		{
			loadFontAndTexts();
		}
		catch (e:Dynamic)
		{
			trace("ERROR creating DialogBox: " + e);
			throw e;
		}
	}

	private function loadFontAndTexts():Void
	{
		if (speakerText != null)
			remove(speakerText, true);
		if (dialogueLines != null)
		{
			for (line in dialogueLines)
				if (line != null)
					remove(line, true);
		}
		if (skipHintText != null)
			remove(skipHintText, true);

		dialogueLines = [];

		var fontData = Main.tongue.getFontData("pixel_operator", 16);
		var fontString = fontData.name;
		font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

		dialogBox = new FlxSprite(20, FlxG.height - 170);
		dialogBox.makeGraphic(FlxG.width - 40, 150, 0xFF1a1a1a);
		dialogBox.scrollFactor.set(0, 0);
		dialogBox.visible = false;
		add(dialogBox);

		var speakerName = Main.tongue.get("$DIALOG_SPEAKER_NAME", "ui");
		speakerText = new FlxBitmapText(40, FlxG.height - 155, speakerName, font);
		speakerText.color = 0xFFFFFF00;
		speakerText.scrollFactor.set(0, 0);
		speakerText.scale.set(0.8, 0.8);
		speakerText.visible = false;
		add(speakerText);

		for (i in 0...4)
		{
			var lineText = new FlxBitmapText(40, FlxG.height - 133 + (i * 16), "", font);
			lineText.color = 0xFFFFFFFF;
			lineText.scrollFactor.set(0, 0);
			lineText.scale.set(0.7, 0.7);
			lineText.visible = false;
			add(lineText);
			dialogueLines.push(lineText);
		}

		var skipHint = Main.tongue.get("$DIALOG_SKIP_HINT", "ui");
		skipHintText = new FlxBitmapText(40, FlxG.height - 40, skipHint, font);
		skipHintText.color = 0xFF888888;
		skipHintText.scrollFactor.set(0, 0);
		skipHintText.scale.set(0.6, 0.6);
		skipHintText.visible = false;
		add(skipHintText);
	}
	public function updateFont():Void
	{
		loadFontAndTexts();
	}

	override public function set_visible(value:Bool):Bool
	{
		if (dialogBox != null)
			dialogBox.visible = value;
		if (speakerText != null)
			speakerText.visible = value;
		if (dialogueLines != null)
		{
			for (line in dialogueLines)
				line.visible = value;
		}
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
		var wrappedLines = wrapText(dialogue, 65);
		displayWrappedLines(wrappedLines);
	}

	private function displayWrappedLines(wrappedLines:Array<String>):Void
	{
		for (i in 0...dialogueLines.length)
		{
			if (i < wrappedLines.length)
			{
				dialogueLines[i].text = wrappedLines[i];
				dialogueLines[i].visible = true;
			}
			else
			{
				dialogueLines[i].text = "";
				dialogueLines[i].visible = false;
			}
		}
	}

	private function wrapText(text:String, charsPerLine:Int):Array<String>
	{
		var cleanText = removeColorTags(text);

		var words:Array<String> = cleanText.split(" ");
		var lines:Array<String> = [];
		var currentLine:String = "";

		for (word in words)
		{
			var testLine = currentLine == "" ? word : currentLine + " " + word;
			if (testLine.length > charsPerLine && currentLine != "")
			{
				lines.push(currentLine);
				currentLine = word;
			}
			else
			{
				currentLine = testLine;
			}
		}

		if (currentLine != "")
		{
			lines.push(currentLine);
		}

		var trimmedLines:Array<String> = [];
		for (line in lines)
		{
			trimmedLines.push(StringTools.ltrim(line));
		}

		return trimmedLines;
	}

	private function wrapTextByWords(text:String, charsPerLine:Int):Array<Array<String>>
	{
		var cleanText = removeColorTags(text);

		var words:Array<String> = cleanText.split(" ");
		var lines:Array<Array<String>> = [];
		var currentLineWords:Array<String> = [];
		var currentLineLength:Int = 0;

		for (word in words)
		{
			var testLength = currentLineLength + (currentLineWords.length > 0 ? 1 : 0) + word.length;
			if (testLength > charsPerLine && currentLineWords.length > 0)
			{
				lines.push(currentLineWords);
				currentLineWords = [word];
				currentLineLength = word.length;
			}
			else
			{
				currentLineWords.push(word);
				currentLineLength = testLength;
			}
		}

		if (currentLineWords.length > 0)
		{
			lines.push(currentLineWords);
		}

		return lines;
	}

	private function removeColorTags(text:String):String
	{
		var result = text;
		result = ~/\[color=[^\]]*\]/g.replace(result, "");
		result = ~/\[\/color\]/g.replace(result, "");
		result = ~/\[instant=[^\]]*\]/g.replace(result, "");
		result = ~/\[\/instant\]/g.replace(result, "");
		return result;
	}

	public function showSkipHint(show:Bool):Void
	{
		skipHintText.visible = show;
	}

	public function hide():Void
	{
		isActive = false;
		dialogBox.visible = false;
		speakerText.visible = false;
		if (dialogueLines != null)
		{
			for (line in dialogueLines)
				line.visible = false;
		}
		skipHintText.visible = false;
		typewriterText = "";
		typewriterFullText = "";
		typewriterCharIndex = 0;
		typewriterTimer = 0;
	}

	public function show(speaker:String, text:String, ?onClose:Void->Void):Void
	{
		isActive = true;
		setSpeaker(speaker);
		this.onClose = onClose;

		typewriterFullText = text;
		typewriterText = "";
		typewriterCharIndex = 0;
		typewriterTimer = 0;
		isTypewriterComplete = false;
		autoAdvanceDelay = 0;
		autoAdvanceEnabled = false;

		typewriterWrappedWords = wrapTextByWords(text, 65);

		typewriterWrappedLines = [];
		for (wordArray in typewriterWrappedWords)
		{
			typewriterWrappedLines.push(wordArray.join(" "));
		}
		
		for (line in dialogueLines)
		{
			line.text = "";
			line.visible = false;
		}
		
		dialogBox.visible = true;
		speakerText.visible = true;
		showSkipHint(false);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!isActive)
			return;

		updateTypewriter(elapsed);

		if (isTypewriterComplete && autoAdvanceEnabled)
		{
			autoAdvanceDelay -= elapsed;
			if (autoAdvanceDelay <= 0)
			{
				autoAdvanceDelay = 0;
				if (FlxG.keys.justPressed.ENTER)
				{
					closeAndCallback();
				}
			}
		}
		else
		{
			if (FlxG.keys.justPressed.X)
			{
				typewriterCharIndex = typewriterFullText.length;
				typewriterText = typewriterFullText;
				setDialogue(typewriterText);
				showSkipHint(true);
				isTypewriterComplete = true;
			}

			if (FlxG.keys.justPressed.ENTER && isTypewriterComplete)
			{
				closeAndCallback();
			}
		}
	}

	private function closeAndCallback():Void
	{
		hide();
		if (onClose != null)
		{
			onClose();
		}
	}

	private function updateTypewriter(elapsed:Float):Void
	{
		if (typewriterCharIndex >= typewriterFullText.length)
		{
			if (!isTypewriterComplete)
			{
				isTypewriterComplete = true;
				showSkipHint(true);
			}
			return;
		}

		typewriterTimer += elapsed;

		while (typewriterTimer >= typewriterSpeed && typewriterCharIndex < typewriterFullText.length)
		{
			typewriterTimer -= typewriterSpeed;
			typewriterText += typewriterFullText.charAt(typewriterCharIndex);
			typewriterCharIndex++;
		}

		displayTypewriterText(typewriterText);
	}

	private function displayTypewriterText(text:String):Void
	{
		var visibleText = removeColorTags(text);

		var visibleWords:Array<String> = visibleText.split(" ");

		var charCount:Int = 0;
		var wordIndex:Int = 0;

		for (i in 0...dialogueLines.length)
		{
			if (i < typewriterWrappedWords.length)
			{
				var lineWords = typewriterWrappedWords[i];
				var lineDisplayText = "";

				for (j in 0...lineWords.length)
				{
					if (wordIndex < visibleWords.length)
					{
						var word = visibleWords[wordIndex];
						var wordCharsNeeded = word.length + (j > 0 ? 1 : 0);

						if (charCount + wordCharsNeeded <= text.length)
						{
							if (j > 0)
								lineDisplayText += " ";
							lineDisplayText += word;
							charCount += wordCharsNeeded;
							wordIndex++;
						}
						else
						{
							var remaining = text.length - charCount;
							if (j > 0 && remaining > 0)
							{
								lineDisplayText += " ";
								remaining--;
							}
							if (remaining > 0)
							{
								lineDisplayText += word.substring(0, remaining);
							}
							charCount = text.length;
							break;
						}
					}
				}

				dialogueLines[i].text = lineDisplayText;
				dialogueLines[i].visible = (lineDisplayText.length > 0);
			}
			else
			{
				dialogueLines[i].text = "";
				dialogueLines[i].visible = false;
			}
		}
	}
}
