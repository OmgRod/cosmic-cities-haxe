package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import ui.SplashTextData;

class SplashText extends FlxGroup {
    public var text:FlxBitmapText;
    var baseScale:Float = 1.0;
    var maxWidth:Float;
    var maxHeight:Float;
    var logo:FlxSprite;
    var animTime:Float = 0.0;
	var centerX:Float = 0.0;
	var centerY:Float = 0.0;
	var rotatedBboxW:Float = 0.0;
	var rotatedBboxH:Float = 0.0;

    public function new(logo:FlxSprite, font:Dynamic) {
        super();
        this.logo = logo;
        var splash = SplashTextData.splashes[Std.random(SplashTextData.splashes.length)];
        text = new FlxBitmapText(0, 0, splash, font);
        text.color = 0xFFFFFF00;
        text.angle = -35;
        text.active = false;
		text.antialiasing = false;
		text.scrollFactor.set(0, 0);
        add(text);
        maxWidth = FlxG.width * 0.65;
        maxHeight = FlxG.height * 0.18;
        autoScale();
        positionRelativeToLogo();
    }

    function autoScale() {
		this.text.scale.set(1, 1);
		this.text.updateHitbox();
		var scale = 1.0;
		var radians = Math.abs(this.text.angle) * Math.PI / 180;
		var cosA = Math.cos(radians);
		var sinA = Math.sin(radians);
		var w = this.text.textWidth;
		var h = this.text.textHeight;

		var bboxW = Math.abs(w * cosA) + Math.abs(h * sinA);
		var bboxH = Math.abs(w * sinA) + Math.abs(h * cosA);
		if (bboxW > this.maxWidth)
			scale = this.maxWidth / bboxW;
		if (bboxH * scale > this.maxHeight)
			scale = this.maxHeight / bboxH;

		scale = Math.round(scale * 100) / 100;
		this.text.scale.set(scale, scale);
		this.text.updateHitbox();
		this.baseScale = scale;
		this.text.origin.set(this.text.width * 0.5, this.text.height * 0.5);

		this.rotatedBboxW = Math.abs(this.text.textWidth * cosA) + Math.abs(this.text.textHeight * sinA);
		this.rotatedBboxH = Math.abs(this.text.textWidth * sinA) + Math.abs(this.text.textHeight * cosA);
    }

    function positionRelativeToLogo() {
		var margin = 10;
		var maxGrowthScale = this.baseScale * 1.08;

		var radians = Math.abs(this.text.angle) * Math.PI / 180;
		var cosA = Math.cos(radians);
		var sinA = Math.sin(radians);

		var maxGrowthBboxW = this.rotatedBboxW * (maxGrowthScale / this.baseScale);
		var maxGrowthBboxH = this.rotatedBboxH * (maxGrowthScale / this.baseScale);

		var logoBottom = this.logo.y + this.logo.height;
		var py = logoBottom;

		var px = FlxG.width - margin - (maxGrowthBboxW / 2);

		if (py - maxGrowthBboxH * 0.5 < margin)
			py = margin + maxGrowthBboxH * 0.5;
		if (py + maxGrowthBboxH * 0.5 > FlxG.height - margin)
			py = FlxG.height - margin - maxGrowthBboxH * 0.5;

		this.centerX = px;
		this.centerY = py;

		this.text.scale.set(this.baseScale, this.baseScale);
		this.text.x = this.centerX;
		this.text.y = this.centerY;
    }

    override function update(elapsed:Float):Void {
        this.animTime += elapsed;
        var s = 1 + 0.08 * Math.sin(this.animTime * 2.5);
		this.text.scale.set(this.baseScale * s, this.baseScale * s);
    }
}