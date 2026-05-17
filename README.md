# Wrist Dungeon

**Wrist Dungeon** is a Garmin Connect IQ watch app that brings a compact, retro first-person dungeon crawler to the wrist. It uses Monkey C and Toybox APIs to render a raycast 3D maze, enemies, pickups, a HUD, and watch-friendly menu/input screens.

## Features

- First-person raycast dungeon rendering with distance-shaded walls.
- Three handcrafted levels with enemies, ammo pickups, and health pickups.
- Lightweight 10 FPS game loop tuned for a 240×240 watch display.
- Button and touch controls for movement, turning, shooting, pausing, and minimap toggling.
- HUD with HP, ammo, score, and level information.
- Optional minimap overlay.
- Main menu, instructions screen, pause menu, game over screen, and win screen.

## Supported device

This project currently targets the **Garmin Forerunner 165 (`fr165`)** and requires Connect IQ API level **4.2.0** or newer.

## Project structure

```text
.
├── manifest.xml              # Connect IQ app metadata, supported products, version, permissions
├── monkey.jungle             # Monkey C project configuration
├── resources/                # App resources: strings, drawables, launcher icon
└── source/                   # Monkey C source files
    ├── App.mc                # Application entry point and trig table initialization
    ├── GameView.mc           # Main game view, loop, transitions, and input delegate
    ├── MenuView.mc           # Main menu, instructions, pause, game over, and win screens
    ├── GameState.mc          # Singleton game state and level loading
    ├── Constants.mc          # Colors, gameplay constants, screen sizes, level maps
    ├── Map.mc                # Grid parsing, wall checks, entity spawn data, pickups
    ├── Player.mc             # Player movement, HP, ammo, and shooting
    ├── Enemy.mc              # Enemy AI, combat, and sprite drawing
    ├── Bullet.mc             # Projectile movement and collisions
    ├── Raycaster.mc          # 3D wall and enemy rendering
    ├── HUD.mc                # Gameplay HUD drawing
    └── Minimap.mc            # Optional minimap overlay
```

## Requirements

Install Garmin's Connect IQ tooling before building:

- Garmin Connect IQ SDK with Monkey C compiler (`monkeyc`).
- Connect IQ simulator tools (`connectiq` / `monkeydo`) for local testing.
- A Garmin developer key (`developer_key.der`) for signing builds.

Make sure the SDK `bin` directory is available on your `PATH` so `monkeyc` and `monkeydo` can be run from this repository.

## Build

From the repository root, compile the app for the Forerunner 165 target:

```sh
mkdir -p bin
monkeyc -f monkey.jungle -o bin/WristDungeon.prg -y /path/to/developer_key.der -d fr165
```

Replace `/path/to/developer_key.der` with the path to your Garmin developer key.

## Run in the simulator

Start the Connect IQ simulator, then run the compiled app:

```sh
connectiq
monkeydo bin/WristDungeon.prg fr165
```

If your SDK uses a different simulator command name or workflow, use the equivalent Connect IQ SDK launch command for the `fr165` device.

## Gameplay

Clear each dungeon by defeating all enemies. Finishing a level grants a score bonus and advances to the next level. Clear all three levels to win.

### Controls

| Input | Action |
| --- | --- |
| `UP` | Move forward |
| `DOWN` | Move backward |
| `START` | Shoot |
| `BACK` / `LAP` | Pause |
| Hold `UP` | Toggle minimap |
| Tap left side | Turn left |
| Tap right side | Turn right |
| Center swipe up | Step forward |

### Pickups and scoring

- Ammo pickups restore ammo.
- Health pickups restore HP up to the starting maximum.
- Enemy kills award score.
- Level completion awards a bonus score.

## Development notes

- Trigonometric lookup tables are initialized once at app startup to avoid repeated `Math.sin()` / `Math.cos()` calls during rendering.
- Rendering constants are centralized in `source/Constants.mc` for easier tuning.
- Level maps are stored as string rows in `source/Constants.mc`; map characters are parsed by `source/Map.mc`:
  - `1` = wall
  - `0` = floor
  - `P` = player start
  - `E` = enemy spawn
  - `A` = ammo pickup
  - `H` = health pickup
- The app is configured as a `watch-app` in `manifest.xml` and currently declares no special permissions.

## License

No license file is currently included in this repository. Add one before distributing or accepting external contributions.
