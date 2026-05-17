// Bullet.mc — Active projectile entity

import Toybox.Lang;
using WristDungeon as C;

class Bullet {

    var x      as Float;
    var y      as Float;
    var dx     as Float;
    var dy     as Float;
    var active as Boolean = true;

    function initialize(startX as Float, startY as Float, angle as Number) {
        x  = startX;
        y  = startY;
        dx = C.cosTable[angle] * C.BULLET_SPEED;
        dy = C.sinTable[angle] * C.BULLET_SPEED;
    }

    // Advance bullet position; deactivate on wall or enemy hit
    function update() as Void {
        if (!active) { return; }
        var gs  = GameState.get();
        var map = gs.map as GameMap;

        x += dx;
        y += dy;

        // Wall collision
        if (map.isWall(x.toNumber(), y.toNumber())) {
            active = false;
            gs.markDirty();
            return;
        }

        // Enemy collision
        for (var i = 0; i < C.MAX_ENEMIES; i++) {
            var en = gs.enemies[i];
            if (en == null) { continue; }
            if ((en as Enemy).hp <= 0) { continue; }
            if ((en as Enemy).checkBulletHit(x, y)) {
                (en as Enemy).hp -= 30;
                if ((en as Enemy).hp <= 0) {
                    gs.score += C.KILL_SCORE;
                }
                active = false;
                gs.markDirty();
                return;
            }
        }

        gs.markDirty();
    }

    // Returns true if bullet is within the 8-tile rendering range of the player
    function inViewRange(px as Float, py as Float) as Boolean {
        var dx2 = x - px;
        var dy2 = y - py;
        return (dx2 * dx2 + dy2 * dy2) < 64.0f;  // 8² tiles
    }

}
