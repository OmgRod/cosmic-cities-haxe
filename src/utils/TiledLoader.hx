package utils;

import flixel.FlxG;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

class TiledLoader {
    public static function loadMap(tmxPath:String, tilesetImagePath:String):{ group:FlxGroup, layers:Array<FlxTilemap> } {
        var group = new FlxGroup();
        var layers:Array<FlxTilemap> = [];

        var tmap = new TiledMap(tmxPath);
        var tileW = tmap.tileWidth;
        var tileH = tmap.tileHeight;

        for (l in tmap.layers) {
            var tl = cast(l, TiledLayer);
            if (tl == null || tl.data == null) continue;
            var tilemap = new FlxTilemap();
            tilemap.loadMapFromArray(tl.data, tmap.fullWidth, tmap.fullHeight, tilesetImagePath, tileW, tileH, FlxTilemap.OFF, 0, 1, 1);
            tilemap.immovable = true;
            tilemap.scrollFactor.set(1, 1);
            group.add(tilemap);
            layers.push(tilemap);
        }

        return { group: group, layers: layers };
    }
}
