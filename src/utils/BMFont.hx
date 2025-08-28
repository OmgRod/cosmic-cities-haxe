package utils;

import flixel.graphics.frames.FlxBitmapFont;
import openfl.Assets;

class BMFont
{
    var font:FlxBitmapFont;

    public function new(fontpath:String, pngpath:String)
    {
        var fontBitmap = Assets.getBitmapData(pngpath);
        var fontData = Assets.getText(fontpath);
        font = FlxBitmapFont.fromAngelCode(fontBitmap, fontData);
        if (font == null)
        {
            throw "Failed to load bitmap font assets!";
        }
    }

    public function getFont():FlxBitmapFont
    {
        return font;
    }
}