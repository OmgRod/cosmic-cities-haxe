package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxBar;
import managers.MusicManager;
import states.MainMenuState;
import ui.backgrounds.Starfield;
import utils.BMFont;
#if (!disable_discord && cpp && !android)
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

		var fontString = Main.tongue.getFontData("pixel_operator", 16).name;
		var font = new BMFont("assets/fonts/" + fontString + "/" + fontString + ".fnt", "assets/fonts/" + fontString + "/" + fontString + ".png").getFont();

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
				#if cpp
				updateStatus(Main.tongue.get("$LOADING_INIT_DC_RPC", "ui"));
				initDiscordRpc(() ->
				{
					loadingStep++;
					runNextStep();
				});
				#else
				loadingStep++;
				runNextStep();
				#end

			case 1:
				updateStatus(Main.tongue.get("$LOADING_LD_ASSETS", "ui"));
				MusicManager.load("intro", "assets/sounds/music.intro.wav", true);
				MusicManager.load("intro.old", "assets/sounds/music.intro.old.wav", true);
				MusicManager.load("geton", "assets/sounds/music.geton.wav", true);
				MusicManager.load("firstencounter", "assets/sounds/music.firstencounter.mp3", false);
				MusicManager.load("roundone", "assets/sounds/music.roundone.mp3", true);

				loadingStep++;
                runNextStep();

			case 2: 
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
		#if (!disable_discord && cpp && !android)
        try {
            final handlers:DiscordEventHandlers = new DiscordEventHandlers();
            handlers.ready = Function.fromStaticFunction(onReady);
            handlers.disconnected = Function.fromStaticFunction(onDisconnected);
            handlers.errored = Function.fromStaticFunction(onError);
            Discord.Initialize("1392251941349757110", RawPointer.addressOf(handlers), false, null);
        } catch (e:Dynamic) {
            Sys.println('Discord RPC initialization failed: $e');
        }
		#end

        done();
    }

	#if (!disable_discord && cpp && !android)
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
