package modding;

import flixel.FlxState;
import flixel.FlxBasic;

class ModHookContext
{
	public var state:FlxState;
	public var payload:Dynamic;
	public var cancelled:Bool = false;
	public var activeModId(default, null):String;

	public function new(state:FlxState, ?payload:Dynamic)
	{
		this.state = state;
		this.payload = payload;
	}

	public inline function add(object:FlxBasic):Void
	{
		if (state != null && object != null)
		{
			state.add(object);
		}
	}

	public inline function setPayload(value:Dynamic):Void
	{
		payload = value;
	}

	public inline function getPayload():Dynamic
	{
		return payload;
	}
}
