// HUD.mc — Heads-up display renderer (bottom 70px of screen)

import Toybox.Graphics;
import Toybox.Lang;
using WristDungeon as C;

class HUD {

    function initialize() {
    }

    // Draw entire HUD. Strings are pre-built to avoid allocation during draw call.
    function drawHUD(dc as Graphics.Dc, player as Player, score as Number, level as Number) as Void {
        // Background bar
        dc.setColor(C.COLOR_HUD_BG, C.COLOR_HUD_BG);
        dc.fillRectangle(0, C.HUD_Y, C.SCREEN_W, C.HUD_H);

        // Separator line
        dc.setColor(C.COLOR_HUD_BORDER, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, C.HUD_Y, C.SCREEN_W, 1);

        // ── Health bar ───────────────────────────────────────────────────
        var hpBarW  = 80;
        var hpBarH  = 10;
        var hpX     = 8;
        var hpY     = C.HUD_Y + 8;
        var hpFill  = (player.hp * hpBarW / C.PLAYER_START_HP);
        if (hpFill < 0) { hpFill = 0; }
        if (hpFill > hpBarW) { hpFill = hpBarW; }

        // Bar outline
        dc.setColor(C.COLOR_MID_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(hpX - 1, hpY - 1, hpBarW + 2, hpBarH + 2);

        // Fill color based on HP
        var hpColor = _hpColor(player.hp);
        dc.setColor(hpColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(hpX, hpY, hpFill, hpBarH);

        // HP label
        dc.setColor(C.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(hpX, hpY + hpBarH + 2, Graphics.FONT_XTINY, "HP:" + player.hp.toString(), Graphics.TEXT_JUSTIFY_LEFT);

        // ── Ammo ─────────────────────────────────────────────────────────
        dc.setColor(C.COLOR_AMMO, Graphics.COLOR_TRANSPARENT);
        var ammoStr = "■ " + player.ammo.toString();
        dc.drawText(hpX, C.HUD_Y + 28, Graphics.FONT_XTINY, ammoStr, Graphics.TEXT_JUSTIFY_LEFT);

        // ── Level ─────────────────────────────────────────────────────────
        dc.setColor(C.COLOR_MENU_NORMAL, Graphics.COLOR_TRANSPARENT);
        var lvlStr = "LVL " + level.toString();
        dc.drawText(C.SCREEN_W / 2, C.HUD_Y + 8, Graphics.FONT_XTINY, lvlStr, Graphics.TEXT_JUSTIFY_CENTER);

        // ── Score (right-aligned) ──────────────────────────────────────────
        dc.setColor(C.COLOR_SCORE, Graphics.COLOR_TRANSPARENT);
        var scoreStr = score.toString();
        dc.drawText(C.SCREEN_W - 6, C.HUD_Y + 8, Graphics.FONT_XTINY, scoreStr, Graphics.TEXT_JUSTIFY_RIGHT);

        // Score label
        dc.setColor(C.COLOR_MENU_NORMAL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(C.SCREEN_W - 6, C.HUD_Y + 20, Graphics.FONT_XTINY, "pts", Graphics.TEXT_JUSTIFY_RIGHT);

        // ── Enemy count ────────────────────────────────────────────────────
        var gs = GameState.get();
        var alive = 0;
        for (var i = 0; i < C.MAX_ENEMIES; i++) {
            var en = gs.enemies[i];
            if (en != null && (en as Enemy).hp > 0) { alive++; }
        }
        dc.setColor(C.COLOR_HP_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(C.SCREEN_W / 2, C.HUD_Y + 22, Graphics.FONT_XTINY, "☠ " + alive.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function _hpColor(hp as Number) as Number {
        if (hp > 60) { return C.COLOR_HP_GREEN; }
        if (hp > 30) { return C.COLOR_HP_YELLOW; }
        return C.COLOR_HP_RED;
    }

}
