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
	static var medalRetry:Map<Int, Int> = new Map();
	static var maxMedalRetries:Int = 10;
	
	public static function init(appIdAndKey:String, encryptionKey:String):Void
	{
		#if js
		if (initialized) return;
		try {
			trace('[NG] Creating session');
			NG.create(appIdAndKey);
            NG.core.setupEncryption(encryptionKey, AES_128, BASE_64);
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
		if (app != null && key != null) {
			init(app, key);
		}
		#end
	}

	public static function unlockMedal(id:Int):Void
	{
		#if js
		if (!initialized) {
			trace('[NG] Not initialized; queuing medal ' + id);
			medalQueue.push(id);
			return;
		}
		if (!ready) {
			trace('[NG] Not ready; queuing medal ' + id);
			medalQueue.push(id);
			return;
		}
		try {
			trace('[NG] Unlock medal request: ' + id);
			NG.core.medals.get(id).sendUnlock();
			trace('[NG] Unlock sent for medal ' + id);
		} catch (e:Dynamic) {
			lastError = Std.string(e);
			trace('[NG] Unlock error: ' + lastError);
			if (lastError != null && lastError.indexOf('Key not found') != -1) {
				var tries = medalRetry.exists(id) ? medalRetry.get(id) : 0;
				if (tries < maxMedalRetries) {
					tries++;
					medalRetry.set(id, tries);
					trace('[NG] Medal ' + id + ' not found yet; retry #' + tries + ' in 1000ms');
					haxe.Timer.delay(function() unlockMedal(id), 1000);
					return;
				}
				trace('[NG] Gave up retrying medal ' + id + ' after ' + tries + ' attempts');
			}
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
		while (medalQueue.length > 0) {
			var id = medalQueue.shift();
			unlockMedal(id);
		}
		#end
	}
}
