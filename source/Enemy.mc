// Enemy.mc — Enemy entity: AI movement, sprite rendering

import Toybox.Graphics;
import Toybox.Lang;
using WristDungeon as C;

class Enemy {

    var x      as Float;
    var y      as Float;
    var hp     as Number = C.ENEMY_HP;
    var _aiTick as Number = 0;
    var _dx    as Float  = 0.0f;
    var _dy    as Float  = 0.0f;

    function initialize(startX as Float, startY as Float) {
        x = startX;
        y = startY;
    }

    // Called every game tick
    function update() as Void {
        if (hp <= 0) { return; }
        var gs  = GameState.get();
        var map = gs.map as GameMap;
        var p   = gs.player as Player;

        // Recalculate direction every ENEMY_AI_TICKS
        _aiTick++;
        if (_aiTick >= C.ENEMY_AI_TICKS) {
            _aiTick = 0;
            _computeDir(p, map);
        }

        // Move
        var nx = x + _dx;
        var ny = y + _dy;
        if (!map.isWall(nx.toNumber(), y.toNumber()))  { x = nx; }
        if (!map.isWall(x.toNumber(), ny.toNumber()))  { y = ny; }

        // Melee attack if very close
        var dx = p.x - x;
        var dy = p.y - y;
        if ((dx * dx + dy * dy) < 0.6f) {
            p.takeDamage(C.ENEMY_DAMAGE);
        }

        gs.markDirty();
    }

    // Check if bullet collides with this enemy
    function checkBulletHit(bx as Float, by as Float) as Boolean {
        var dx = bx - x;
        var dy = by - y;
        return (dx * dx + dy * dy) < 0.25f;   // 0.5 tile radius
    }

    // Draw pixel-art enemy sprite centered at (screenX, screenY) with given scale
    function drawSprite(dc as Graphics.Dc, screenX as Number, screenY as Number, scale as Float) as Void {
        var w = (scale * 20).toNumber();
        var h = (scale * 28).toNumber();
        if (w < 4) { w = 4; }
        if (h < 6) { h = 6; }
        var x0 = screenX - w / 2;
        var y0 = screenY - h / 2;

        // Body
        dc.setColor(C.COLOR_ENEMY_BODY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x0, y0, w, h);

        // Eyes
        var ew = (w / 5).toNumber();
        if (ew < 2) { ew = 2; }
        var eh = (h / 6).toNumber();
        if (eh < 2) { eh = 2; }
        dc.setColor(C.COLOR_ENEMY_EYE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x0 + w / 4 - ew / 2, y0 + h / 4, ew, eh);
        dc.fillRectangle(x0 + 3 * w / 4 - ew / 2, y0 + h / 4, ew, eh);

        // Mouth
        var mw = (w * 2 / 3).toNumber();
        var mh = (h / 8).toNumber();
        if (mh < 2) { mh = 2; }
        dc.setColor(C.COLOR_ENEMY_MOUTH, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x0 + w / 6, y0 + h * 2 / 3, mw, mh);
    }

    // ── Private ──────────────────────────────────────────────────────────────
    hidden function _computeDir(p as Player, map as GameMap) as Void {
        var dx = p.x - x;
        var dy = p.y - y;
        var dist = (dx * dx + dy * dy);
        if (dist < 0.001f) { _dx = 0.0f; _dy = 0.0f; return; }
        // Normalize
        var len = _sqrt(dist);
        _dx = (dx / len) * C.ENEMY_SPEED;
        _dy = (dy / len) * C.ENEMY_SPEED;
        // Wall avoidance: zero out component that would enter a wall
        if (map.isWall((x + _dx).toNumber(), y.toNumber())) { _dx = 0.0f; }
        if (map.isWall(x.toNumber(), (y + _dy).toNumber()))  { _dy = 0.0f; }
    }

    // Integer square root approximation (avoids Math.sqrt in hot path)
    hidden function _sqrt(v as Float) as Float {
        if (v <= 0.0f) { return 0.0f; }
        var x = v;
        var x1 = (x + 1.0f) / 2.0f;
        for (var i = 0; i < 8; i++) {
            x1 = (x1 + v / x1) / 2.0f;
        }
        return x1;
    }

}
