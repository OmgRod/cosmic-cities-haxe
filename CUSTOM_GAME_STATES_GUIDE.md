# Custom Game States Guide

This guide explains how to create custom game states in mods without modifying the main game code.

## Overview

Custom game states allow mods to create completely new screens/levels/menus that work independently from the main game. The mod system provides:

1. **ModState** - A base class that custom states extend
2. **ModStateRegistry** - A registry for custom states
3. **Generic State Hooks** - Lifecycle hooks that fire for all states

## Creating a Custom State

### Step 1: Create the State Class

Create a `.hx` file in your mod's `classes/` directory:

```haxe
// mods/your-mod/classes/MyCustomState.hx
import modding.ModState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MyCustomState extends ModState
{
    public function new()
    {
        super("your-mod:my-custom-state"); // Unique ID for your state
    }
    
    override public function create():Void
    {
        super.create(); // IMPORTANT: Call super to fire hooks
        
        // Your initialization code
        FlxG.camera.bgColor = FlxColor.BLUE;
        
        var text = new FlxText(0, 0, FlxG.width, "My Custom State!", 32);
        text.alignment = CENTER;
        add(text);
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed); // IMPORTANT: Call super to fire hooks
        
        // Your update code
        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new MainMenuState());
        }
    }
}
```

### Step 2: Enable Compilation

Edit `Project.xml` to include your mod's classes directory:

```xml
<source path="mods/your-mod/classes" if="desktop" />
```

### Step 3: Register the State

Create a script to register your state:

```haxe
// mods/your-mod/scripts/my_custom_state.hx

// Load the class dynamically
var MyCustomStateClass = Type.resolveClass("MyCustomState");

if (MyCustomStateClass != null) {
    ModStateRegistry.register("your-mod:my-custom-state", MyCustomStateClass);
    trace("Custom state registered!");
}
```

### Step 4: Switch to the State

You can switch to your custom state in several ways:

**From a script:**
```haxe
ModStateRegistry.switchTo("your-mod:my-custom-state");
```

**From a button hook:**
```haxe
Hooks.register(Events.MAINMENU_CREATE_POST, function(ctx) {
    var button = new TextButton(x, y, "My State", font, 150, 40);
    button.setCallback(function() {
        ModStateRegistry.switchTo("your-mod:my-custom-state");
    });
    ctx.payload.buttonGroup.add(button);
});
```

**From compiled Haxe code:**
```haxe
FlxG.switchState(new MyCustomState());
```

## Generic State Hooks

When your state extends `ModState`, it automatically fires these hooks:

- `STATE_CREATE_PRE` - Before state.create()
- `STATE_CREATE_POST` - After state.create()
- `STATE_UPDATE_PRE` - Before state.update()
- `STATE_UPDATE_POST` - After state.update()
- `STATE_DRAW_PRE` - Before state.draw()
- `STATE_DRAW_POST` - After state.draw()
- `STATE_DESTROY_PRE` - Before state.destroy()
- `STATE_DESTROY_POST` - After state.destroy()

### Hook Payload

Each hook receives a payload with:
- `state` - The state instance
- `stateId` - The unique ID you set in the constructor
- `stateClass` - The class name
- `elapsed` - The delta time (for update hooks only)

### Listening to State Hooks

Other mods can listen to your state's lifecycle:

```haxe
Hooks.register(Events.STATE_CREATE_POST, function(ctx) {
    if (ctx.payload.stateId == "your-mod:my-custom-state") {
        trace("Custom state was created!");
        // Modify the state
        ctx.payload.state.bgColor = FlxColor.RED;
    }
});
```

## Benefits of ModState

### 1. No Main Game Modification
Your custom states exist entirely in your mod. No need to edit core game files.

### 2. Hook Integration
Other mods can interact with your states through the generic state hooks.

### 3. Clean Separation
States are clearly identified by their `stateId`, making it easy to target specific states.

### 4. Dynamic Loading
States are loaded at runtime using `Type.resolveClass()`, so they're only compiled when needed.

## Complete Example

See `mods/example-mod/classes/CustomGameState.hx` and `mods/example-mod/scripts/custom_game_state.hx` for a complete working example.

## Advanced: Controlling Hooks

If you don't want automatic hooks, set `fireHooks = false`:

```haxe
class MyQuietState extends ModState
{
    public function new()
    {
        super("my-quiet-state");
        fireHooks = false; // Won't trigger generic state hooks
    }
}
```

## ModStateRegistry API

```haxe
// Register a state
ModStateRegistry.register("mod-id:state-name", StateClass);

// Unregister a state
ModStateRegistry.unregister("mod-id:state-name");

// Check if registered
if (ModStateRegistry.exists("mod-id:state-name")) { }

// Get the class
var stateClass = ModStateRegistry.get("mod-id:state-name");

// Switch to state
ModStateRegistry.switchTo("mod-id:state-name");

// List all registered states
var states = ModStateRegistry.listStates();

// Clear all registered states
ModStateRegistry.clear();
```

## Best Practices

1. **Always call super** in create(), update(), draw(), and destroy()
2. **Use unique IDs** - prefix with your mod ID: "my-mod:my-state"
3. **Handle ESC key** - let users return to main menu
4. **Test thoroughly** - custom states run outside the main game's state machine
5. **Document your states** - tell other mod authors what your states do

## Troubleshooting

**State class not found:**
- Make sure `<source path>` is in Project.xml
- Verify the class file exists in `mods/your-mod/classes/`
- Check that the class name matches the filename

**Hooks not firing:**
- Ensure you're calling `super.create()`, `super.update()`, etc.
- Check that `fireHooks` is true (default)
- Verify the state extends `ModState`

**Can't switch to state:**
- Verify the state is registered with `ModStateRegistry.exists()`
- Check the state ID matches exactly
- Look for errors in the console
