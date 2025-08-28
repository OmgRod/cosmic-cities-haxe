package states;

import flixel.FlxState;
import ui.backgrounds.Starfield;
import utils.BMFont;

class CreditsState extends FlxState
{
    override public function create()
    {
        var starfield = new Starfield();
        add(starfield);

        var font1 = new BMFont("assets/fonts/pixel_operator.fnt", "assets/fonts/pixel_operator.png").getFont();
    }
}