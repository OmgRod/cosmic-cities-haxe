package manager;

import flixel.sound.FlxSound;

class MusicManager
{
    public static var music:FlxSound;

    public static function playIntroMusic():Void
    {
        if (music == null)
        {
            music = new FlxSound();
            music.loadStream("assets/sounds/music.intro.wav", true);
            music.volume = 0.5;
            music.play();
        }
        else if (!music.playing)
        {
            music.play();
        }
    }

    public static function stopMusic():Void
    {
        if (music != null && music.playing)
            music.stop();
    }

    public static function pauseMusic():Void
    {
        if (music != null && music.playing)
            music.pause();
    }
}
