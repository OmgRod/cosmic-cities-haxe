package utils;

import flixel.addons.api.FlxNewgrounds;
import haxe.Timer;

class NGHelper
{
	public static var enabled(default, null):Bool = true;
	public static var initialized(default, null):Bool = false;
	public static var ready(default, null):Bool = false;
	public static var username(default, null):Null<String> = null;
	public static var lastError(default, null):Null<String> = null;

	static var medalQueue:Array<Int> = [];
	static var retryMap:haxe.ds.IntMap<Int> = new haxe.ds.IntMap<Int>();
	static var maxMedalRetries:Int = 5;

	/**
	 * Initializes the Newgrounds API with your app ID and AES key.
	 */
	public static function init(appId:String, aesKey:String):Void
	{
		if (initialized)
			return;

		trace("[NGHelper] Initializing Newgrounds API...");

		try
		{
			FlxNewgrounds.onReady = function()
			{
				trace("[NGHelper] Newgrounds connected!");
				ready = true;
				username = null; // could be retrieved later when user login added
				flushMedalQueue();
			};

			FlxNewgrounds.onError = function(msg:String)
			{
				lastError = msg;
				trace("[NGHelper] Error: " + msg);
			};

			FlxNewgrounds.onMedalUnlocked = function(medal)
			{
				trace("[NGHelper] Medal unlocked: " + medal.name);
			};

			FlxNewgrounds.init(appId, aesKey);
			initialized = true;
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			trace("[NGHelper] Init exception: " + lastError);
		}
	}

	/**
	 * Unlocks a medal by ID. If the API isn't ready yet, it will queue it automatically.
	 */
	public static function unlockMedal(id:Int):Void
	{
		if (!initialized)
		{
			trace("[NGHelper] Not initialized — queuing medal " + id);
			medalQueue.push(id);
			return;
		}

		if (!ready)
		{
			trace("[NGHelper] API not ready yet — queuing medal " + id);
			medalQueue.push(id);
			return;
		}

		if (FlxNewgrounds.isMedalUnlocked(id))
		{
			trace("[NGHelper] Medal " + id + " already unlocked, skipping.");
			return;
		}

		trace("[NGHelper] Unlocking medal " + id + "...");
		try
		{
			FlxNewgrounds.unlockMedal(id);
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			trace("[NGHelper] Unlock failed — queued for retry: " + lastError);
			queueRetry(id);
		}
	}

	/**
	 * Flushes queued medal unlock requests.
	 */
	static function flushMedalQueue():Void
	{
		if (medalQueue.length == 0)
			return;

		trace("[NGHelper] Flushing medal queue (" + medalQueue.length + " items)...");
		var pending = medalQueue.copy();
		medalQueue = [];

		for (id in pending)
		{
			try
			{
				if (!FlxNewgrounds.isMedalUnlocked(id))
				{
					FlxNewgrounds.unlockMedal(id);
					trace("[NGHelper] Medal " + id + " unlocked via queue.");
				}
				else
				{
					trace("[NGHelper] Medal " + id + " already unlocked (queue skip).");
				}
			}
			catch (e:Dynamic)
			{
				lastError = Std.string(e);
				trace("[NGHelper] Medal " + id + " failed in flush: " + lastError);
				queueRetry(id);
			}
		}

		if (medalQueue.length > 0)
		{
			trace("[NGHelper] Re-flushing queued medals after delay...");
			Timer.delay(flushMedalQueue, 1000);
		}
	}

	static function queueRetry(id:Int):Void
	{
		var tries = retryMap.exists(id) ? retryMap.get(id) : 0;
		tries++;

		if (tries < maxMedalRetries)
		{
			retryMap.set(id, tries);
			medalQueue.push(id);
			trace("[NGHelper] Medal " + id + " scheduled for retry (attempt #" + tries + ")");
			Timer.delay(flushMedalQueue, 1000);
		}
		else
		{
			trace("[NGHelper] Medal " + id + " reached max retries (" + tries + "), giving up.");
		}
	}

	/**
	 * Posts a score to a Newgrounds scoreboard.
	 */
	public static function postScore(boardId:String, value:Int):Void
	{
		if (!initialized || !ready)
		{
			trace("[NGHelper] Cannot post score yet — API not ready.");
			return;
		}

		try
		{
			trace("[NGHelper] Posting score: " + value + " to board " + boardId);
			FlxNewgrounds.postScore(boardId, value);
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			trace("[NGHelper] Score post error: " + lastError);
		}
	}

	/**
	 * Utility: manually trigger flush (if you want to force it).
	 */
	public static function flush():Void
	{
		flushMedalQueue();
	}
}
