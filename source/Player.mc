// Player.mc — Player entity: position, angle, health, ammo, movement, shooting

import Toybox.Lang;
import Toybox.Math;
using WristDungeon as C;

class Player {

    var x      as Float;
    var y      as Float;
    var angle  as Number;   // 0–359 degrees (index into lookup tables)
    var hp     as Number  = C.PLAYER_START_HP;
    var ammo   as Number  = C.PLAYER_START_AMMO;

    // Input flags (set by onKey, processed in game loop)
    var movingForward  as Boolean = false;
    var movingBack     as Boolean = false;
    var turningLeft    as Boolean = false;
    var turningRight   as Boolean = false;
    var wantShoot      as Boolean = false;

    function initialize(startX as Float, startY as Float, startAngle as Number) {
        x     = startX;
        y     = startY;
        angle = startAngle;
    }

    // Called every game tick to process movement
    function move() as Void {
        var gs  = GameState.get();
        var map = gs.map as GameMap;

        if (movingForward) {
            _tryMove(x + C.cosTable[angle] * C.PLAYER_SPEED,
                     y + C.sinTable[angle] * C.PLAYER_SPEED, map);
        }
        if (movingBack) {
            _tryMove(x - C.cosTable[angle] * C.PLAYER_SPEED,
                     y - C.sinTable[angle] * C.PLAYER_SPEED, map);
        }
    }

    function turn(delta as Number) as Void {
        angle = (angle + delta + 360) % 360;
    }

    function turnLeft() as Void {
        var deg = (C.PLAYER_TURN_SPEED * (180.0 / Math.PI)).toNumber();
        if (deg < 1) { deg = 3; }
        angle = (angle - deg + 360) % 360;
    }

    function turnRight() as Void {
        var deg = (C.PLAYER_TURN_SPEED * (180.0 / Math.PI)).toNumber();
        if (deg < 1) { deg = 3; }
        angle = (angle + deg) % 360;
    }

    // Attempt to shoot — spawns a bullet if ammo available
    function shoot() as Void {
        if (ammo <= 0) { return; }
        var gs = GameState.get();
        for (var i = 0; i < C.MAX_BULLETS; i++) {
            if (gs.bullets[i] == null) {
                gs.bullets[i] = new Bullet(x, y, angle);
                ammo--;
                gs.markDirty();
                return;
            }
        }
        // All slots full — use hitscan as fallback
        _hitscanShoot(gs);
    }

    // Hitscan: immediate raycast hit test (no bullet object)
    hidden function _hitscanShoot(gs as GameState) as Void {
        if (ammo <= 0) { return; }
        ammo--;
        var map = gs.map as GameMap;
        var step = 0.1f;
        var bx = x + C.cosTable[angle] * 0.5f;
        var by = y + C.sinTable[angle] * 0.5f;
        for (var i = 0; i < 80; i++) {
            bx += C.cosTable[angle] * step;
            by += C.sinTable[angle] * step;
            if (map.isWall(bx.toNumber(), by.toNumber())) { break; }
            // Check enemy hits
            for (var e = 0; e < C.MAX_ENEMIES; e++) {
                var en = gs.enemies[e];
                if (en == null) { continue; }
                if ((en as Enemy).hp <= 0) { continue; }
                var dx = (en as Enemy).x - bx;
                var dy = (en as Enemy).y - by;
                if ((dx * dx + dy * dy) < 0.3f) {
                    (en as Enemy).hp -= 30;
                    if ((en as Enemy).hp <= 0) {
                        gs.score += C.KILL_SCORE;
                    }
                    gs.markDirty();
                    return;
                }
            }
        }
        gs.markDirty();
    }

    function takeDamage(dmg as Number) as Void {
        hp -= dmg;
        if (hp < 0) { hp = 0; }
        GameState.get().markDirty();
    }

    // ── Private ──────────────────────────────────────────────────────────────
    hidden function _tryMove(nx as Float, ny as Float, map as GameMap) as Void {
        var r = C.PLAYER_COLLISION_R;
        if (!map.isWall((nx + r).toNumber(), y.toNumber()) &&
            !map.isWall((nx - r).toNumber(), y.toNumber())) {
            x = nx;
        }
        if (!map.isWall(x.toNumber(), (ny + r).toNumber()) &&
            !map.isWall(x.toNumber(), (ny - r).toNumber())) {
            y = ny;
        }
        GameState.get().markDirty();
    }

}
