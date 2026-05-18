// GameView.mc — Main game view: render loop, input delegate, game logic tick

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;
using WristDungeon as C;

// ─────────────────────────────────────────────────────────────────────────────
// GameView — renders the 3D viewport + HUD, holds the Timer
// ─────────────────────────────────────────────────────────────────────────────
class GameView extends WatchUi.View {

    hidden var _raycaster  as Raycaster;
    hidden var _hud        as HUD;
    hidden var _minimap    as Minimap;
    hidden var _timer      as Timer.Timer;
    hidden var _upHoldTick as Number = 0;   // track UP long-press for minimap toggle

    function initialize() {
        View.initialize();
        _raycaster = new Raycaster();
        _hud       = new HUD();
        _minimap   = new Minimap();
        _timer     = new Timer.Timer();
    }

    function onLayout(dc as Graphics.Dc) as Void {
    }

    function onShow() as Void {
        // 10 fps — 100ms per frame
        _timer.start(method(:gameLoop), 100, true);
    }

    function onHide() as Void {
        _timer.stop();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var gs = GameState.get();
        if (gs.mode != C.MODE_GAME) { return; }

        dc.setColor(C.COLOR_BLACK, C.COLOR_BLACK);
        dc.clear();

        _raycaster.renderFrame(dc);
        _hud.drawHUD(dc, gs.player as Player, gs.score, gs.level);

        if (gs.showMinimap) {
            _minimap.draw(dc);
        }

        gs.needsRedraw = false;
    }

    // ── Game loop (called by Timer every 100ms) ───────────────────────────
    function gameLoop() as Void {
        var gs = GameState.get();
        if (gs.mode != C.MODE_GAME) { return; }

        gs.tick++;
        var player = gs.player as Player;
        var map    = gs.map    as GameMap;

        // Process player movement flags
        if (player.turningLeft)  { player.turnLeft(); }
        if (player.turningRight) { player.turnRight(); }
        player.move();

        // Shoot
        if (player.wantShoot) {
            player.wantShoot = false;
            player.shoot();
        }

        // Update bullets
        for (var i = 0; i < C.MAX_BULLETS; i++) {
            var b = gs.bullets[i];
            if (b != null) {
                (b as Bullet).update();
                if (!(b as Bullet).active) { gs.bullets[i] = null; }
            }
        }

        // Update enemies
        for (var i = 0; i < C.MAX_ENEMIES; i++) {
            var en = gs.enemies[i];
            if (en != null && (en as Enemy).hp > 0) {
                (en as Enemy).update();
            }
        }

        // Item pickups
        map.checkPickups(player);

        // Check win: all enemies dead and player alive
        var allDead = true;
        for (var i = 0; i < C.MAX_ENEMIES; i++) {
            var en = gs.enemies[i];
            if (en != null && (en as Enemy).hp > 0) { allDead = false; break; }
        }

        if (player.hp <= 0) {
            _triggerGameOver(gs);
            return;
        }

        if (allDead) {
            if (gs.level < 3) {
                // Advance to next level
                gs.score += C.LEVEL_SCORE;
                gs.loadLevel(gs.level + 1);
            } else {
                _triggerWin(gs);
                return;
            }
        }

        if (gs.needsRedraw) {
            WatchUi.requestUpdate();
        }
    }

    // ── Private transitions ───────────────────────────────────────────────
    hidden function _triggerGameOver(gs as GameState) as Void {
        _timer.stop();
        gs.mode = C.MODE_GAMEOVER;
        var menuView = new MenuView();
        var menuDelegate = new MenuDelegate(menuView);
        WatchUi.pushView(menuView, menuDelegate, WatchUi.SLIDE_DOWN);
    }

    hidden function _triggerWin(gs as GameState) as Void {
        _timer.stop();
        gs.score += C.LEVEL_SCORE;
        gs.mode = C.MODE_WIN;
        var menuView = new MenuView();
        var menuDelegate = new MenuDelegate(menuView);
        WatchUi.pushView(menuView, menuDelegate, WatchUi.SLIDE_UP);
    }

}

// ─────────────────────────────────────────────────────────────────────────────
// GameDelegate — button + touch input during gameplay
// ─────────────────────────────────────────────────────────────────────────────
class GameDelegate extends WatchUi.BehaviorDelegate {

    hidden var _view       as GameView;
    hidden var _upPressed  as Boolean = false;
    hidden var _upHoldMs   as Number  = 0;

    function initialize(view as GameView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var gs     = GameState.get();
        if (gs.mode != C.MODE_GAME) { return false; }
        var player = gs.player as Player;
        var key    = evt.getKey();
        var typ    = evt.getType();

        if (key == WatchUi.KEY_UP) {
            if (typ == WatchUi.PRESS_TYPE_ACTION) {
                player.movingForward = true;
                _upPressed = true;
            } else if (typ == 0) {   // PRESS_TYPE_RELEASE
                player.movingForward = false;
                _upPressed = false;
                _upHoldMs  = 0;
            } else if (typ == 1) {   // PRESS_TYPE_HOLD
                // Long press toggle minimap
                gs.showMinimap = !gs.showMinimap;
                gs.markDirty();
            }
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            if (typ == WatchUi.PRESS_TYPE_ACTION) {
                player.movingBack = true;
            } else if (typ == 0) {   // PRESS_TYPE_RELEASE
                player.movingBack = false;
            }
            return true;
        }

        if (key == WatchUi.KEY_START) {
            if (typ == WatchUi.PRESS_TYPE_ACTION) {
                player.wantShoot = true;
            }
            return true;
        }

        if (key == WatchUi.KEY_LAP) {
            if (typ == WatchUi.PRESS_TYPE_ACTION) {
                // Pause
                gs.mode = C.MODE_PAUSE;
                var menuView = new MenuView();
                var menuDelegate = new MenuDelegate(menuView);
                WatchUi.pushView(menuView, menuDelegate, WatchUi.SLIDE_UP);
            } else if (typ == 1) {   // PRESS_TYPE_HOLD
                // Force quit after 2s
                gs.mode = C.MODE_MENU;
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            }
            return true;
        }

        return false;
    }

    // Touch controls: left third = turn left, right third = turn right
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        var gs = GameState.get();
        if (gs.mode != C.MODE_GAME) { return false; }
        var player = gs.player as Player;
        var x = evt.getCoordinates()[0];

        if (x < C.SCREEN_W / 3) {
            player.turnLeft();
            gs.markDirty();
            WatchUi.requestUpdate();
        } else if (x > 2 * C.SCREEN_W / 3) {
            player.turnRight();
            gs.markDirty();
            WatchUi.requestUpdate();
        }
        return true;
    }

    // Swipe up on center = move forward one step
    function onSwipe(evt as WatchUi.SwipeEvent) as Boolean {
        var gs = GameState.get();
        if (gs.mode != C.MODE_GAME) { return false; }
        var player = gs.player as Player;
        var dir = evt.getDirection();

        // SwipeEvent on fr165 has no getCoordinates(); direction-only is supported.
        if (dir == WatchUi.SWIPE_UP) {
            player.movingForward = true;
            // Will be cleared next tick automatically (single step on swipe)
        }
        return true;
    }

}
