package modding;

class ScriptHookAPI
{
	final modId:String;

	public function new(modId:String)
	{
		this.modId = modId;
	}

	public function register(event:String, callback:ModHookContext->Void, ?priority:Int = 0):String
	{
		return ModHooks.register(event, callback, priority, modId);
	}

	public function remove(handle:String):Bool
	{
		return ModHooks.remove(handle);
	}

	public function removeAll(event:String):Void
	{
		ModHooks.removeHooksForOwnerAndEvent(modId, event);
	}

	public function clear():Void
	{
		ModHooks.removeHooksForOwner(modId);
	}

	public function run(event:String, ?payload:Dynamic):Void
	{
		var context = new ModHookContext(null, payload);
		ModHooks.run(event, context);
	}
}
