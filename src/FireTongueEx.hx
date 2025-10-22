import firetongue.FireTongue;
import flixel.addons.ui.interfaces.IFireTongue;
import managers.ModManager;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class FireTongueEx extends FireTongue implements IFireTongue
{
	var modOverlay:Map<String, String> = new Map();

	public function new()
	{
		super();
	}
	override public function get(flag:String, context:String = "data", safe:Bool = true):String
	{
		if (modOverlay.exists(flag))
		{
			return modOverlay.get(flag);
		}

		return super.get(flag, context, safe);
	}

	public function reloadModLocales(lang:String):Void
	{
		modOverlay.clear();
		#if (sys && desktop)
		var modman = ModManager.getInstance();
		for (modId in modman.getEnabledMods())
		{
			var base = modman.getModPath(modId);
			if (base == null)
				continue;
			var dir = base + "/assets/locales/" + lang;
			if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir))
				continue;

			try
			{
				var entries = FileSystem.readDirectory(dir);
				for (e in entries)
				{
					if (!StringTools.endsWith(e, ".csv"))
						continue;
					var content = File.getContent(dir + "/" + e);
					parseTwoColCsv(content, modOverlay);
				}
			}
			catch (e:Dynamic)
			{
				trace('[Locales] Error loading mod locales for ' + modId + ': ' + e);
			}
		}
		#end
	}

	static function parseTwoColCsv(text:String, out:Map<String, String>):Void
	{
		if (text == null)
			return;
		var lines = text.split("\n");
		for (line in lines)
		{
			if (line == null)
				continue;
			if (line.length > 0 && line.charAt(line.length - 1) == "\r")
				line = line.substr(0, line.length - 1);
			var trimmed = StringTools.trim(line);
			if (trimmed.length == 0)
				continue;
			if (StringTools.startsWith(trimmed, "\"flag\""))
				continue;
			if (trimmed.charAt(0) != '"')
				continue;
			var i = 1;
			var key = readQuoted(trimmed, i);
			if (key == null)
				continue;
			i = key.endIndex;
			var comma = trimmed.indexOf(",", i);
			if (comma == -1)
				continue;
			var j = comma + 1;
			while (j < trimmed.length && StringTools.isSpace(trimmed, j))
				j++;
			if (j >= trimmed.length || trimmed.charAt(j) != '"')
				continue;
			j++;
			var val = readQuoted(trimmed, j);
			if (val == null)
				continue;
			var k = key.value;
			var v = val.value;
			if (k != null && v != null)
			{
				out.set(k, v);
			}
		}
	}

	static function readQuoted(s:String, start:Int):{value:String, endIndex:Int}
	{
		var buf = new StringBuf();
		var i = start;
		while (i < s.length)
		{
			var c = s.charAt(i);
			if (c == '"')
			{
				if (i + 1 < s.length && s.charAt(i + 1) == '"')
				{
					buf.add('"');
					i += 2;
					continue;
				}
				i++;
				return {value: buf.toString(), endIndex: i};
			}
			buf.add(c);
			i++;
		}
		return null;
	}
}