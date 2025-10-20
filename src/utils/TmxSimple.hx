package utils;

import flixel.tile.FlxTilemap;
#if sys
import sys.io.File;
#end
#if js
import openfl.utils.Assets;
#end

typedef TmxLoadResult = {
    var layers:Array<FlxTilemap>;
    var pixelWidth:Int;
    var pixelHeight:Int;
    var tileWidth:Int;
    var tileHeight:Int;
    var mapWidth:Int;
    var mapHeight:Int;
    var hitboxes:Array<{x:Float, y:Float, width:Float, height:Float}>;
	var roomSwaps:Array<
		{
			x:Float,
			y:Float,
			width:Float,
			height:Float,
			roomFilename:String,
			targetX:Float,
			targetY:Float
		}>;
}

class TmxSimple {
    public static function load(tmxPath:String, tilesetGraphic:String):TmxLoadResult {
        var layers:Array<FlxTilemap> = [];
        var mapW = 0, mapH = 0, tileW = 0, tileH = 0;
        var firstGid = 1;
		var hitboxes:Array<
			{
				x:Float,
				y:Float,
				width:Float,
				height:Float
			}> = [];
		var roomSwaps:Array<
			{
				x:Float,
				y:Float,
				width:Float,
				height:Float,
				roomFilename:String,
				targetX:Float,
				targetY:Float
			}> = [];
        #if sys
        var xmlString = File.getContent(tmxPath);
		#elseif js
		var xmlString = Assets.getText(tmxPath);
		#end

		#if (sys || js)
        var doc = Xml.parse(xmlString);
        var root = doc.firstElement();
        if (root == null || root.nodeName != "map") {
            throw 'Invalid TMX: root <map> not found in ' + tmxPath;
        }
		var wStr = root.get("width");
		var hStr = root.get("height");
		var twStr = root.get("tilewidth");
		var thStr = root.get("tileheight");
		trace("TMX attributes: width=" + wStr + " height=" + hStr + " tilewidth=" + twStr + " tileheight=" + thStr);
		var parsedW = Std.parseInt(wStr);
		var parsedH = Std.parseInt(hStr);
		var parsedTW = Std.parseInt(twStr);
		var parsedTH = Std.parseInt(thStr);
		mapW = (parsedW != null) ? parsedW : 0;
		mapH = (parsedH != null) ? parsedH : 0;
		tileW = (parsedTW != null) ? parsedTW : 64;
		tileH = (parsedTH != null) ? parsedTH : 64;

        
        for (ts in root.elements()) {
            if (ts.nodeName == "tileset") {
                var fg = ts.get("firstgid");
				if (fg != null && fg != "")
				{
					var parsedFg = Std.parseInt(fg);
					if (parsedFg != null)
						firstGid = parsedFg;
				}
                break;
            }
        }

        for (layer in root.elements()) {
            if (layer.nodeName != "layer") continue;
            var dataNode:Xml = null;
            for (node in layer.elements()) {
                if (node.nodeName == "data") { dataNode = node; break; }
            }
            if (dataNode == null) continue;

            var encoding = dataNode.get("encoding");

            var csv:String = null;
            var hasChunks = false;
            for (child in dataNode.elements()) {
                if (child.nodeName == "chunk") { hasChunks = true; break; }
            }

            if (hasChunks) {
                var grid = [for (_ in 0...(mapW * mapH)) 0];
				trace("Grid size: " + grid.length + " (mapW=" + mapW + " mapH=" + mapH + ")");
                for (chunk in dataNode.elements()) {
                    if (chunk.nodeName != "chunk") continue;
					var cxParsed = Std.parseInt(chunk.get("x"));
					var cyParsed = Std.parseInt(chunk.get("y"));
					var cwParsed = Std.parseInt(chunk.get("width"));
					var chParsed = Std.parseInt(chunk.get("height"));
					var cx = (cxParsed != null) ? cxParsed : 0;
					var cy = (cyParsed != null) ? cyParsed : 0;
					var cw = (cwParsed != null) ? cwParsed : 0;
					var ch = (chParsed != null) ? chParsed : 0;
					trace("Processing chunk: cx=" + cx + " cy=" + cy + " cw=" + cw + " ch=" + ch);
                    var chunkText = getInnerText(chunk);
                    var rows = chunkText.split("\n");
                    var ry = 0;
                    for (row in rows) {
                        var r = StringTools.trim(row);
                        if (r.length == 0) continue;
                        var vals = r.split(",");
                        for (rx in 0...vals.length) {
                            var vStr = StringTools.trim(vals[rx]);
							if (vStr == "" || vStr == "null")
								vStr = "0";
							var parsed = Std.parseInt(vStr);
							if (parsed == null)
								parsed = 0;
							var v = convertGid(parsed, firstGid);
                            var gx = cx + rx;
                            var gy = cy + ry;
                            if (gx >= 0 && gx < mapW && gy >= 0 && gy < mapH) {
                                grid[gy * mapW + gx] = v;
                            }
                        }
                        ry++;
                        if (ry >= ch) break;
                    }
                }
                csv = gridToCSV(grid, mapW, mapH);
            } else {
                
                var content = StringTools.trim(getInnerText(dataNode));
                var rows = content.split("\n");
                var out = new StringBuf();
                for (ry in 0...rows.length) {
                    var row = StringTools.trim(rows[ry]);
                    if (row.length == 0) {
                        if (ry < rows.length - 1) out.add("\n");
                        continue;
                    }
                    var vals = row.split(",");
                    for (rx in 0...vals.length) {
                        var vStr = StringTools.trim(vals[rx]);
						if (vStr == "")
							continue;
						if (vStr == "null")
							vStr = "0";
						var parsed = Std.parseInt(vStr);
						if (parsed == null)
							parsed = 0;
						var v = convertGid(parsed, firstGid);
						var vString = Std.string(v);
						if (vString == "null")
							vString = "0";
						out.add(vString);
                        if (rx < vals.length - 1) out.add(",");
                    }
                    if (ry < rows.length - 1) out.add("\n");
                }
                csv = out.toString();
            }

            if (csv != null) {
				trace("CSV PREVIEW: " + csv.substr(0, 500));
                var tilemap = new FlxTilemap();
                tilemap.loadMapFromCSV(csv, tilesetGraphic, tileW, tileH);
                tilemap.immovable = true;
                layers.push(tilemap);
            }
        }

        
        for (objGroup in root.elements()) {
            if (objGroup.nodeName != "objectgroup") continue;
            var groupName = objGroup.get("name");
            if (groupName == "Hitboxes") {
				trace("Found Hitboxes objectgroup");
				var hitboxCount = 0;
                for (obj in objGroup.elements()) {
                    if (obj.nodeName != "object") continue;
					var xStr = obj.get("x");
					var yStr = obj.get("y");
					var wStr = obj.get("width");
					var hStr = obj.get("height");

					if (wStr == null || hStr == null || wStr == "" || hStr == "")
					{
						trace("Skipping object without width/height (likely a point object)");
						continue;
					}

					var ox = Std.parseFloat(xStr);
					var oy = Std.parseFloat(yStr);
					var ow = Std.parseFloat(wStr);
					var oh = Std.parseFloat(hStr);
					
					if (Math.isNaN(ox) || Math.isNaN(oy) || Math.isNaN(ow) || Math.isNaN(oh))
					{
						trace("Warning: Skipping hitbox with NaN values - x:" + ox + " y:" + oy + " w:" + ow + " h:" + oh);
						continue;
					}
					if (ow <= 0 || oh <= 0)
					{
						trace("Warning: Skipping hitbox with invalid dimensions - w:" + ow + " h:" + oh);
						continue;
					}
                    
                    hitboxes.push({x: ox, y: oy, width: ow, height: oh});
					hitboxCount++;
				}
				trace("Loaded " + hitboxCount + " hitboxes");
			}
			else if (groupName == "RoomSwap")
			{
				for (obj in objGroup.elements())
				{
					if (obj.nodeName != "object")
						continue;
					var ox = Std.parseFloat(obj.get("x"));
					var oy = Std.parseFloat(obj.get("y"));
					var ow = Std.parseFloat(obj.get("width"));
					var oh = Std.parseFloat(obj.get("height"));
					var roomFilename = "";
					var targetX = 0.0;
					var targetY = 0.0;
					for (propGroup in obj.elements())
					{
						if (propGroup.nodeName == "properties")
						{
							for (prop in propGroup.elements())
							{
								if (prop.nodeName != "property")
									continue;
								var pname = prop.get("name");
								var pval = prop.get("value");
								if (pname == "RoomFilename")
									roomFilename = pval;
								else if (pname == "targetX")
									targetX = Std.parseFloat(pval);
								else if (pname == "targetY")
									targetY = Std.parseFloat(pval);
							}
						}
					}
					roomSwaps.push({
						x: ox,
						y: oy,
						width: ow,
						height: oh,
						roomFilename: roomFilename,
						targetX: targetX,
						targetY: targetY
					});
				}
            }
        }
        #end
        return {
            layers: layers,
            pixelWidth: mapW * tileW,
            pixelHeight: mapH * tileH,
            tileWidth: tileW,
            tileHeight: tileH,
            mapWidth: mapW,
            mapHeight: mapH,
			hitboxes: hitboxes,
			roomSwaps: roomSwaps
        };
    }

    static function getInnerText(x:Xml):String {
        var sb = new StringBuf();
        for (n in x) {
            if (n.nodeType == Xml.PCData || n.nodeType == Xml.CData) {
                sb.add(n.nodeValue);
            }
        }
        return sb.toString();
    }

    static function gridToCSV(grid:Array<Int>, w:Int, h:Int):String {
		trace("gridToCSV called: w=" + w + " h=" + h + " gridLen=" + grid.length);
        var sb = new StringBuf();
        for (y in 0...h) {
            for (x in 0...w) {
				var idx = y * w + x;
				var val = (idx < grid.length) ? grid[idx] : 0;
				var valStr = Std.string(val);
				if (valStr == "null")
					valStr = "0";
				sb.add(valStr);
                if (x < w - 1) sb.add(",");
            }
            if (y < h - 1) sb.add("\n");
        }
		var result = sb.toString();
		result = StringTools.rtrim(result);
		trace("gridToCSV complete, result length=" + result.length + " (after trim)");
		return result;
    }

    
    
    static function convertGid(gid:Int, firstGid:Int):Int {
        if (gid == 0) return 0;
        var FLIPPED_HORIZONTALLY_FLAG = 0x80000000;
        var FLIPPED_VERTICALLY_FLAG   = 0x40000000;
        var FLIPPED_DIAGONALLY_FLAG   = 0x20000000;
        var clean = gid & ~(FLIPPED_HORIZONTALLY_FLAG | FLIPPED_VERTICALLY_FLAG | FLIPPED_DIAGONALLY_FLAG);
        var index = clean - firstGid; 
        if (index < 0) index = 0;
        return index;
    }
}
