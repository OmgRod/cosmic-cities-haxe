package states;

import flixel.FlxState;
import manager.MusicManager;
import ui.backgrounds.Starfield;

class GameState extends FlxState
{
	override public function create()
    {
        super.create();

        var starfield = new Starfield();
        add(starfield);

		MusicManager.stop("intro");
    }
}
