# Rhythm Fishing - Technical Architecture Document

## Overview
This document outlines the technical structure, systems design, and implementation plan for Rhythm Fishing built in Godot 4.x (GDScript).

---

## Project Structure

```
rhythm-fishing/
├── scenes/
│   ├── main.tscn                    # Root scene
│   ├── main.gd                      # Main game manager
│   ├── ui/
│   │   ├── main_menu.tscn
│   │   ├── main_menu.gd
│   │   ├── level_select.tscn
│   │   ├── settings.tscn
│   │   └── hud/
│   │       ├── fishing_hud.tscn
│   │       ├── rhythm_hud.tscn
│   │       └── results_screen.tscn
│   ├── fishing/
│   │   ├── fishing_phase.tscn
│   │   ├── fishing_phase.gd
│   │   ├── bobber.tscn
│   │   ├── bobber.gd
│   │   └── fish_spawner.gd
│   └── rhythm/
│       ├── rhythm_minigame.tscn
│       ├── rhythm_minigame.gd
│       ├── note.tscn
│       ├── note.gd
│       ├── note_manager.gd
│       └── hit_detector.gd
├── scripts/
│   ├── core/
│   │   ├── game_manager.gd          # Central game state
│   │   ├── scene_manager.gd         # Scene transitions
│   │   ├── input_manager.gd         # Input handling
│   │   ├── audio_manager.gd         # Music/SFX
│   │   └── progression_manager.gd   # Save/progression
│   ├── data/
│   │   ├── fish_database.gd         # Fish species data
│   │   ├── beat_map_loader.gd       # Load beat maps
│   │   ├── player_data.gd           # Player progress
│   │   └── constants.gd             # Game constants
│   └── systems/
│       ├── scoring_system.gd        # Score calculation
│       ├── mastery_system.gd        # Mastery tracking
│       ├── timing_system.gd         # Beat/timing detection
│       └── rod_system.gd            # Rod mechanics
├── data/
│   ├── fish/
│   │   ├── perch_genus.json
│   │   ├── salmon_genus.json
│   │   ├── drum_genus.json
│   │   └── legendary.json
│   ├── beat_maps/
│   │   ├── area_1/
│   │   │   ├── calm_creek_1.json
│   │   │   └── calm_creek_2.json
│   │   └── area_2/
│   │       └── ...
│   └── settings.json
├── assets/
│   ├── sprites/
│   │   ├── fish/
│   │   ├── ui/
│   │   └── effects/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/
├── project.godot
└── README.md
```

---

## Core Systems Architecture

### 1. **Game Manager** (Central Hub)
**File:** `scripts/core/game_manager.gd`

Singleton that manages:
- Game state (menu, fishing, rhythm, results)
- Current area/level
- Current fish being caught
- Player data access
- Signal emission for state changes

```gdscript
class_name GameManager
extends Node

# Game states
enum GameState { MENU, LEVEL_SELECT, FISHING, RHYTHM, RESULTS, PAUSED }

var current_state: GameState
var current_area: String          # "area_1", "area_2", etc
var current_level: String         # Song/beat map identifier
var current_fish: Dictionary      # Fish data being caught
var player_data: PlayerData

# Signals
signal state_changed(new_state: GameState)
signal area_changed(area: String)
signal fish_caught(fish: Dictionary)
signal level_completed(score: int)
```

---

### 2. **Scene Manager** (Navigation)
**File:** `scripts/core/scene_manager.gd`

Handles scene transitions and loading:
- Load scenes asynchronously
- Handle fade transitions
- Stack-based scene management (menu → level select → fishing)

```gdscript
class_name SceneManager
extends Node

func change_scene(scene_path: String, transition_duration: float = 0.5) -> void:
    # Fade out current, load new scene, fade in
    pass

func push_scene(scene_path: String) -> void:
    # Add scene on top of stack (for pause menu, etc)
    pass

func pop_scene() -> void:
    # Return to previous scene
    pass
```

---

### 3. **Input Manager** (Input Handling)
**File:** `scripts/core/input_manager.gd`

Centralized input processing:
- Mouse/touch clicks
- Keyboard (ESC for pause, etc)
- Input context (fishing vs rhythm has different behavior)

```gdscript
class_name InputManager
extends Node

signal click_detected(position: Vector2, time_ms: float)
signal hold_started(position: Vector2)
signal hold_released()
signal pause_pressed()

var input_enabled: bool = true
var current_context: String  # "fishing", "rhythm", "menu"
```

---

### 4. **Audio Manager** (Music & SFX)
**File:** `scripts/core/audio_manager.gd`

Manages:
- Music playback
- Sound effects
- Volume control
- Beat sync (crucial for rhythm game)

```gdscript
class_name AudioManager
extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func play_music(music_name: String, loop: bool = true) -> void:
    pass

func play_sfx(sfx_name: String) -> void:
    pass

func get_music_position_ms() -> int:
    # Critical for rhythm detection
    pass

func set_music_offset_ms(offset: int) -> void:
    # Latency compensation
    pass
```

---

### 5. **Progression Manager** (Save System)
**File:** `scripts/core/progression_manager.gd`

Handles:
- Save/load game progress
- Mastery tracking per fish
- Unlock conditions
- Leaderboards (local)

---

## Data Structures

### Fish Data Structure
```json
{
  "id": "yellow_perch_01",
  "common_name": "Yellow Perch",
  "scientific_name": "Perca flavescens",
  "genus": "Perch",
  "tier": 1,
  "area": "area_1",
  "size_range_inches": [4, 8],
  "visual_color": "Golden-yellow",
  "rarity": "Very Common",
  "spawn_chance": 100,
  "unlock_condition": "none",
  "music_genre": "acoustic",
  "pattern_ids": ["yellow_perch_pattern_1", "yellow_perch_pattern_2"],
  "pattern_difficulty": 1,
  "bpm_range": [90, 110],
  "base_points": 100,
  "size_variant_multiplier": 1.0,
  "mastery_reward_per_catch": 5,
  "description": "Curious and easy to catch, perfect for beginners"
}
```

### Beat Map Structure
```json
{
  "id": "calm_creek_1",
  "title": "Gentle Stream",
  "artist": "Ambient Composer",
  "area": "area_1",
  "genre": "acoustic",
  "bpm": 100,
  "difficulty": 1,
  "duration_seconds": 45,
  "offset_ms": 0,
  "target_fish_genus": ["Perch"],
  "audio_file": "calm_creek_1.ogg",
  "notes": [
    {
      "time_ms": 1000,
      "type": "circle",
      "position": [400, 300],
      "timing_window_ms": 100
    },
    {
      "time_ms": 1500,
      "type": "circle",
      "position": [400, 300],
      "timing_window_ms": 100
    }
  ],
  "total_notes": 45,
  "health_to_win": 100
}
```

### Player Progress Structure
```json
{
  "player_id": "unique_id",
  "total_score": 50000,
  "level_completion": {
    "area_1": {
      "unlocked": true,
      "completed_levels": 3,
      "best_scores": { "level_1": 2500 }
    }
  },
  "fish_caught": {
    "yellow_perch_01": {
      "total_caught": 25,
      "best_size_inches": 7.8,
      "caught_legendary": false
    }
  },
  "mastery": {
    "Perch": 50,
    "Salmon": 0
  },
  "rod_progression": {
    "casual": 1,
    "hardcore": 0
  }
}
```

---

## Scene Hierarchy & State Flow

```
Main (Root)
├── GameManager (Autoload/Singleton)
├── InputManager (Autoload)
├── AudioManager (Autoload)
├── SceneManager (Autoload)
│
└── Active Scene (one at a time):
    ├── MainMenu
    │   ├── StartButton → Level Select
    │   ├── Settings
    │   └── Quit
    │
    ├── LevelSelect
    │   ├── Area Selection
    │   │   ├── Area 1 (Calm Creek)
    │   │   ├── Area 2 (Golden River)
    │   │   ├── Area 3 (Coastal Bay)
    │   │   └── Area 4 (Deep Ocean)
    │   ├── Rod Selection (Casual vs Hardcore)
    │   └── Back to Menu
    │
    ├── FishingPhase
    │   ├── Background (water, scenery)
    │   ├── Bobber (player fishing line)
    │   ├── Cast Button
    │   ├── HUD (score, timer, area info)
    │   └── Pause Button → PauseMenu
    │       └── Resume / Settings / Quit
    │
    ├── RhythmMinigame
    │   ├── Background (same area)
    │   ├── Fish Animation
    │   ├── Note Container (circles, holds, sliders spawn here)
    │   ├── Hit Detector (mouse click/touch detector)
    │   ├── HUD (health bar, combo, score)
    │   └── Pause Button → PauseMenu
    │
    └── ResultsScreen
        ├── Final Score
        ├── Fish Caught
        ├── Accuracy Stats
        ├── Mastery Progress
        ├── Retry Button
        ├── Next Level Button
        └── Menu Button
```

---

## Game Loop & State Transitions

```
START
  ↓
MENU STATE
  ├─ User clicks "Start"
  ↓
LEVEL_SELECT STATE
  ├─ User picks area + rod
  ├─ User selects specific level/song
  ↓
FISHING STATE
  ├─ Music plays (ambience)
  ├─ Player waits for fish
  ├─ Fish spawns randomly
  ├─ Fish bites → transition to RHYTHM
  ├─ Time expires → go to RESULTS (failed)
  ├─ User pauses → PAUSED state
  ↓
RHYTHM STATE
  ├─ Minigame music plays
  ├─ Notes spawn to beat
  ├─ Player clicks notes
  ├─ Health bar decreases on misses
  ├─ If health = 0 → fish escapes → RESULTS (failed)
  ├─ If all notes hit → fish caught → RESULTS (success)
  ├─ User pauses → PAUSED state
  ↓
RESULTS STATE
  ├─ Show score, accuracy, fish caught
  ├─ Update progression/mastery
  ├─ User clicks "Retry" → back to FISHING
  ├─ User clicks "Next Level" → LEVEL_SELECT
  ├─ User clicks "Menu" → MENU
  ↓
LOOP
```

---

## Key System Interactions

### Fishing Phase Flow
```
FishingPhase._ready():
  ├─ Load beat map data
  ├─ Get target fish pool for area
  ├─ Start ambience music
  └─ Show cast button

FishingPhase._process():
  ├─ Update timer
  ├─ Check spawn conditions
  ├─ If random spawn → spawn fish
  └─ Update visuals

User clicks cast:
  ├─ Play cast animation
  └─ Enable waiting state

Fish spawns:
  ├─ Play bite animation
  ├─ Play bite SFX
  └─ After delay → transition to RhythmMinigame
```

### Rhythm Minigame Flow
```
RhythmMinigame._ready():
  ├─ Load beat map
  ├─ Start music playback
  ├─ Sync music to audio position
  └─ Create note visual objects

RhythmMinigame._process(delta):
  ├─ Get current music position
  ├─ Spawn notes that are within spawn window
  ├─ Update note positions (move toward hit zone)
  ├─ Check for expired notes (missed)
  └─ Update health bar

User clicks:
  ├─ Check if click is on a note
  ├─ Calculate timing accuracy
  │   ├─ Perfect (±50ms) → 300 points
  │   ├─ Good (±100ms) → 100 points
  │   └─ Miss → 0 points, lose health
  ├─ Play hit effect
  ├─ Update combo
  └─ Check win/lose conditions

Minigame ends:
  ├─ If health = 0 → escape, go to Results
  ├─ If all notes hit → catch, go to Results
  └─ Update progression
```

---

## Timing System (Critical for Rhythm Game)

### Audio Sync Strategy
```
1. Load beat map with note timings
2. Start music playback
3. Each frame:
   ├─ Get current audio playback position (in ms)
   ├─ For each note in beat map:
   │   ├─ Calculate: note_time - current_audio_time
   │   ├─ If value = within spawn window → spawn note
   │   ├─ If value = between -100ms to +100ms → hittable
   │   └─ If value < -100ms → missed
   └─ Adjust for input latency offset
```

### Input Latency Compensation
```
Player clicks → Browser input lag (~16-50ms)
                Browser → Godot (~16ms)
                Godot processing → Audio comparison (~16ms)

Total: ~50-100ms typical lag

Solution: Audio offset calibration in settings
- Allow player to adjust offset +/- 100ms
- Test against a simple click→sound pattern
- Save offset to PlayerData
```

---

## Scoring System

### Hit Scoring
```
Base Hit Points:
- Perfect (±50ms): 300 pts
- Good (±100ms): 100 pts
- Miss (>100ms): 0 pts

Combo Multiplier:
- 0-10 hits: 1x
- 11-25 hits: 1.5x
- 26-50 hits: 2x
- 51+ hits: 3x

Rod Multiplier:
- Casual rod: 1x (baseline)
- Challenge rod: 1.5x
- Master rod: 1.75x
- Legendary rod: 2x

Final Score = (Hit Points) × (Combo Multiplier) × (Rod Multiplier) × (Fish Difficulty)
```

### Accuracy Calculation
```
Accuracy % = (Perfect hits × 300 + Good hits × 100) / (Total notes × 300)

Example:
- 30 perfect hits = 9000 pts
- 5 good hits = 500 pts
- 10 misses = 0 pts
- Total: 9500 / (45 × 300) = 70.4% accuracy
```

---

## Performance Targets

- **Frame Rate:** Stable 60 FPS
- **Input Latency:** <50ms from click to detection
- **Memory:** <200MB during gameplay
- **Audio Sync Drift:** <10ms over 60 seconds of music

---

## Dependencies & External Libraries

- **Godot 4.2+** (built-in, no external dependencies)
- Beat map files (JSON)
- Audio files (OGG Vorbis, native Godot support)
- Custom GDScript modules

---

## Implementation Priority

### Phase 1: Core Foundation
1. GameManager + Scene system
2. Basic menu UI
3. Input manager
4. Audio manager
5. Progression/save system

### Phase 2: Fishing Phase
1. Fishing scene layout
2. Bobber animation
3. Fish spawner
4. Basic timer/HUD

### Phase 3: Rhythm Minigame
1. Note rendering (circles only)
2. Hit detection
3. Timing system
4. Scoring

### Phase 4: Polish & Features
1. More note types (holds, sliders)
2. Visual effects
3. Sound effects
4. Fish species data
5. Full progression system

---

## Testing Strategy

- **Unit Tests:** Scoring calculation, mastery logic
- **Integration Tests:** Scene transitions, state changes
- **Gameplay Tests:** Timing accuracy, feel/flow
- **Performance Tests:** Frame rate, memory usage

---

## Future Considerations

- Mobile touch controls
- Gamepad support
- Online leaderboards
- Custom beat map editor
- Mod support
- Accessibility features (colorblind modes, adjustable timing windows)
