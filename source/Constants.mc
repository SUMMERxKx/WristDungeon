// Constants.mc — All magic numbers, colors, and map data for Wrist Dungeon

import Toybox.Lang;

module WristDungeon {

    // ── Colors ──────────────────────────────────────────────────────────────
    const COLOR_BLACK        = 0x000000;
    const COLOR_WHITE        = 0xFFFFFF;
    const COLOR_DARK_GRAY    = 0x303030;
    const COLOR_MID_GRAY     = 0x606060;
    const COLOR_LIGHT_GRAY   = 0xA0A0A0;
    const COLOR_CEILING      = 0x1A1A2E;  // dark navy
    const COLOR_FLOOR        = 0x12100E;  // very dark brown
    const COLOR_WALL_BRIGHT  = 0xE0E0E0;  // near wall (E/W face)
    const COLOR_WALL_MID     = 0x909090;  // mid-distance
    const COLOR_WALL_DARK    = 0x404040;  // far wall (N/S face)
    const COLOR_HP_GREEN     = 0x00CC44;
    const COLOR_HP_YELLOW    = 0xFFCC00;
    const COLOR_HP_RED       = 0xFF2200;
    const COLOR_AMMO         = 0xFFDD00;  // neon yellow
    const COLOR_CROSSHAIR    = 0x00FF66;  // neon green
    const COLOR_SCORE        = 0xAAFFFF;  // cyan
    const COLOR_HUD_BG       = 0x0A0A0A;
    const COLOR_HUD_BORDER   = 0x333333;
    const COLOR_ENEMY_BODY   = 0xCC3300;  // enemy red
    const COLOR_ENEMY_EYE    = 0xFFFF00;  // enemy eye
    const COLOR_ENEMY_MOUTH  = 0x220000;  // enemy mouth
    const COLOR_BULLET       = 0xFFFF88;
    const COLOR_ITEM_HEALTH  = 0xFF4466;
    const COLOR_ITEM_AMMO    = 0xFFDD00;
    const COLOR_MINIMAP_WALL = 0x888888;
    const COLOR_MINIMAP_FLOOR= 0x222222;
    const COLOR_MINIMAP_PLAYER = 0x00FF00;
    const COLOR_MINIMAP_ENEMY  = 0xFF0000;
    const COLOR_MINIMAP_BG   = 0x000000;
    const COLOR_MENU_TITLE   = 0xFF5500;
    const COLOR_MENU_SELECT  = 0xFFDD00;
    const COLOR_MENU_NORMAL  = 0xBBBBBB;

    // ── Screen dimensions (fr165: 390×390 AMOLED) ─────────────────────────
    const SCREEN_W           = 390;
    const SCREEN_H           = 390;
    const VIEWPORT_H         = 276;
    const HUD_H              = 114;
    const HUD_Y              = 276;
    const NUM_RAYS           = 98;       // rays per frame (1 per 4 columns)
    const RAY_STEP           = 4;        // screen columns per ray

    // ── Gameplay ─────────────────────────────────────────────────────────────
    const PLAYER_SPEED       = 0.08f;    // tiles per tick
    const PLAYER_TURN_SPEED  = 0.05f;   // radians per tick
    const PLAYER_COLLISION_R = 0.3f;
    const PLAYER_START_HP    = 100;
    const PLAYER_START_AMMO  = 20;
    const MAX_ENEMIES        = 6;
    const MAX_BULLETS        = 3;
    const ENEMY_SPEED        = 0.03f;
    const ENEMY_AI_TICKS     = 3;        // re-path every N ticks
    const BULLET_SPEED       = 0.15f;
    const MAX_RAY_DIST       = 8;        // tiles
    const FOV_HALF           = 30;       // degrees — half of 60° FOV
    const ENEMY_DAMAGE       = 10;
    const ENEMY_HP           = 30;
    const KILL_SCORE         = 100;
    const LEVEL_SCORE        = 500;
    const AMMO_PICKUP        = 10;
    const HEALTH_PICKUP      = 25;
    const MINIMAP_SIZE       = 65;
    const MINIMAP_TILE       = 3;

    // ── Trig lookup table (360 entries, degrees) ─────────────────────────────
    // Initialized by App.mc::initialize(), stored here for global access.
    var sinTable as Array<Float> = new Array<Float>[360];
    var cosTable as Array<Float> = new Array<Float>[360];

    // ── Game modes ───────────────────────────────────────────────────────────
    const MODE_MENU          = 0;
    const MODE_GAME          = 1;
    const MODE_PAUSE         = 2;
    const MODE_GAMEOVER      = 3;
    const MODE_WIN           = 4;
    const MODE_INSTRUCTIONS  = 5;

    // ── Map data (string rows, one char per tile) ────────────────────────────
    // 1=wall, 0=floor, P=player start, E=enemy, A=ammo, H=health
    // Level 1: 12×12
    var MAP_1 as Array<String> = [
        "111111111111",
        "1P0000000001",
        "101011101101",
        "100000000001",
        "101100110011",
        "1000E0000001",
        "101100110011",
        "10000A000001",
        "101100110011",
        "1000000H0001",
        "10000E000001",
        "111111111111"
    ] as Array<String>;

    var MAP_1_W as Number = 12;
    var MAP_1_H as Number = 12;

    // Level 2: 14×14
    var MAP_2 as Array<String> = [
        "11111111111111",
        "1P00000000E001",
        "10111011011011",
        "10000000000001",
        "10110011001111",
        "10000000000001",
        "10111011011011",
        "10000A000H0001",
        "10111011011011",
        "10000000000001",
        "10110011001111",
        "10000E0000E001",
        "10111011011011",
        "11111111111111"
    ] as Array<String>;

    var MAP_2_W as Number = 14;
    var MAP_2_H as Number = 14;

    // Level 3: 16×16
    var MAP_3 as Array<String> = [
        "1111111111111111",
        "1P0000000000E001",
        "1011101101101111",
        "1000000000000001",
        "1011100110111011",
        "1000000000000001",
        "1011011011011011",
        "10000A000H000001",
        "1011011011011011",
        "1000000000000001",
        "1011100110111011",
        "1000E0000E0E0001",
        "1011101101101111",
        "1000000000000001",
        "10H0E000A0000001",
        "1111111111111111"
    ] as Array<String>;

    var MAP_3_W as Number = 16;
    var MAP_3_H as Number = 16;

}
