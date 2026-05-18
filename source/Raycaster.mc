// Raycaster.mc — Pseudo-3D DDA raycaster renderer

import Toybox.Graphics;
import Toybox.Lang;
using WristDungeon as C;

class Raycaster {

    // Flat pre-computed value used for wall projection
    // focal = (screen_width/2) / tan(FOV/2)  = 120 / tan(30°) ≈ 207.8
    hidden var _focal as Float = 337.7f;   // (SCREEN_W/2) / tan(30°) for 390px wide display

    function initialize() {
    }

    // Render the full 3D viewport (top 170 px) and enemy sprites
    function renderFrame(dc as Graphics.Dc) as Void {
        var gs     = GameState.get();
        var player = gs.player as Player;
        var map    = gs.map as GameMap;

        // ── Ceiling & Floor ─────────────────────────────────────────────────
        dc.setColor(C.COLOR_CEILING, C.COLOR_CEILING);
        dc.fillRectangle(0, 0, C.SCREEN_W, C.VIEWPORT_H / 2);
        dc.setColor(C.COLOR_FLOOR, C.COLOR_FLOOR);
        dc.fillRectangle(0, C.VIEWPORT_H / 2, C.SCREEN_W, C.VIEWPORT_H / 2);

        // ── Cast rays ───────────────────────────────────────────────────────
        // zBuffer stores perpendicular wall distance per screen column (for sprite occlusion)
        var zBuffer = new Array<Float>[C.SCREEN_W];

        var ray = 0;
        for (var screenX = 0; screenX < C.SCREEN_W; screenX += C.RAY_STEP) {
            // Camera-space column: -1.0 (left) to +1.0 (right)
            var camX = (2.0f * screenX.toFloat() / C.SCREEN_W.toFloat()) - 1.0f;

            // Ray angle in degrees
            var rayAngleDeg = (player.angle + (camX * C.FOV_HALF).toNumber() + 360) % 360;
            if (rayAngleDeg < 0)   { rayAngleDeg = 0; }
            if (rayAngleDeg > 359) { rayAngleDeg = 359; }

            var cosA = C.cosTable[rayAngleDeg];
            var sinA = C.sinTable[rayAngleDeg];

            // DDA setup
            var mapX  = player.x.toNumber();
            var mapY  = player.y.toNumber();
            var posX  = player.x;
            var posY  = player.y;

            // Avoid division by zero
            var deltaDistX = (cosA == 0.0f) ? 1e30f : _absF(1.0f / cosA);
            var deltaDistY = (sinA == 0.0f) ? 1e30f : _absF(1.0f / sinA);

            var stepX = 0;
            var stepY = 0;
            var sideDistX = 0.0f;
            var sideDistY = 0.0f;

            if (cosA < 0.0f) {
                stepX    = -1;
                sideDistX = (posX - mapX.toFloat()) * deltaDistX;
            } else {
                stepX    = 1;
                sideDistX = (mapX.toFloat() + 1.0f - posX) * deltaDistX;
            }
            if (sinA < 0.0f) {
                stepY    = -1;
                sideDistY = (posY - mapY.toFloat()) * deltaDistY;
            } else {
                stepY    = 1;
                sideDistY = (mapY.toFloat() + 1.0f - posY) * deltaDistY;
            }

            var hit  = false;
            var side = 0;   // 0 = E/W wall, 1 = N/S wall
            var dist = 0;

            while (!hit && dist < C.MAX_RAY_DIST) {
                if (sideDistX < sideDistY) {
                    sideDistX += deltaDistX;
                    mapX += stepX;
                    side = 0;
                } else {
                    sideDistY += deltaDistY;
                    mapY += stepY;
                    side = 1;
                }
                if (map.isWall(mapX, mapY)) { hit = true; }
                dist++;
            }

            // Perp wall distance (uncorrected fish-eye)
            var perpDist = 0.0f;
            if (side == 0) {
                perpDist = (mapX.toFloat() - posX + (1.0f - stepX.toFloat()) / 2.0f) / cosA;
            } else {
                perpDist = (mapY.toFloat() - posY + (1.0f - stepY.toFloat()) / 2.0f) / sinA;
            }
            if (perpDist < 0.1f) { perpDist = 0.1f; }

            // Store in z-buffer for each screen column covered by this ray
            for (var c = screenX; c < screenX + C.RAY_STEP && c < C.SCREEN_W; c++) {
                zBuffer[c] = perpDist;
            }

            // Wall slice height
            var sliceH = (C.VIEWPORT_H.toFloat() / perpDist).toNumber();
            if (sliceH > C.VIEWPORT_H) { sliceH = C.VIEWPORT_H; }
            var sliceTop = (C.VIEWPORT_H - sliceH) / 2;

            // Choose wall color based on distance and side
            var wallColor = _wallColor(perpDist, side);
            dc.setColor(wallColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(screenX, sliceTop, C.RAY_STEP, sliceH);

            ray++;
        }

        // ── Enemy sprites ───────────────────────────────────────────────────
        _renderEnemies(dc, gs, player, zBuffer);

        // ── Crosshair ───────────────────────────────────────────────────────
        dc.setColor(C.COLOR_CROSSHAIR, Graphics.COLOR_TRANSPARENT);
        var cx = C.SCREEN_W / 2;
        var cy = C.VIEWPORT_H / 2;
        dc.fillRectangle(cx - 1, cy - 6, 2, 5);   // upper arm
        dc.fillRectangle(cx - 1, cy + 2, 2, 5);   // lower arm
        dc.fillRectangle(cx - 6, cy - 1, 5, 2);   // left arm
        dc.fillRectangle(cx + 2, cy - 1, 5, 2);   // right arm
    }

    // ── Private: wall color from distance and side ────────────────────────────
    hidden function _wallColor(dist as Float, side as Number) as Number {
        var brightness = 0;
        if (dist < 2.0f)      { brightness = 0; }
        else if (dist < 4.0f) { brightness = 1; }
        else if (dist < 6.0f) { brightness = 2; }
        else                  { brightness = 3; }

        // N/S walls slightly darker
        if (side == 1) { brightness++; }
        if (brightness > 4) { brightness = 4; }

        if (brightness == 0) { return C.COLOR_WALL_BRIGHT; }
        if (brightness == 1) { return C.COLOR_LIGHT_GRAY; }
        if (brightness == 2) { return C.COLOR_MID_GRAY; }
        if (brightness == 3) { return C.COLOR_DARK_GRAY; }
        return C.COLOR_BLACK;
    }

    // ── Private: sprite rendering ─────────────────────────────────────────────
    hidden function _renderEnemies(dc as Graphics.Dc, gs as GameState, player as Player, zBuffer as Array<Float>) as Void {
        for (var i = 0; i < C.MAX_ENEMIES; i++) {
            var en = gs.enemies[i];
            if (en == null || (en as Enemy).hp <= 0) { continue; }

            var e = en as Enemy;
            var dx = e.x - player.x;
            var dy = e.y - player.y;

            // Transform relative to camera
            var cosA = C.cosTable[player.angle];
            var sinA = C.sinTable[player.angle];

            // Inverse camera matrix
            var invDet = 1.0f / (cosA * cosA + sinA * sinA);  // identity det=1 always
            var transformX = invDet * (cosA * dx + sinA * dy);
            var transformY = invDet * (-sinA * dx + cosA * dy);

            if (transformY <= 0.1f) { continue; }   // behind player

            // Screen X position of sprite center
            var spriteScreenX = ((C.SCREEN_W.toFloat() / 2.0f) * (1.0f + transformX / transformY)).toNumber();
            var spriteH = (_absF(C.VIEWPORT_H.toFloat() / transformY)).toNumber();
            if (spriteH > C.VIEWPORT_H) { spriteH = C.VIEWPORT_H; }
            var spriteY = C.VIEWPORT_H / 2;

            // Check occlusion: sprite must be closer than wall at screen column
            if (spriteScreenX >= 0 && spriteScreenX < C.SCREEN_W) {
                var zAtSprite = zBuffer[spriteScreenX];
                if (transformY < zAtSprite) {
                    var scale = _absF(1.0f / transformY);
                    e.drawSprite(dc, spriteScreenX, spriteY, scale);
                }
            }
        }
    }

    hidden function _absF(v as Float) as Float {
        return v < 0.0f ? -v : v;
    }

}
