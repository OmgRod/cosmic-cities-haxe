package managers;

import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import haxe.ds.StringMap;

class MusicManager
{
	static var sources:StringMap<FlxSound> = new StringMap();
	static var currentId:String = null;

	public static function load(id:String, filepath:String, loop:Bool = false):Void
	{
		if (sources.exists(id))
		{
			var old = sources.get(id);
			old.stop();
			sources.remove(id);
		}
		var sound = new FlxSound();
		sound.loadStream(filepath, loop);
		sources.set(id, sound);
	}

	public static function play(id:String):Bool
	{
		var sound = sources.get(id);
		if (sound == null)
			return false;
		currentId = id;
		sound.play();
		return true;
	}

	public static function stop(id:String):Void
	{
		var sound = sources.get(id);
		if (sound != null)
		{
			sound.stop();
			if (currentId == id)
				currentId = null;
		}
	}

	public static function pause(id:String):Void
	{
		var sound = sources.get(id);
		if (sound != null && sound.playing)
		{
			sound.pause();
		}
	}

	public static function resume(id:String):Void
	{
		var sound = sources.get(id);
		if (sound != null && !sound.playing)
		{
			sound.play();
        }
    }

	public static function fadeOutAndStop(id:String, duration:Float):Void
	{
		var sound = sources.get(id);
		if (sound == null)
			return;

		FlxTween.tween(sound, {volume: 0.0}, duration, (({
			onComplete: function():Void
			{
				sound.stop();
				if (currentId == id)
					currentId = null;
			}
		}) : Dynamic));
	}

	public static function fadeToVolume(id:String, target:Float, duration:Float):Void
	{
		var sound = sources.get(id);
		if (sound == null)
			return;

		trace('[MUSIC] fadeToVolume start id='
			+ id
			+ ' from='
			+ Std.string(sound.volume)
			+ ' target='
			+ Std.string(target)
			+ ' dur='
			+ Std.string(duration));
		FlxTween.tween(sound, {volume: target}, duration, (({
			onComplete: function():Void
			{
				// ensure final volume applied
				sound.volume = target;
				trace('[MUSIC] fadeToVolume complete id=' + id + ' finalVol=' + Std.string(sound.volume));
				if (target <= 0.001)
				{
					sound.stop();
					if (currentId == id)
						currentId = null;
				}
			}
		}) : Dynamic));
	}

	public static function pauseAll():Void
	{
		if (currentId != null)
		{
			var sound = sources.get(currentId);
			if (sound != null && sound.playing)
			{
				sound.pause();
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
				sound.play();
			}
		}
	}

	public static function isPlaying(id:String):Bool
	{
		var sound = sources.get(id);
		return sound != null && sound.playing;
    }

	public static function getCurrent():String
	{
		return currentId;
	}

	public static function setGlobalVolume(vol:Float):Void
	{
		for (id in sources.keys())
		{
			var snd = sources.get(id);
			if (snd != null)
			{
				snd.volume = vol;
			}
		}
	}
}
