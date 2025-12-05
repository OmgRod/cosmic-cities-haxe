package managers;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import haxe.ds.StringMap;
import haxe.Timer;

class MusicManager
{
	// maps id -> FlxSound
	static var sources:StringMap<FlxSound> = new StringMap();
	// keep original file paths and loop flags for fallback
	static var paths:StringMap<String> = new StringMap();
	static var loops:StringMap<Bool> = new StringMap();

	static var currentId:String = null;

	public static function load(id:String, filepath:String, loop:Bool = false):Void
	{
		try
		{
			if (sources.exists(id))
			{
				var old = sources.get(id);
				if (old != null)
				{
					try {
						old.stop();
					} catch (_:Dynamic) {}
					sources.remove(id);
				}
			}

			var sound = new FlxSound();
			// store path/loop for fallback
			paths.set(id, filepath);
			loops.set(id, loop);

			try
			{
				sound.loadStream(filepath, loop);
			}
			catch (e:Dynamic)
			{
				trace('[MUSIC] loadStream failed for ' + filepath + ' : ' + e);
			}

			// set initial volume to global volume if available
			try
			{
				if (FlxG != null && FlxG.sound != null)
					sound.volume = FlxG.sound.volume;
			}
			catch (_:Dynamic) {}

			// try to register with FlxG's sound manager so it isn't auto-destroyed unexpectedly
			try
			{
				if (FlxG != null && FlxG.sound != null && FlxG.sound.list != null)
				{
					// FlxTypedGroup uses add() rather than push()
					FlxG.sound.list.add(sound);
					// prevent engine auto-destroying our streaming music
					sound.autoDestroy = false;
				}
			}
			catch (_:Dynamic)
			{
				// ignore registration failure
			}

			sources.set(id, sound);
			trace('[MUSIC] loaded id=' + id + ' path=' + filepath + ' loop=' + Std.string(loop));
		}
		catch (e:Dynamic)
		{
			trace('[MUSIC] load exception for id=' + id + ' : ' + e);
		}
	}

	public static function play(id:String):Bool
	{
		var sound:FlxSound = null;
		try
		{
			sound = sources.get(id);
		}
		catch (_:Dynamic) { }

		if (sound == null)
		{
			// fallback: try FlxG.sound.play with stored path
			var p:String = paths.exists(id) ? paths.get(id) : null;
			var lp:Bool = loops.exists(id) ? loops.get(id) : false;
			if (p != null && FlxG != null && FlxG.sound != null)
			{
				try
				{
					var fb = FlxG.sound.play(p, FlxG.sound.volume, lp);
					trace('[MUSIC] fallback FlxG.sound.play for id=' + id + ' returned=' + Std.string(fb != null));
					if (fb != null) currentId = id;
					return fb != null;
				}
				catch (e:Dynamic)
				{
					trace('[MUSIC] fallback play failed for id=' + id + ' : ' + e);
					return false;
				}
			}
			return false;
		}

			try
			{
				currentId = id;
				var started = false;
				try {
					started = (sound.play() != null);
				} catch (_:Dynamic) {
					try {
						sound.play();
						started = true;
					} catch (_:Dynamic) {
						started = false;
					}
				}
				if (!started)
				{
					// schedule a few retries to account for async stream startup on some platforms
					Timer.delay(function() {
						try {
							sound.play();
						} catch (_:Dynamic) {}
					}, 100);
					Timer.delay(function() {
						try {
							sound.play();
						} catch (_:Dynamic) {}
					}, 300);
					Timer.delay(function() {
						try {
							sound.play();
						} catch (_:Dynamic) {}
					}, 700);
				}
				trace('[MUSIC] play requested id=' + id + ' started=' + Std.string(started));
				return true;
			}
		catch (e:Dynamic)
		{
			trace('[MUSIC] play exception for id=' + id + ' : ' + e);
			return false;
		}
	}

	public static function stop(id:String):Void
	{
		try
		{
			var sound = sources.get(id);
			if (sound != null)
			{
				try {
					sound.stop();
				} catch (_:Dynamic) {}
				if (currentId == id) currentId = null;
			}
		}
		catch (_:Dynamic) {}
	}

	public static function pause(id:String):Void
	{
		try
		{
			var sound = sources.get(id);
			if (sound != null && sound.playing)
				sound.pause();
		}
		catch (_:Dynamic) {}
	}

	public static function resume(id:String):Void
	{
		try
		{
			var sound = sources.get(id);
			if (sound != null && !sound.playing)
				sound.play();
		}
		catch (_:Dynamic) {}
	}

	public static function fadeOutAndStop(id:String, duration:Float):Void
	{
		var sound = sources.get(id);
		if (sound == null) return;

		FlxTween.tween(sound, {volume: 0.0}, duration, (({
			onComplete: function():Void
			{
				try {
					sound.stop();
				} catch (_:Dynamic) {}
				if (currentId == id) currentId = null;
			}
		}) : Dynamic));
	}

	public static function fadeToVolume(id:String, target:Float, duration:Float):Void
	{
		var sound = sources.get(id);
		if (sound == null) return;

		try
		{
			trace('[MUSIC] fadeToVolume start id=' + id + ' from=' + Std.string(sound.volume) + ' target=' + Std.string(target) + ' dur=' + Std.string(duration));
			FlxTween.tween(sound, {volume: target}, duration, (({
				onComplete: function():Void
				{
					try {
						sound.volume = target;
					} catch (_:Dynamic) {}
					trace('[MUSIC] fadeToVolume complete id=' + id + ' finalVol=' + Std.string(sound.volume));
					if (target <= 0.001)
					{
						try {
							sound.stop();
						} catch (_:Dynamic) {}
						if (currentId == id) currentId = null;
					}
				}
			}) : Dynamic));
		}
		catch (e:Dynamic)
		{
			trace('[MUSIC] fadeToVolume exception for id=' + id + ' : ' + e);
		}
	}

	public static function pauseAll():Void
	{
		if (currentId != null)
		{
			var sound = sources.get(currentId);
			if (sound != null && sound.playing)
			{
				try {
					sound.pause();
				} catch (_:Dynamic) {}
			}
		}
	}

	public static function resumeAll():Void
	{
		if (currentId != null)
		{
			var sound = sources.get(currentId);
			if (sound != null && !sound.playing)
			{
				try {
					sound.play();
				} catch (_:Dynamic) {}
			}
		}
	}

	public static function isPlaying(id:String):Bool
	{
		try
		{
			var sound = sources.get(id);
			return sound != null && sound.playing;
		}
		catch (_:Dynamic)
		{
			return false;
		}
	}

	public static function getCurrent():String
	{
		return currentId;
	}

	public static function setGlobalVolume(vol:Float):Void
	{
		try
		{
			if (FlxG != null && FlxG.sound != null)
			{
				FlxG.sound.volume = vol;
				try {
					FlxG.sound.defaultSoundGroup.volume = vol;
				} catch (_:Dynamic) {}
				try {
					if (FlxG.sound.music != null) FlxG.sound.music.volume = vol;
				} catch (_:Dynamic) {}
			}

			for (id in sources.keys())
			{
				try
				{
					var snd = sources.get(id);
					if (snd != null) snd.volume = vol;
				}
				catch (_:Dynamic) {}
			}
		}
		catch (e:Dynamic)
		{
			trace('[MUSIC] setGlobalVolume exception: ' + e);
		}
	}
}
