# Rhythm Fishing

A fun, polished 2D fishing game with rhythm game mechanics inspired by osu!

## Game Concept

**Core Gameplay Loop:**
1. **Cast & Wait** - Calmly cast your line and wait for fish to bite
2. **Fish Bites** - When a fish bites, a rhythm minigame starts
3. **Reel with Rhythm** - Hit circles/objects to the beat to reel the fish in
   - Perfect timing = faster reel, better rewards
   - Miss = lose progress, fish closer to escaping
4. **Catch Success** - Successfully hit all rhythm objects to catch the fish!

## Project Structure

```
rhythm-fishing/
├── scenes/              # Godot scenes (.tscn files)
│   ├── main.tscn       # Main game scene
│   └── main.gd         # Main game script
├── scripts/             # GDScript files
│   ├── fishing_game.gd
│   ├── rhythm_minigame.gd
│   ├── fish_manager.gd
│   └── audio_manager.gd
├── assets/
│   ├── sprites/         # Character/object sprites
│   ├── audio/           # Sound effects
│   └── music/           # Background tracks
├── project.godot        # Godot project configuration
└── README.md
```

## Development Roadmap

### Phase 1: Foundation
- [ ] Basic fishing UI (cast button, score display)
- [ ] Simple rhythm minigame prototype
- [ ] Fish spawning system
- [ ] Basic audio playback

### Phase 2: Core Mechanics
- [ ] Full rhythm detection (timing windows, scoring)
- [ ] Fish behavior and difficulty levels
- [ ] Combo system and visual feedback
- [ ] Sound effects and music integration

### Phase 3: Polish & Features
- [ ] Main menu and scene transitions
- [ ] Multiple song/level support
- [ ] Fish variety with unique patterns
- [ ] Upgrade system (better rods, bait)
- [ ] Leaderboards/score tracking

### Phase 4: Distribution
- [ ] Game balance and difficulty curve
- [ ] Performance optimization
- [ ] Steam integration
- [ ] Platform testing (Windows, Mac, Linux)

## Setup & Installation

### Requirements
- **Godot 4.2+** (Download from https://godotengine.org)
- macOS, Windows, or Linux

### Getting Started
1. Install Godot 4.2 or later
2. Open this project folder in Godot
3. Press Play (F5) to run the game

## Controls (Planned)

- **Left Click** - Cast fishing line / Hit rhythm notes
- **Drag** - (For rhythm slider mechanics)
- **ESC** - Pause/Menu

## Notes

- Built with Godot 4.x (GDScript)
- Targets Steam distribution
- Multi-platform support (Windows, Mac, Linux)
- Inspired by Flash game aesthetic and osu! rhythm mechanics
