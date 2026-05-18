// MenuView.mc — Splash, Main Menu, Instructions, Pause, Game Over, and Win screens

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using WristDungeon as C;

// ─────────────────────────────────────────────────────────────────────────────
// MenuView — shared view for all non-game screens
// ─────────────────────────────────────────────────────────────────────────────
class MenuView extends WatchUi.View {

    hidden var _menuItem as Number = 0;   // selected menu item index

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var gs = GameState.get();
        dc.setColor(C.COLOR_BLACK, C.COLOR_BLACK);
        dc.clear();

        if (gs.mode == C.MODE_MENU) {
            _drawMainMenu(dc);
        } else if (gs.mode == C.MODE_INSTRUCTIONS) {
            _drawInstructions(dc);
        } else if (gs.mode == C.MODE_PAUSE) {
            _drawPause(dc);
        } else if (gs.mode == C.MODE_GAMEOVER) {
            _drawGameOver(dc);
        } else if (gs.mode == C.MODE_WIN) {
            _drawWin(dc);
        }
    }

    function getSelectedItem() as Number { return _menuItem; }
    function setSelectedItem(idx as Number) as Void { _menuItem = idx; }

    // ── Main Menu ─────────────────────────────────────────────────────────
    hidden function _drawMainMenu(dc as Graphics.Dc) as Void {
        var cx = C.SCREEN_W / 2;
        var titleY = C.SCREEN_H / 8;
        var lineY  = titleY + 95;
        var itemY0 = lineY + 18;

        // Title
        dc.setColor(C.COLOR_MENU_TITLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, titleY, Graphics.FONT_MEDIUM, "WRIST", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, titleY + 35, Graphics.FONT_MEDIUM, "DUNGEON", Graphics.TEXT_JUSTIFY_CENTER);

        // Decorative line
        dc.setColor(C.COLOR_MID_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - 80, lineY, cx + 80, lineY);

        // Menu items
        var items = ["PLAY", "HOW TO PLAY", "QUIT"];
        for (var i = 0; i < items.size(); i++) {
            var color = (i == _menuItem) ? C.COLOR_MENU_SELECT : C.COLOR_MENU_NORMAL;
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            var prefix = (i == _menuItem) ? "> " : "  ";
            dc.drawText(cx, itemY0 + i * 42, Graphics.FONT_SMALL, prefix + items[i], Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Version tag
        dc.setColor(C.COLOR_DARK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H - 32, Graphics.FONT_XTINY, "v1.0 | FR165", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Instructions ──────────────────────────────────────────────────────
    hidden function _drawInstructions(dc as Graphics.Dc) as Void {
        var cx = C.SCREEN_W / 2;
        dc.setColor(C.COLOR_MENU_TITLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 16, Graphics.FONT_SMALL, "HOW TO PLAY", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(C.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var lines = [
            "UP:      Move forward",
            "DOWN:    Move back",
            "START:   Shoot",
            "BACK:    Pause",
            "UP hold: Minimap",
            "Touch L: Turn left",
            "Touch R: Turn right",
            "",
            "Kill enemies, grab",
            "ammo(◆) & health(♥)",
            "Reach the exit!"
        ];
        for (var i = 0; i < lines.size(); i++) {
            dc.setColor(i == 0 ? C.COLOR_SCORE : C.COLOR_MENU_NORMAL, Graphics.COLOR_TRANSPARENT);
            dc.drawText(12, 38 + i * 18, Graphics.FONT_XTINY, lines[i], Graphics.TEXT_JUSTIFY_LEFT);
        }

        dc.setColor(C.COLOR_MID_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H - 28, Graphics.FONT_XTINY, "BACK to return", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Pause ─────────────────────────────────────────────────────────────
    hidden function _drawPause(dc as Graphics.Dc) as Void {
        var gs = GameState.get();
        var cx = C.SCREEN_W / 2;
        dc.setColor(C.COLOR_MENU_TITLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 7, Graphics.FONT_MEDIUM, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(C.COLOR_MID_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - 65, C.SCREEN_H / 4, cx + 65, C.SCREEN_H / 4);

        var items = ["RESUME", "RESTART", "QUIT"];
        for (var i = 0; i < items.size(); i++) {
            var color = (i == _menuItem) ? C.COLOR_MENU_SELECT : C.COLOR_MENU_NORMAL;
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            var prefix = (i == _menuItem) ? "> " : "  ";
            dc.drawText(cx, C.SCREEN_H / 3 + i * 45, Graphics.FONT_SMALL, prefix + items[i], Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Show score
        dc.setColor(C.COLOR_SCORE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H - 50, Graphics.FONT_XTINY, "Score: " + gs.score.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Game Over ─────────────────────────────────────────────────────────
    hidden function _drawGameOver(dc as Graphics.Dc) as Void {
        var gs = GameState.get();
        var cx = C.SCREEN_W / 2;
        dc.setColor(C.COLOR_HP_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 6, Graphics.FONT_LARGE, "GAME OVER", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(C.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 3, Graphics.FONT_MEDIUM, "Score", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(C.COLOR_SCORE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 3 + 30, Graphics.FONT_MEDIUM, gs.score.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(C.COLOR_MENU_NORMAL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 2, Graphics.FONT_SMALL, "Level " + gs.level.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(C.COLOR_MENU_SELECT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H - 50, Graphics.FONT_XTINY, "START: Play Again  BACK: Menu", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Win ───────────────────────────────────────────────────────────────
    hidden function _drawWin(dc as Graphics.Dc) as Void {
        var gs = GameState.get();
        var cx = C.SCREEN_W / 2;
        dc.setColor(C.COLOR_HP_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 7, Graphics.FONT_LARGE, "YOU WIN!", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(C.COLOR_AMMO, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 4, Graphics.FONT_SMALL, "Dungeon Cleared!", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(C.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 3, Graphics.FONT_MEDIUM, "Score", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(C.COLOR_SCORE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H / 3 + 30, Graphics.FONT_MEDIUM, gs.score.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(C.COLOR_MENU_SELECT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, C.SCREEN_H - 50, Graphics.FONT_XTINY, "START: Play Again  BACK: Menu", Graphics.TEXT_JUSTIFY_CENTER);
    }

}

// ─────────────────────────────────────────────────────────────────────────────
// MenuDelegate — handles button input for all menu screens
// ─────────────────────────────────────────────────────────────────────────────
class MenuDelegate extends WatchUi.BehaviorDelegate {

    hidden var _view as MenuView;

    function initialize(view as MenuView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var gs  = GameState.get();
        var key = evt.getKey();
        var typ = evt.getType();

        if (gs.mode == C.MODE_MENU)         { return _handleMainMenu(key, typ, gs); }
        if (gs.mode == C.MODE_INSTRUCTIONS) { return _handleInstructions(key, gs); }
        if (gs.mode == C.MODE_PAUSE)        { return _handlePause(key, typ, gs); }
        if (gs.mode == C.MODE_GAMEOVER)     { return _handleEndScreen(key, gs); }
        if (gs.mode == C.MODE_WIN)          { return _handleEndScreen(key, gs); }
        return false;
    }

    // START/ENTER on fr165 — same as selecting the highlighted menu item
    function onSelect() as Boolean {
        var gs = GameState.get();
        if (gs.mode == C.MODE_MENU)  { return _confirmMainMenu(gs); }
        if (gs.mode == C.MODE_PAUSE) { return _confirmPause(gs); }
        return false;
    }

    hidden function _isConfirmKey(key as Number) as Boolean {
        return key == WatchUi.KEY_START || key == WatchUi.KEY_ENTER;
    }

    hidden function _confirmMainMenu(gs as GameState) as Boolean {
        var sel = _view.getSelectedItem();
        if (sel == 0) {  // Play
            gs.resetGame();
            gs.mode = C.MODE_GAME;
            var gameView = new GameView();
            var gameDelegate = new GameDelegate(gameView);
            WatchUi.pushView(gameView, gameDelegate, WatchUi.SLIDE_LEFT);
        } else if (sel == 1) {  // Instructions
            gs.mode = C.MODE_INSTRUCTIONS;
            WatchUi.requestUpdate();
        } else {  // Quit
            System.exit();
        }
        return true;
    }

    hidden function _confirmPause(gs as GameState) as Boolean {
        var sel = _view.getSelectedItem();
        if (sel == 0) {  // Resume
            gs.mode  = C.MODE_GAME;
            gs.needsRedraw = true;
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else if (sel == 1) {  // Restart
            gs.resetGame();
            gs.mode = C.MODE_GAME;
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else {  // Quit
            gs.mode = C.MODE_MENU;
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        return true;
    }

    hidden function _handleMainMenu(key as Number, typ as Number, gs as GameState) as Boolean {
        if (key == WatchUi.KEY_UP && typ == WatchUi.PRESS_TYPE_ACTION) {
            _view.setSelectedItem((_view.getSelectedItem() - 1 + 3) % 3);
            WatchUi.requestUpdate();
        } else if (key == WatchUi.KEY_DOWN && typ == WatchUi.PRESS_TYPE_ACTION) {
            _view.setSelectedItem((_view.getSelectedItem() + 1) % 3);
            WatchUi.requestUpdate();
        } else if (_isConfirmKey(key) && typ == WatchUi.PRESS_TYPE_ACTION) {
            _confirmMainMenu(gs);
        }
        return true;
    }

    hidden function _handleInstructions(key as Number, gs as GameState) as Boolean {
        if (key == WatchUi.KEY_LAP) {
            gs.mode = C.MODE_MENU;
            WatchUi.requestUpdate();
        }
        return true;
    }

    hidden function _handlePause(key as Number, typ as Number, gs as GameState) as Boolean {
        if (key == WatchUi.KEY_UP && typ == WatchUi.PRESS_TYPE_ACTION) {
            _view.setSelectedItem((_view.getSelectedItem() - 1 + 3) % 3);
            WatchUi.requestUpdate();
        } else if (key == WatchUi.KEY_DOWN && typ == WatchUi.PRESS_TYPE_ACTION) {
            _view.setSelectedItem((_view.getSelectedItem() + 1) % 3);
            WatchUi.requestUpdate();
        } else if (_isConfirmKey(key) && typ == WatchUi.PRESS_TYPE_ACTION) {
            _confirmPause(gs);
        } else if (key == WatchUi.KEY_LAP) {
            // Also resume on back press from pause
            gs.mode  = C.MODE_GAME;
            gs.needsRedraw = true;
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
        return true;
    }

    hidden function _handleEndScreen(key as Number, gs as GameState) as Boolean {
        if (_isConfirmKey(key)) {
            gs.resetGame();
            gs.mode = C.MODE_GAME;
            var gameView = new GameView();
            var gameDelegate = new GameDelegate(gameView);
            WatchUi.pushView(gameView, gameDelegate, WatchUi.SLIDE_LEFT);
        } else if (key == WatchUi.KEY_LAP) {
            gs.mode = C.MODE_MENU;
            WatchUi.requestUpdate();
        }
        return true;
    }

}
