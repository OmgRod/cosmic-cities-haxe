package states;

import firetongue.FireTongue;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxBar;
import manager.MusicManager;
import openfl.Assets;
import states.MainMenuState;
import ui.backgrounds.Starfield;
import utils.BMFont;
#if cpp
import cpp.ConstCharStar;
import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end

class LoadingState extends FlxState
{
    var progressBar:FlxBar;
    var loadingStep:Int = 0;
	var statusText:FlxBitmapText;

	override public function create()
    {
        super.create();

        var starfield = new Starfield();
        add(starfield);

        progressBar = new FlxBar(FlxG.width / 2 - 150, FlxG.height / 2 - 10, null, 300, 20, null, "", 0, 4, false);
        progressBar.createFilledBar(0xFF222222, 0xFF00CCFF, false);
        progressBar.value = 0;
        add(progressBar);

		var font = new BMFont("assets/fonts/pixel_operator.fnt", "assets/fonts/pixel_operator.png").getFont();

        statusText = new FlxBitmapText(0, 0, "", font);
        statusText.color = 0xFFFFFFFF;
        statusText.scale.set(1, 1);
        statusText.x = (FlxG.width - statusText.width * statusText.scale.x) / 2;
		statusText.y = progressBar.y + progressBar.height + 4;
		add(statusText);
        
        runNextStep();
    }

    function runNextStep():Void
    {
        switch (loadingStep)
        {
			case 0:
				updateStatus(Main.tongue.get("$LOADING_INIT_DC_RPC", "ui"));
				initDiscordRpc(() ->
				{
					loadingStep++;
					runNextStep();
				});

			case 1:
				updateStatus(Main.tongue.get("$LOADING_LD_ASSETS", "ui"));
				MusicManager.load("intro", "assets/sounds/music.intro.wav", true);
				MusicManager.load("intro.old", "assets/sounds/music.intro.old.wav", true);

				loadingStep++;
                runNextStep();

			// case 2:
			//     updateStatus("Loading data...");
			// 	Assets.getText("assets/maps/ship-main.tmx");
			// 	Assets.getText("assets/maps/ship-cockpit.tmx");
			// 	Assets.getText("assets/maps/ship-stairs.tmx");
			// 	Assets.getText("assets/maps/ship-topfloor.tmx");
			//     loadingStep++;
			//     runNextStep();

			// case 3:
			//     updateStatus("Finalizing...");
			//     loadingStep++;
			//     runNextStep();

			case 2: // 4
				updateStatus(Main.tongue.get("$LOADING_DONE", "ui"));
                progressBar.value = 4;
				FlxG.switchState(() -> new MainMenuState());
        }

        progressBar.value = loadingStep;
    }

    function updateStatus(text:String):Void
    {
        statusText.text = text;
        statusText.x = (FlxG.width - statusText.width * statusText.scale.x) / 2;
    }

    function initDiscordRpc(done:Void->Void):Void
    {
		#if cpp
        final handlers:DiscordEventHandlers = new DiscordEventHandlers();
        handlers.ready = Function.fromStaticFunction(onReady);
        handlers.disconnected = Function.fromStaticFunction(onDisconnected);
        handlers.errored = Function.fromStaticFunction(onError);
		Discord.Initialize("1392251941349757110", RawPointer.addressOf(handlers), false, null);
		#end

        done();
    }

	#if cpp
    static function onReady(request:RawConstPointer<DiscordUser>):Void
    {
        final discordPresence = new DiscordRichPresence();
        discordPresence.largeImageText = "Cosmic Cities";
        discordPresence.state = "Loading...";
        discordPresence.largeImageKey = "logo";

        Discord.UpdatePresence(RawConstPointer.addressOf(discordPresence));
    }

    static function onDisconnected(errorCode:Int, message:ConstCharStar):Void
    {
        Sys.println('Discord RPC: Disconnected ($errorCode:$message)');
    }

    static function onError(errorCode:Int, message:ConstCharStar):Void
    {
        Sys.println('Discord RPC: Error ($errorCode:$message)');
    }
	#end
}
