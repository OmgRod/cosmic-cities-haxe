package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.LoadingState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(640, 480, LoadingState));
	}
}
