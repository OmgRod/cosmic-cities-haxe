package managers;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import haxe.ds.StringMap;
import haxe.Timer;
import openfl.Assets;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.events.Event;
import openfl.events.IOErrorEvent;

class MusicManager
{
	// maps id -> SoundChannel for direct playback
	static var soundChannels:StringMap<SoundChannel> = new StringMap();
	// keep original file paths and loop flags for fallback
	static var paths:StringMap<String> = new StringMap();
	static var loops:StringMap<Bool> = new StringMap();

	static var currentId:String = null;

	public static function load(id:String, filepath:String, loop:Bool = false):Void
	{
		try
		{
			// Just store the path and loop flag - we'll load on-demand when playing
			paths.set(id, filepath);
			loops.set(id, loop);
			trace('[MUSIC] registered id=' + id + ' path=' + filepath + ' loop=' + Std.string(loop));
		}
		catch (e:Dynamic)
		{
			trace('[MUSIC] load exception for id=' + id + ' : ' + e);
		}
	}

	public static function play(id:String):Bool
	{
		try
		{
			// Get the path and loop flag
			var p:String = paths.exists(id) ? paths.get(id) : null;
			var lp:Bool = loops.exists(id) ? loops.get(id) : false;
			
			if (p == null)
			{
				trace('[MUSIC] play failed - id not registered: ' + id);
				return false;
			}

			// If already playing this track, keep it running (avoid restart on state change)
			var existing = soundChannels.get(id);
			if (currentId == id && existing != null)
			{
				// Refresh volume in case settings changed
				var transform = existing.soundTransform;
				transform.volume = FlxG.sound.volume;
				existing.soundTransform = transform;
				trace('[MUSIC] already playing, skipping restart: id=' + id);
				return true;
			}

			// Load music using Assets.getMusic (for streaming music files)
			trace('[MUSIC] loading music: id=' + id + ' path=' + p + ' loop=' + lp);
			trace('[MUSIC] FlxG.sound.volume=' + FlxG.sound.volume + ' muted=' + FlxG.sound.muted);
			
			var sound:Sound = null;
			
			try {
				// Use Assets.getMusic for music files (supports streaming)
				sound = Assets.getMusic(p);
				if (sound == null) {
					trace('[MUSIC] ERROR: Assets.getMusic returned null');
					return false;
				}
				
				// Add event listeners for debugging
				sound.addEventListener(Event.COMPLETE, function(e:Event) {
					trace('[MUSIC] Sound COMPLETE event: ' + id);
				});
				sound.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
					trace('[MUSIC] Sound IO_ERROR: ' + id + ' - ' + e.text);
				});
			}
			catch (e:Dynamic) {
				trace('[MUSIC] ERROR loading assets: ' + e);
				return false;
			}
			
			// Stop current channel only when switching tracks
			var currentChannel = soundChannels.get(currentId);
			if (currentId != null && currentId != id && currentChannel != null) {
				trace('[MUSIC] stopping current channel: ' + currentId);
				currentChannel.stop();
				soundChannels.remove(currentId);
			}
			
			// Play sound directly using Sound.play()
			trace('[MUSIC] calling sound.play() with volume=' + FlxG.sound.volume);
			var channel:SoundChannel = sound.play(0, lp ? 999999 : 0, null);
			
			if (channel != null) {
				soundChannels.set(id, channel);
				currentId = id;
				// Set volume on the channel
				var transform = channel.soundTransform;
				transform.volume = FlxG.sound.volume;
				channel.soundTransform = transform;
				trace('[MUSIC] ✓ Started playing via SoundChannel: id=' + id);
				return true;
			}
			else
			{
				trace('[MUSIC] ERROR: sound.play() returned null');
				return false;
			}
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
			if (currentId == id)
			{
				var ch = soundChannels.get(id);
				if (ch != null)
				{
					ch.stop();
					soundChannels.remove(id);
				}
				currentId = null;
				trace('[MUSIC] stopped id=' + id);
			}
		}
		catch (_:Dynamic) {}
	}

	public static function pause(id:String):Void
	{
		try
		{
			if (currentId == id)
			{
				var ch = soundChannels.get(id);
				if (ch != null)
				{
					ch.stop();
					soundChannels.remove(id);
					trace('[MUSIC] paused id=' + id);
				}
			}
		}
		catch (_:Dynamic) {}
	}

	public static function resume(id:String):Void
	{
		try
		{
			if (currentId == id)
			{
				// Simply replay using play(), which will re-register the channel
				play(id);
				trace('[MUSIC] resumed id=' + id);
			}
		}
		catch (_:Dynamic) {}
	}

	public static function fadeOutAndStop(id:String, duration:Float):Void
	{
		if (currentId != id) return;

		var ch = soundChannels.get(id);
		if (ch == null) return;

		var transform = ch.soundTransform;
		var startVol = transform.volume;
		FlxTween.num(startVol, 0.0, duration, {
			onUpdate: function(t:FlxTween)
			{
				var v = startVol + (0.0 - startVol) * t.percent;
				transform.volume = v;
				ch.soundTransform = transform;
			},
			onComplete: function(t:FlxTween)
			{
				try { ch.stop(); } catch (_:Dynamic) {}
				soundChannels.remove(id);
				if (currentId == id) currentId = null;
			}
		});
	}

	public static function fadeToVolume(id:String, target:Float, duration:Float):Void
	{
		if (currentId != id) return;

		var ch = soundChannels.get(id);
		if (ch == null) return;

		try
		{
			var transform = ch.soundTransform;
			var startVol = transform.volume;
			FlxTween.num(startVol, target, duration, {
				onUpdate: function(t:FlxTween)
				{
					var v = startVol + (target - startVol) * t.percent;
					transform.volume = v;
					ch.soundTransform = transform;
				},
				onComplete: function(t:FlxTween)
				{
					transform.volume = target;
					ch.soundTransform = transform;
					if (target <= 0.001)
					{
						try { ch.stop(); } catch (_:Dynamic) {}
						soundChannels.remove(id);
						if (currentId == id) currentId = null;
					}
				}
			});
		}
		catch (e:Dynamic)
		{
			trace('[MUSIC] fadeToVolume exception for id=' + id + ' : ' + e);
		}
	}

	public static function pauseAll():Void
	{
		try {
			for (id in soundChannels.keys())
			{
				var ch = soundChannels.get(id);
				if (ch != null)
				{
					ch.stop();
				}
			}
			soundChannels = new StringMap();
			if (currentId != null) trace('[MUSIC] paused all');
		} catch (_:Dynamic) {}
	}

	public static function resumeAll():Void
	{
		if (currentId != null)
		{
			try {
				play(currentId);
				trace('[MUSIC] resumed all');
			} catch (_:Dynamic) {}
		}
	}

	public static function isPlaying(id:String):Bool
	{
		try
		{
			return currentId == id && soundChannels.exists(id);
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

			for (id in soundChannels.keys())
			{
				try
				{
					var channel = soundChannels.get(id);
					if (channel != null) {
						var transform = channel.soundTransform;
						transform.volume = vol;
						channel.soundTransform = transform;
					}
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
