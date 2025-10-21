package modding;

import haxe.ds.StringMap;

class ModHooks
{
	private static inline var CORE_OWNER_ID = "core";

	private static var hooks:StringMap<Array<HookEntry>> = new StringMap();
	private static var nextHandle:Int = 0;
	private static var orderCounter:Int = 0;

	public static function register(event:String, callback:ModHookContext->Void, ?priority:Int = 0, ?ownerId:String):String
	{
		if (event == null || callback == null)
		{
			return null;
		}

		var normalized = event.toLowerCase();
		var list = ensureList(normalized);

		var handle = allocateHandle(normalized, ownerId);
		var entry:HookEntry = {
			handle: handle,
			ownerId: ownerId != null ? ownerId : CORE_OWNER_ID,
			priority: priority,
			order: orderCounter++,
			callback: callback
		};

		var insertIndex = list.length;
		for (i in 0...list.length)
		{
			var candidate = list[i];
			if (priority > candidate.priority || (priority == candidate.priority && entry.order < candidate.order))
			{
				insertIndex = i;
				break;
			}
		}
		list.insert(insertIndex, entry);
		return handle;
	}

	public static function remove(handle:String):Bool
	{
		if (handle == null)
		{
			return false;
		}
		for (event in hooks.keys())
		{
			var list = hooks.get(event);
			if (list == null)
				continue;
			for (i in 0...list.length)
			{
				if (list[i].handle == handle)
				{
					list.splice(i, 1);
					if (list.length == 0)
					{
						hooks.remove(event);
					}
					return true;
				}
			}
		}
		return false;
	}

	public static function removeHooksForOwner(ownerId:String):Void
	{
		if (ownerId == null)
		{
			return;
		}
		for (event in hooks.keys())
		{
			var list = hooks.get(event);
			if (list == null)
				continue;
			var filtered = list.filter(function(entry) return entry.ownerId != ownerId);
			if (filtered.length == 0)
			{
				hooks.remove(event);
			}
			else if (filtered.length != list.length)
			{
				hooks.set(event, filtered);
			}
		}
	}

	public static function removeHooksForOwnerAndEvent(ownerId:String, event:String):Void
	{
		if (ownerId == null || event == null)
		{
			return;
		}
		var normalized = event.toLowerCase();
		var list = hooks.get(normalized);
		if (list == null)
		{
			return;
		}
		var filtered = list.filter(function(entry) return entry.ownerId != ownerId);
		if (filtered.length == 0)
		{
			hooks.remove(normalized);
		}
		else if (filtered.length != list.length)
		{
			hooks.set(normalized, filtered);
		}
	}

	public static function clearModHooks():Void
	{
		for (event in hooks.keys())
		{
			var list = hooks.get(event);
			if (list == null)
				continue;
			var filtered = list.filter(function(entry) return entry.ownerId == CORE_OWNER_ID);
			if (filtered.length == 0)
			{
				hooks.remove(event);
			}
			else if (filtered.length != list.length)
			{
				hooks.set(event, filtered);
			}
		}
	}

	public static function run(event:String, context:ModHookContext):Void
	{
		if (event == null || context == null)
		{
			return;
		}
		var normalized = event.toLowerCase();
		var list = hooks.get(normalized);
		if (list == null || list.length == 0)
		{
			return;
		}
		var snapshot = list.copy();
		context.cancelled = false;
		for (entry in snapshot)
		{
			context.activeModId = entry.ownerId;
			try
			{
				entry.callback(context);
			}
			catch (e:Dynamic)
			{
				trace("[ModHooks] Error in hook '" + normalized + "' owned by " + entry.ownerId + ": " + e);
			}
			if (context.cancelled)
			{
				break;
			}
		}
		context.activeModId = null;
	}

	public static function hasHooks(event:String):Bool
	{
		if (event == null)
		{
			return false;
		}
		var normalized = event.toLowerCase();
		var list = hooks.get(normalized);
		return list != null && list.length > 0;
	}

	private static function ensureList(event:String):Array<HookEntry>
	{
		var list = hooks.get(event);
		if (list == null)
		{
			list = [];
			hooks.set(event, list);
		}
		return list;
	}

	private static function allocateHandle(event:String, ownerId:String):String
	{
		var owner = ownerId != null ? ownerId : CORE_OWNER_ID;
		return owner + ":" + event + ":" + (nextHandle++);
	}
}

private typedef HookEntry =
{
	var handle:String;
	var ownerId:String;
	var priority:Int;
	var order:Int;
	var callback:ModHookContext->Void;
}
