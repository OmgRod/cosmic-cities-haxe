package states;

import flixel.FlxG;
import flixel.FlxState;
import haxe.io.Path;
import manager.MusicManager;
import ui.backgrounds.Starfield;

class GameState extends FlxState
{
    override public function create():Void
    {
        super.create();

        var starfield = new Starfield();
        add(starfield);

        MusicManager.stopMusic();
    }
}
