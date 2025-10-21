// Example mod hooks - demonstrate removing logo and adding custom text

Hooks.register(Events.MAINMENU_CREATE_POST, function(ctx)
{
    var payload = ctx.payload;
    if (payload == null || payload.logo == null)
    {
        trace("MainMenu payload or logo not available");
        return;
    }

    // Remove the logo
    var logo = payload.logo;
    logo.visible = false;
    trace("Logo hidden by example-mod");

    // Add custom text in place of the logo
    var hiText = new FlxBitmapText();
    hiText.text = "hi";
    hiText.color = FlxColor.CYAN;
    hiText.scale.set(4, 4);
    hiText.x = (FlxG.width - hiText.width * 4) / 2;
    hiText.y = 64;
    ctx.add(hiText);
    trace("Added 'hi' text to main menu");
});
