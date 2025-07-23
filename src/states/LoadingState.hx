package states;

import cpp.ConstCharStar;
import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.ui.FlxBar;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import openfl.Assets;
import states.MainMenu;
import sys.thread.Thread;
import ui.backgrounds.Starfield;

class LoadingState extends FlxState
{
    var progressBar:FlxBar;
    var loadingStep:Int = 0;
    var statusText:FlxBitmapText;
    var font:FlxBitmapFont;

    override public function create():Void
    {
        super.create();

        var starfield = new Starfield();
        add(starfield);

        progressBar = new FlxBar(FlxG.width / 2 - 150, FlxG.height / 2 - 10, null, 300, 20, null, "", 0, 4, false);
        progressBar.createFilledBar(0xFF222222, 0xFF00CCFF, false);
        progressBar.value = 0;
        add(progressBar);

        var fontBitmap = Assets.getBitmapData("assets/fonts/pixel_operator.png");
        var fontData = Assets.getText("assets/fonts/pixel_operator.fnt");

        font = FlxBitmapFont.fromAngelCode(fontBitmap, fontData);
        if (font == null)
        {
            throw "Failed to load bitmap font assets!";
        }

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
                updateStatus("Initializing...");
                loadingStep++;
                runNextStep();

            case 1:
                updateStatus("Initializing Discord RPC...");
                initDiscordRpc(() -> {
                    loadingStep++;
                    runNextStep();
                });

            case 2:
                updateStatus("Loading assets...");
                loadingStep++;
                Thread.create(() -> {
                    Sys.sleep(10);
                });
                runNextStep();

            case 3:
                updateStatus("Loading data...");
                loadingStep++;
                runNextStep();

            case 4:
                updateStatus("Finalizing...");
                loadingStep++;
                runNextStep();

            case 5:
                updateStatus("Done!");
                progressBar.value = 4;
                FlxG.switchState(() -> new MainMenu());
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
        final handlers:DiscordEventHandlers = new DiscordEventHandlers();
        handlers.ready = Function.fromStaticFunction(onReady);
        handlers.disconnected = Function.fromStaticFunction(onDisconnected);
        handlers.errored = Function.fromStaticFunction(onError);
        Discord.Initialize("1392251941349757110", RawPointer.addressOf(handlers), false, null);

        Thread.create(() -> {
            while (loadingStep == 1)
            {
                #if DISCORD_DISABLE_IO_THREAD
                Discord.UpdateConnection();
                #end
                Discord.RunCallbacks();
                Sys.sleep(2);
            }
        });

        done();
    }

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
}
