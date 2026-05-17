// GameState.mc — Singleton game state shared across views

import Toybox.Lang;
using WristDungeon as C;

class GameState {

    // ── Singleton ──────────────────────────────────────────────────────────
    static var instance as GameState?;

    static function get() as GameState {
        if (instance == null) {
            instance = new GameState();
        }
        return instance as GameState;
    }

    // ── State fields ───────────────────────────────────────────────────────
    var mode        as Number  = C.MODE_MENU;
    var score       as Number  = 0;
    var level       as Number  = 1;
    var tick        as Number  = 0;
    var needsRedraw as Boolean = true;
    var showMinimap as Boolean = false;

    // Live game objects (set up when a game starts)
    var player      as Player?;
    var enemies     as Array<Enemy?> = new Array<Enemy?>[C.MAX_ENEMIES];
    var bullets     as Array<Bullet?> = new Array<Bullet?>[C.MAX_BULLETS];
    var map         as GameMap?;

    function initialize() {
        _clearArrays();
    }

    // ── Reset for new game / new level ────────────────────────────────────
    function resetGame() as Void {
        score  = 0;
        level  = 1;
        tick   = 0;
        needsRedraw = true;
        showMinimap = false;
        loadLevel(1);
    }

    function loadLevel(lvl as Number) as Void {
        level = lvl;
        tick  = 0;
        map   = new GameMap(lvl);
        _clearArrays();
        _spawnEntities();
        needsRedraw = true;
    }

    // ── Mark dirty ────────────────────────────────────────────────────────
    function markDirty() as Void {
        needsRedraw = true;
    }

    // ── Private ───────────────────────────────────────────────────────────
    hidden function _clearArrays() as Void {
        for (var i = 0; i < C.MAX_ENEMIES; i++) { enemies[i] = null; }
        for (var i = 0; i < C.MAX_BULLETS; i++) { bullets[i] = null; }
    }

    hidden function _spawnEntities() as Void {
        var m = map as GameMap;

        // Let the map parse its grid and fill enemies/player
        var entities = m.getEntities();

        // Player
        player = entities[:player] as Player;

        // Enemies (up to MAX_ENEMIES)
        var enemyList = entities[:enemies] as Array<Enemy?>;
        var count = enemyList.size() < C.MAX_ENEMIES ? enemyList.size() : C.MAX_ENEMIES;
        for (var i = 0; i < count; i++) {
            enemies[i] = enemyList[i];
        }
    }

}
