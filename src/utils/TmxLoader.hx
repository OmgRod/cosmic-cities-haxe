package utils;

import flixel.tile.FlxTilemap;
import haxe.xml.Access;
import sys.io.File;

class TmxLoader {
    public static function loadTileLayers(tmxPath:String, tilesetGraphic:String):Array<FlxTilemap> {
        var layers:Array<FlxTilemap> = [];
        #if sys
        var xmlString = File.getContent(tmxPath);
        var xml = Xml.parse(xmlString);
        var x = new Access(xml.firstElement());

        var mapWidth = Std.parseInt(x.att.width);
        var mapHeight = Std.parseInt(x.att.height);
        var tileWidth = Std.parseInt(x.att.tilewidth);
        var tileHeight = Std.parseInt(x.att.tileheight);

        for (layer in x.nodes.layer) {
            var name = layer.att.name;
            var dataNode = layer.node.data;
            if (dataNode == null || dataNode.att.encoding != "csv") continue;

            var csv:String = null;

            
            var chunks = dataNode.nodes.chunk;
            if (chunks.hasNext()) {
                var grid:Array<Int> = [];
                grid.resize(mapWidth * mapHeight);
                for (i in 0...grid.length) grid[i] = 0;

                for (chunk in chunks) {
                    var cx = Std.parseInt(chunk.att.x);
                    var cy = Std.parseInt(chunk.att.y);
                    var cw = Std.parseInt(chunk.att.width);
                    var ch = Std.parseInt(chunk.att.height);
                    var chunkCSV = chunk.innerData.trim();
                    var rows = chunkCSV.split("\n");
                    var rowIndex = 0;
                    for (row in rows) {
                        var rowTrim = StringTools.trim(row);
                        if (rowTrim.length == 0) continue;
                        var vals = rowTrim.split(",");
                        for (colIndex in 0...vals.length) {
                            var vStr = StringTools.trim(vals[colIndex]);
                            if (vStr == "") continue;
                            var v = Std.parseInt(vStr);
                            var gx = cx + colIndex;
                            var gy = cy + rowIndex;
                            if (gx >= 0 && gx < mapWidth && gy >= 0 && gy < mapHeight) {
                                grid[gy * mapWidth + gx] = v;
                            }
                        }
                        rowIndex++;
                    }
                }

                
                var sb = new StringBuf();
                for (ry in 0...mapHeight) {
                    for (rx in 0...mapWidth) {
                        sb.add(grid[ry * mapWidth + rx]);
                        if (rx < mapWidth - 1) sb.add(",");
                    }
                    if (ry < mapHeight - 1) sb.add("\n");
                }
                csv = sb.toString();
            } else {
                
                csv = dataNode.innerData.trim();
            }

            if (csv != null) {
                var tilemap = new FlxTilemap();
                tilemap.loadMapFromCSV(csv, tilesetGraphic, tileWidth, tileHeight, FlxTilemap.OFF, 0, 1, 1);
                tilemap.immovable = true;
                layers.push(tilemap);
            }
        }
        #else
        trace("TMX loading requires sys target");
        #end
        return layers;
    }
}
