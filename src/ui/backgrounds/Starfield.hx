package ui.backgrounds;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

class Starfield extends FlxTypedGroup<FlxSprite>
{
    public var vw:Int;
    public var vh:Int;
    public var starCount:Int = 100;
    public var starSpeed:Float = 2.5;

    var bgColorA:Array<Float> = [0.0, 0.01, 0.015];
    var bgColorB:Array<Float> = [0.015, 0.02, 0.03];
    var bgColor:Array<Float> = [0, 0, 0];

    var bgColorTime:Float = 0;
    var bgColorDuration:Float = 10;
    var twinkleTime:Float = 0;
    var twinkleOffsets:Array<Float> = [];

    public function new(?width:Int, ?height:Int, ?count:Int, ?speed:Float, ?colorA:Array<Float>, ?colorB:Array<Float>, ?duration:Float)
    {
        super();

        vw = width != null ? width : FlxG.width;
        vh = height != null ? height : FlxG.height;

        starCount = count != null ? count : starCount;
        starSpeed = speed != null ? speed : starSpeed;
        if (colorA != null) bgColorA = colorA;
        if (colorB != null) bgColorB = colorB;
        if (duration != null) bgColorDuration = duration;

        for (i in 0...starCount)
        {
            var star = new FlxSprite(FlxG.random.float(0, vw), FlxG.random.float(0, vh));
            star.makeGraphic(1, 1, FlxColor.WHITE);
            star.scale.set(FlxG.random.int(1, 2), FlxG.random.int(1, 2));
            star.scrollFactor.set();
            star.alpha = 1;
            add(star);

            twinkleOffsets.push(FlxG.random.float(0, Math.PI * 2));
        }
    }

    override public function update(dt:Float):Void
    {
        super.update(dt);

        bgColorTime = (bgColorTime + dt) % bgColorDuration;
        twinkleTime += dt;

        for (i in 0...members.length)
        {
            var star = members[i];
            if (star == null) continue;

            star.x -= starSpeed * dt;
            if (star.x < 0)
            {
                star.x = vw;
                star.y = FlxG.random.float(0, vh);
                star.scale.set(FlxG.random.int(1, 2), FlxG.random.int(1, 2));
                twinkleOffsets[i] = FlxG.random.float(0, Math.PI * 2);
            }

            var twinkle = 0.75 + 0.25 * Math.sin(twinkleTime * 4 + twinkleOffsets[i]);
            star.alpha = twinkle;
        }
    }

    public function drawBackground():Void
    {
        var t = bgColorTime / (bgColorDuration / 2);
        if (t > 1) t = 2 - t;

        for (i in 0...3)
            bgColor[i] = bgColorA[i] + (bgColorB[i] - bgColorA[i]) * t;

        FlxG.camera.fill(FlxColor.fromRGBFloat(bgColor[0], bgColor[1], bgColor[2]));
    }
}
