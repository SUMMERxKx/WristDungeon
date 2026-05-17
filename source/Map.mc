// Map.mc — Level grid management: wall detection, entity spawning, item pickup

import Toybox.Lang;
using WristDungeon as C;

class GameMap {

    var width  as Number;
    var height as Number;

    // Grid stored as flat integer array: 0=floor, 1=wall
    hidden var _grid as Array<Number>;

    // Item arrays: ammo and health pack positions
    var ammoItems   as Array<Array<Number>>;
    var healthItems as Array<Array<Number>>;

    // Raw string rows — parsed once
    hidden var _rows    as Array<String>;
    hidden var _playerX as Float = 1.5f;
    hidden var _playerY as Float = 1.5f;
    hidden var _enemyStarts as Array<Array<Float>>;

    function initialize(level as Number) {
        ammoItems   = [] as Array<Array<Number>>;
        healthItems = [] as Array<Array<Number>>;
        _enemyStarts = [] as Array<Array<Float>>;

        if (level == 1) {
            _rows  = C.MAP_1;
            width  = C.MAP_1_W;
            height = C.MAP_1_H;
        } else if (level == 2) {
            _rows  = C.MAP_2;
            width  = C.MAP_2_W;
            height = C.MAP_2_H;
        } else {
            _rows  = C.MAP_3;
            width  = C.MAP_3_W;
            height = C.MAP_3_H;
        }

        _grid = new Array<Number>[width * height];
        _parseGrid();
    }

    // Returns true if tile (tx, ty) is a wall or out of bounds
    function isWall(tx as Number, ty as Number) as Boolean {
        if (tx < 0 || ty < 0 || tx >= width || ty >= height) { return true; }
        return _grid[ty * width + tx] == 1;
    }

    // Returns a Dictionary with :player (Player) and :enemies (Array<Enemy?>)
    function getEntities() as Dictionary {
        var p = new Player(_playerX, _playerY, 0);

        var enemyArr = new Array<Enemy?>[_enemyStarts.size()];
        for (var i = 0; i < _enemyStarts.size(); i++) {
            var pos = _enemyStarts[i];
            enemyArr[i] = new Enemy(pos[0], pos[1]);
        }

        return { :player => p, :enemies => enemyArr };
    }

    // Consumes an ammo item at tile (tx, ty) if present; returns amount or 0
    function pickupAmmo(tx as Number, ty as Number) as Number {
        for (var i = 0; i < ammoItems.size(); i++) {
            var item = ammoItems[i];
            if (item[0] == tx && item[1] == ty) {
                ammoItems = _removeAt(ammoItems, i);
                return C.AMMO_PICKUP;
            }
        }
        return 0;
    }

    // Consumes a health item at tile (tx, ty) if present; returns amount or 0
    function pickupHealth(tx as Number, ty as Number) as Number {
        for (var i = 0; i < healthItems.size(); i++) {
            var item = healthItems[i];
            if (item[0] == tx && item[1] == ty) {
                healthItems = _removeAt(healthItems, i);
                return C.HEALTH_PICKUP;
            }
        }
        return 0;
    }

    // Check if player is standing on items and apply pickups
    function checkPickups(p as Player) as Void {
        var tx = p.x.toNumber();
        var ty = p.y.toNumber();
        var a = pickupAmmo(tx, ty);
        if (a > 0) { p.ammo += a; GameState.get().markDirty(); }
        var h = pickupHealth(tx, ty);
        if (h > 0) {
            p.hp += h;
            if (p.hp > C.PLAYER_START_HP) { p.hp = C.PLAYER_START_HP; }
            GameState.get().markDirty();
        }
    }

    // ── Private ──────────────────────────────────────────────────────────────
    hidden function _parseGrid() as Void {
        for (var row = 0; row < height; row++) {
            var rowStr = _rows[row];
            for (var col = 0; col < width; col++) {
                var ch = rowStr.substring(col, col + 1);
                if (ch.equals("1")) {
                    _grid[row * width + col] = 1;
                } else {
                    _grid[row * width + col] = 0;
                    if (ch.equals("P")) {
                        _playerX = col.toFloat() + 0.5f;
                        _playerY = row.toFloat() + 0.5f;
                    } else if (ch.equals("E")) {
                        _enemyStarts.add([col.toFloat() + 0.5f, row.toFloat() + 0.5f]);
                    } else if (ch.equals("A")) {
                        ammoItems.add([col, row]);
                    } else if (ch.equals("H")) {
                        healthItems.add([col, row]);
                    }
                }
            }
        }
    }

    hidden function _removeAt(arr as Array, idx as Number) as Array {
        var out = [] as Array;
        for (var i = 0; i < arr.size(); i++) {
            if (i != idx) { out.add(arr[i]); }
        }
        return out;
    }

}
