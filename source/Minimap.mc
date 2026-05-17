// Minimap.mc — Optional 40×40 pixel overlay minimap

import Toybox.Graphics;
import Toybox.Lang;
using WristDungeon as C;

class Minimap {

    function initialize() {
    }

    // Draw the minimap overlay in bottom-right corner of viewport
    function draw(dc as Graphics.Dc) as Void {
        var gs     = GameState.get();
        var map    = gs.map as GameMap;
        var player = gs.player as Player;

        var originX = C.SCREEN_W - C.MINIMAP_SIZE - 4;
        var originY = 4;
        var tileW   = C.MINIMAP_TILE;

        // Background
        dc.setColor(C.COLOR_MINIMAP_BG, C.COLOR_MINIMAP_BG);
        dc.fillRectangle(originX - 1, originY - 1, C.MINIMAP_SIZE + 2, C.MINIMAP_SIZE + 2);

        // Tiles — only draw visible portion (centred on player)
        var visR = C.MINIMAP_SIZE / tileW / 2;   // tiles visible in each direction
        var cx   = player.x.toNumber();
        var cy   = player.y.toNumber();

        for (var row = cy - visR; row <= cy + visR; row++) {
            for (var col = cx - visR; col <= cx + visR; col++) {
                var px = originX + (col - cx + visR) * tileW;
                var py = originY + (row - cy + visR) * tileW;
                if (map.isWall(col, row)) {
                    dc.setColor(C.COLOR_MINIMAP_WALL, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(C.COLOR_MINIMAP_FLOOR, Graphics.COLOR_TRANSPARENT);
                }
                dc.fillRectangle(px, py, tileW, tileW);
            }
        }

        // Enemies
        for (var i = 0; i < C.MAX_ENEMIES; i++) {
            var en = gs.enemies[i];
            if (en == null || (en as Enemy).hp <= 0) { continue; }
            var e  = en as Enemy;
            var ex = (originX + (e.x.toNumber() - cx + visR) * tileW).toNumber();
            var ey = (originY + (e.y.toNumber() - cy + visR) * tileW).toNumber();
            if (ex >= originX && ex < originX + C.MINIMAP_SIZE &&
                ey >= originY && ey < originY + C.MINIMAP_SIZE) {
                dc.setColor(C.COLOR_MINIMAP_ENEMY, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(ex, ey, tileW, tileW);
            }
        }

        // Player dot (center)
        var pdx = originX + visR * tileW;
        var pdy = originY + visR * tileW;
        dc.setColor(C.COLOR_MINIMAP_PLAYER, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(pdx, pdy, tileW, tileW);

        // Direction indicator (1-pixel line)
        var dx = (C.cosTable[player.angle] * 3.0f).toNumber();
        var dy = (C.sinTable[player.angle] * 3.0f).toNumber();
        dc.setColor(C.COLOR_CROSSHAIR, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(pdx + 1, pdy + 1, pdx + 1 + dx, pdy + 1 + dy);
    }

}
