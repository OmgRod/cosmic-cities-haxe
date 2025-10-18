package utils;

import flixel.tile.FlxTilemap;
import sys.io.File;

typedef TmxLoadResult = {
    var layers:Array<FlxTilemap>;
    var pixelWidth:Int;
    var pixelHeight:Int;
    var tileWidth:Int;
    var tileHeight:Int;
    var mapWidth:Int;
    var mapHeight:Int;
    var hitboxes:Array<{x:Float, y:Float, width:Float, height:Float}>;
}

class TmxSimple {
    public static function load(tmxPath:String, tilesetGraphic:String):TmxLoadResult {
        var layers:Array<FlxTilemap> = [];
        var mapW = 0, mapH = 0, tileW = 0, tileH = 0;
        var firstGid = 1;
        var hitboxes:Array<{x:Float, y:Float, width:Float, height:Float}> = [];
        #if sys
        var xmlString = File.getContent(tmxPath);
        var doc = Xml.parse(xmlString);
        var root = doc.firstElement();
        if (root == null || root.nodeName != "map") {
            throw 'Invalid TMX: root <map> not found in ' + tmxPath;
        }
        mapW = Std.parseInt(root.get("width"));
        mapH = Std.parseInt(root.get("height"));
        tileW = Std.parseInt(root.get("tilewidth"));
        tileH = Std.parseInt(root.get("tileheight"));

        
        for (ts in root.elements()) {
            if (ts.nodeName == "tileset") {
                var fg = ts.get("firstgid");
                if (fg != null && fg != "") firstGid = Std.parseInt(fg);
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
                for (chunk in dataNode.elements()) {
                    if (chunk.nodeName != "chunk") continue;
                    var cx = Std.parseInt(chunk.get("x"));
                    var cy = Std.parseInt(chunk.get("y"));
                    var cw = Std.parseInt(chunk.get("width"));
                    var ch = Std.parseInt(chunk.get("height"));
                    var chunkText = getInnerText(chunk);
                    var rows = chunkText.split("\n");
                    var ry = 0;
                    for (row in rows) {
                        var r = StringTools.trim(row);
                        if (r.length == 0) continue;
                        var vals = r.split(",");
                        for (rx in 0...vals.length) {
                            var vStr = StringTools.trim(vals[rx]);
                            if (vStr == "") continue;
                            var v = convertGid(Std.parseInt(vStr), firstGid);
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
                        var v = (vStr == "") ? 0 : convertGid(Std.parseInt(vStr), firstGid);
                        out.add(v);
                        if (rx < vals.length - 1) out.add(",");
                    }
                    if (ry < rows.length - 1) out.add("\n");
                }
                csv = out.toString();
            }

            if (csv != null) {
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
                for (obj in objGroup.elements()) {
                    if (obj.nodeName != "object") continue;
                    var ox = Std.parseFloat(obj.get("x"));
                    var oy = Std.parseFloat(obj.get("y"));
                    var ow = Std.parseFloat(obj.get("width"));
                    var oh = Std.parseFloat(obj.get("height"));
                    hitboxes.push({x: ox, y: oy, width: ow, height: oh});
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
            hitboxes: hitboxes
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
        var sb = new StringBuf();
        for (y in 0...h) {
            for (x in 0...w) {
                sb.add(grid[y * w + x]);
                if (x < w - 1) sb.add(",");
            }
            if (y < h - 1) sb.add("\n");
        }
        return sb.toString();
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
