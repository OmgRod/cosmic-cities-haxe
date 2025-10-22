package modding;

import flixel.FlxState;

class ModState extends FlxState
{
	public var stateId:String;
	public var fireHooks:Bool = true;

	public function new(?stateId:String)
	{
		super();
		this.stateId = stateId != null ? stateId : Type.getClassName(Type.getClass(this));
	}

	override public function create():Void
	{
		if (fireHooks)
		{
			var ctx = new ModHookContext(null, {
				state: this,
				stateId: stateId,
				stateClass: Type.getClassName(Type.getClass(this))
			});
			ModHooks.run(ModHookEvents.STATE_CREATE_PRE, ctx);
		}

		super.create();

		if (fireHooks)
		{
			var ctx = new ModHookContext(null, {
				state: this,
				stateId: stateId,
				stateClass: Type.getClassName(Type.getClass(this))
			});
			ModHooks.run(ModHookEvents.STATE_CREATE_POST, ctx);
		}
	}

	override public function update(elapsed:Float):Void
	{
		if (fireHooks)
		{
			var ctx = new ModHookContext(null, {
				state: this,
				stateId: stateId,
				stateClass: Type.getClassName(Type.getClass(this)),
				elapsed: elapsed
			});
			ModHooks.run(ModHookEvents.STATE_UPDATE_PRE, ctx);
		}

		super.update(elapsed);

		if (fireHooks)
		{
			var ctx = new ModHookContext(null, {
				state: this,
				stateId: stateId,
				stateClass: Type.getClassName(Type.getClass(this)),
				elapsed: elapsed
			});
			ModHooks.run(ModHookEvents.STATE_UPDATE_POST, ctx);
		}
	}

	override public function draw():Void
	{
		if (fireHooks)
		{
			var ctx = new ModHookContext(null, {
				state: this,
				stateId: stateId,
				stateClass: Type.getClassName(Type.getClass(this))
			});
			ModHooks.run(ModHookEvents.STATE_DRAW_PRE, ctx);
		}

		super.draw();

		if (fireHooks)
		{
			var ctx = new ModHookContext(null, {
				state: this,
				stateId: stateId,
				stateClass: Type.getClassName(Type.getClass(this))
			});
			ModHooks.run(ModHookEvents.STATE_DRAW_POST, ctx);
		}
	}

	override public function destroy():Void
	{
		if (fireHooks)
		{
			var ctx = new ModHookContext(null, {
				state: this,
				stateId: stateId,
				stateClass: Type.getClassName(Type.getClass(this))
			});
			ModHooks.run(ModHookEvents.STATE_DESTROY_PRE, ctx);
		}

		super.destroy();

		if (fireHooks)
		{
			var ctx = new ModHookContext(null, {
				state: this,
				stateId: stateId,
				stateClass: Type.getClassName(Type.getClass(this))
			});
			ModHooks.run(ModHookEvents.STATE_DESTROY_POST, ctx);
		}
	}
}
