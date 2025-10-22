package utils;

#if js
import haxe.crypto.Base64;
import io.newgrounds.NG;
#end

class NGHelper
{
	public static var enabled(default, null):Bool = #if js true #else false #end;
	public static var initialized(default, null):Bool = false;
	public static var ready(default, null):Bool = false;
	public static var username(default, null):Null<String> = null;
	public static var lastError(default, null):Null<String> = null;

	static var medalQueue:Array<Int> = [];
	static var pollTries:Int = 0;
	static var maxPollTries:Int = 40;
	static var medalRetry:haxe.ds.IntMap<Int> = new haxe.ds.IntMap<Int>();
	static var maxMedalRetries:Int = 10;

	public static function init(appIdAndKey:String, encryptionKey:String):Void
	{
		#if js
		if (initialized) return;

		try {
			trace('[NG] Creating session');
			NG.create(appIdAndKey);
			setupEncryption(encryptionKey);
			initialized = true;
			startPolling();
		} catch (e:Dynamic) {
			lastError = Std.string(e);
			trace('[NG] Init error: ' + lastError);
		}
		#else
		trace('[NG] Skipped init (non-JS build)');
		#end
	}

	public static function initEncoded(appIdAndKey_b64:String, encryptionKey_b64:String):Void
	{
		#if js
		var app:String = null;
		var key:String = null;

		try {
			app = Base64.decode(appIdAndKey_b64).toString();
			key = Base64.decode(encryptionKey_b64).toString();
		} catch (e:Dynamic) {
			lastError = Std.string(e);
			trace('[NG] Base64 decode error: ' + lastError);
		}
		if (app != null && key != null)
			init(app, key);
		#end
	}

	public static function unlockMedal(id:Int):Void
	{
		#if js
		if (!initialized || !ready)
		{
			trace('[NG] Queued medal ' + id + ' (initialized=' + initialized + ' ready=' + ready + ')');
			medalQueue.push(id);
			return;
		}
		try
		{
			trace('[NG] Unlock medal request: ' + id);
			var medalObj:Dynamic = getMedalObject(id);

			if (medalObj == null)
			{
				trace('[NG] Medal object not available for id ' + id + '; queued for retry');
				medalQueue.push(id);
				flushQueue();
				return;
			}
			medalObj.sendUnlock();
			trace('[NG] Unlock sent for medal ' + id);
		} catch (e:Dynamic) {
			lastError = Std.string(e);
			trace('[NG] Unlock error: ' + lastError);
			medalQueue.push(id);
			flushQueue();
		}
		#else
		trace('[NG] Medal ' + id + ' unlock skipped (non-JS build)');
		#end
	}

	static function startPolling():Void
	{
		#if js
		pollTries = 0;
		pollOnce();
		#end
	}
	public static function createAndCheckSession(appIdAndKey:String, backupSession:String = null):Void
	{
		#if js
		try
		{
			if (backupSession != null)
				NG.createAndCheckSession(appIdAndKey, backupSession);
			else
				NG.createAndCheckSession(appIdAndKey, null);
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			trace('[NG] createAndCheckSession error: ' + lastError);
		}
		#end
	}

	public static function requestLogin(callback:Dynamic):Void
	{
		#if js
		try
		{
			if (NG != null && NG.core != null)
				NG.core.requestLogin(callback);
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			trace('[NG] requestLogin error: ' + lastError);
		}
		#end
	}

	public static function setupEncryption(encryptionKey:String, cipher:Dynamic = null, format:Dynamic = null):Void
	{
		#if js
		try
		{
			if (NG != null && NG.core != null)
			{
				if (cipher == null && format == null)
				{
					NG.core.setupEncryption(encryptionKey);
				}
				else if (format == null)
				{
					NG.core.setupEncryption(encryptionKey, cipher);
				}
				else
				{
					NG.core.setupEncryption(encryptionKey, cipher, format);
				}
			}
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			trace('[NG] setupEncryption error: ' + lastError);
		}
		#end
	}

	public static function loadMedals():Void
	{
		#if js
		try
		{
			if (NG != null && NG.core != null && NG.core.medals != null)
			{
				var loadMethod = Reflect.field(NG.core.medals, "loadList");
				var call:Dynamic = loadMethod != null ? Reflect.callMethod(NG.core.medals, loadMethod, []) : null;
				if (call != null)
					Reflect.callMethod(call, Reflect.field(call, "queue"), []);
			}
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			trace('[NG] loadMedals error: ' + lastError);
		}
		#end
	}

	public static function loadScoreboards():Void
	{
		#if js
		try
		{
			if (NG != null && NG.core != null && NG.core.scoreBoards != null)
			{
				var loadMethod = Reflect.field(NG.core.scoreBoards, "loadList");
				var call:Dynamic = loadMethod != null ? Reflect.callMethod(NG.core.scoreBoards, loadMethod, []) : null;
				if (call != null)
					Reflect.callMethod(call, Reflect.field(call, "queue"), []);
			}
		}
		catch (e:Dynamic)
		{
			lastError = Std.string(e);
			trace('[NG] loadScoreboards error: ' + lastError);
		}
		#end
	}


	static function pollOnce():Void
	{
		#if js
		var ok = false;
		try {
			ok = (NG.core != null && NG.core.medals != null);
		} catch (_:Dynamic) {
			ok = false;
		}

		if (ok) {
			ready = true;
			trace('[NG] Ready. Flushing medal queue: ' + medalQueue.length);
			flushQueue();
			return;
		}

		pollTries++;
		if (pollTries >= maxPollTries) {
			trace('[NG] Poll timeout; NG not ready after ' + pollTries + ' tries');
			return;
		}

		haxe.Timer.delay(pollOnce, 500);
		#end
	}

	static function flushQueue():Void
	{
		#if js
		if (medalQueue.length == 0)
			return;

		trace('[NG] Diagnostic: core='
			+ Std.string(NG != null && NG.core != null)
			+ ' medals='
			+ Std.string(NG != null && NG.core != null && NG.core.medals != null));

		var pending = medalQueue.copy();
		medalQueue = [];
		var failed:Array<Int> = [];

		for (id in pending)
		{
			trace('[NG] Processing queued medal ' + id);
			var medalObj:Dynamic = getMedalObject(id);
			if (medalObj == null)
			{
				trace('[NG] Medal object still not available for id ' + id);
				failed.push(id);
				continue;
			}
			try
			{
				medalObj.sendUnlock();
				trace('[NG] Unlock sent for medal ' + id);
			}
			catch (e:Dynamic)
			{
				lastError = Std.string(e);
				trace('[NG] Unlock error while flushing: ' + lastError);
				failed.push(id);
			}
		}

		if (failed.length > 0)
		{
			for (id in failed)
			{
				var tries = medalRetry.exists(id) ? medalRetry.get(id) : 0;
				tries++;
				medalRetry.set(id, tries);

				if (tries < maxMedalRetries)
				{
					medalQueue.push(id);
					trace('[NG] Medal ' + id + ' will retry (attempt #' + tries + ')');
				}
				else
				{
					trace('[NG] Gave up retrying medal ' + id + ' after ' + tries + ' attempts');
				}
			}

			if (medalQueue.length > 0)
				haxe.Timer.delay(flushQueue, 1000);
		}
		#end
	}

	static function getMedalObject(id:Int):Dynamic
	{
		#if js
		try
		{
			if (NG == null || NG.core == null || NG.core.medals == null)
				return null;

			var medals = NG.core.medals;

			try
			{
				var getMethod = Reflect.field(medals, "get");
				if (getMethod != null)
				{
					var res = Reflect.callMethod(medals, getMethod, [id]);
					if (res != null)
						return res;
				}
			}
			catch (_:Dynamic) {}

			try
			{
				var m = Reflect.field(medals, "_map");
				if (m != null)
				{
					trace('[NG] medals._map fields: ' + Std.string(Reflect.fields(m)));
					for (k in Reflect.fields(m))
					{
						var entry = Reflect.field(m, k);
						if (entry == null)
							continue;
						var entryId:Dynamic = null;
						if (Reflect.hasField(entry, "id"))
							entryId = Reflect.field(entry, "id");
						else if (Reflect.hasField(entry, "medal_id"))
							entryId = Reflect.field(entry, "medal_id");
						else if (Reflect.hasField(entry, "medalId"))
							entryId = Reflect.field(entry, "medalId");
						if (entryId != null)
						{
							var nid = Std.parseInt(Std.string(entryId));
							if (nid == id)
								return entry;
						}
					}
				}
			}
			catch (_:Dynamic) {}

			try
			{
				var arrCandidates = ["list", "_list", "items", "_items"];
				for (fname in arrCandidates)
				{
					var arr = Reflect.field(medals, fname);
					if (arr == null)
						continue;
					try
					{
						for (m in cast(arr, Array<Dynamic>))
						{
							if (m == null)
								continue;
							var entryId:Dynamic = null;
							if (Reflect.hasField(m, "id"))
								entryId = Reflect.field(m, "id");
							else if (Reflect.hasField(m, "medal_id"))
								entryId = Reflect.field(m, "medal_id");
							else if (Reflect.hasField(m, "medalId"))
								entryId = Reflect.field(m, "medalId");
							if (entryId != null)
							{
								var nid = Std.parseInt(Std.string(entryId));
								if (nid == id)
									return m;
							}
						}
					}
					catch (_:Dynamic) {}
				}
			}
			catch (_:Dynamic) {}

			trace('[NG] getMedalObject: medal ' + id + ' not found via get/_map/list');
			trace('[NG] medals object fields: ' + Std.string(Reflect.fields(medals)));
		}
		catch (_:Dynamic) {}
		#end
		return null;
	}
}
