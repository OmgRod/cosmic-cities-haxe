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

    public function new(logo:FlxSprite, font:Dynamic) {
        super();
        this.logo = logo;
        var splash = SplashTextData.splashes[Std.random(SplashTextData.splashes.length)];
        text = new FlxBitmapText(0, 0, splash, font);
        text.color = 0xFFFFFF00;
        text.angle = -35;
        text.active = false;
        text.antialiasing = false;
        text.origin.set(text.width * 0.5, text.height * 0.5);
        add(text);
        maxWidth = FlxG.width * 0.65;
        maxHeight = FlxG.height * 0.18;
        autoScale();
        positionRelativeToLogo();
    }

    function autoScale() {
    this.text.scale.set(1, 1);
    this.text.updateHitbox();
    this.text.origin.set(this.text.width * 0.5, this.text.height * 0.5);
    var scale = 1.0;
    var radians = Math.abs(this.text.angle) * Math.PI / 180;
    var cosA = Math.cos(radians);
    var sinA = Math.sin(radians);
    var w = this.text.textWidth;
    var h = this.text.textHeight;
    var bboxW = Math.abs(w * cosA) + Math.abs(h * sinA);
    var bboxH = Math.abs(w * sinA) + Math.abs(h * cosA);
    if (bboxW > this.maxWidth) scale = this.maxWidth / bboxW;
    if (bboxH * scale > this.maxHeight) scale = this.maxHeight / bboxH;
    scale = Math.round(scale * 100) / 100;
    this.text.scale.set(scale, scale);
    this.text.updateHitbox();
    this.baseScale = scale;
    }

    function positionRelativeToLogo() {
        var margin = 8;
        var offsetX = FlxG.width * 0.18;
        var px = this.logo.x + this.logo.width - this.text.width * 0.5 + offsetX + this.text.origin.x;
        var py = this.logo.y + this.logo.height - this.text.height * 0.5 + this.text.origin.y;
        if (px + this.text.width > FlxG.width - margin) px = FlxG.width - this.text.width - margin;
        if (py + this.text.height > FlxG.height - margin) py = FlxG.height - this.text.height - margin;
        if (px < margin) px = margin;
        if (py < margin) py = margin;
        this.text.x = px;
        this.text.y = py;
    }

    override function update(elapsed:Float):Void {
        this.animTime += elapsed;
        var s = 1 + 0.08 * Math.sin(this.animTime * 2.5);
        this.text.scale.set(this.baseScale * s, this.baseScale * s);
        this.text.updateHitbox();
        this.positionRelativeToLogo();
    }
}