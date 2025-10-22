# Custom Game States - What Was Added

## Summary

Added support for creating completely custom game states in mods without modifying the main game code. Custom states can be compiled classes that extend `ModState` and participate in a generic hook system.

## New Files

### Core System
- **src/modding/ModState.hx** - Base class for custom states with automatic hook firing
- **CUSTOM_GAME_STATES_GUIDE.md** - Complete documentation for creating custom states

### Example Implementation
- **mods/example-mod/classes/CustomGameState.hx** - Example custom state with sprite rendering and back button
- **mods/example-mod/scripts/custom_game_state.hx** - Script that registers the state and adds a menu button

## Modified Files

### src/modding/ModHookEvents.hx
Added 8 new generic state lifecycle hooks:
- `STATE_CREATE_PRE` / `STATE_CREATE_POST`
- `STATE_UPDATE_PRE` / `STATE_UPDATE_POST`
- `STATE_DRAW_PRE` / `STATE_DRAW_POST`
- `STATE_DESTROY_PRE` / `STATE_DESTROY_POST`

### src/modding/ModScriptBindings.hx
- Added all 8 new state hooks to the Events object
- Exposed `ModState` class to scripts

### mods/example-mod/mod.json
- Added `custom_game_state.hx` to scripts array

## How It Works

### 1. ModState Base Class
Custom states extend `ModState` instead of `FlxState`. The base class automatically:
- Fires generic state hooks at lifecycle points
- Stores a unique `stateId` for identification
- Allows toggling hook firing via `fireHooks` property

### 2. Generic State Hooks
Unlike specific hooks (MAINMENU_CREATE_POST, etc.), generic state hooks fire for ANY state that extends ModState. This allows:
- Mods to create custom states
- Other mods to interact with those custom states
- Universal state monitoring/modification

### 3. Dynamic Registration
States are registered using `Type.resolveClass()`, which:
- Loads compiled classes at runtime
- Only compiles when source path is enabled
- Allows mods to add states without main game changes

## Example Usage

### Creating a Custom State

```haxe
// mods/my-mod/classes/MyState.hx
import modding.ModState;
import flixel.FlxG;

class MyState extends ModState {
    public function new() {
        super("my-mod:my-state");
    }
    
    override public function create():Void {
        super.create(); // Fires STATE_CREATE hooks
        // Your code here
    }
}
```

### Registering It

```haxe
// mods/my-mod/scripts/register.hx
var StateClass = Type.resolveClass("MyState");
ModStateRegistry.register("my-mod:my-state", StateClass);
```

### Switching To It

```haxe
ModStateRegistry.switchTo("my-mod:my-state");
```

### Listening to Its Hooks

```haxe
Hooks.register(Events.STATE_CREATE_POST, function(ctx) {
    if (ctx.payload.stateId == "my-mod:my-state") {
        trace("My state was created!");
    }
});
```

## Benefits

1. **No Core Modification** - Custom states exist entirely in mods
2. **Hook Integration** - States participate in the hook system
3. **Mod Interoperability** - Other mods can interact with custom states
4. **Clean Separation** - States are identified by unique IDs
5. **Optional Compilation** - Only compiled when enabled

## Testing

To test the example:

1. Ensure `Project.xml` has: `<source path="mods/example-mod/classes" if="desktop" />`
2. Build and run the game
3. Look for "CUSTOM STATE" button in main menu
4. Click it to see the custom state with rotating sprite
5. Press ESC or Back button to return

## Hook Payload Structure

All generic state hooks receive:
```haxe
{
    state: FlxState,        // The state instance
    stateId: String,        // Unique ID (e.g., "example-mod:custom-game-state")
    stateClass: String,     // Class name (e.g., "CustomGameState")
    elapsed: Float          // Delta time (UPDATE hooks only)
}
```

## Migration Notes

Existing states can be converted to use hooks by:
1. Extending `ModState` instead of `FlxState`
2. Passing a unique ID to `super()` in constructor
3. Ensuring `super.create()`, `super.update()`, etc. are called

States that don't extend `ModState` won't fire generic hooks, maintaining backward compatibility.
