# Rhythm Fishing - Game Design Document

## Project Overview
**Game Title:** Rhythm Fishing
**Platform:** Godot 4.x (GDScript)
**Target Distribution:** Steam (Windows, Mac, Linux)
**Genre:** Rhythm + Fishing Hybrid
**Aesthetic:** Polished Flash game style with smooth animations and satisfying feedback
**Repository:** https://github.com/dSpringOnion/flashfishing

---

## Core Game Flow

### Main Loop Structure
```
Start Game
    ↓
Main Menu
    ↓
Select Song/Level
    ↓
Fishing Phase (Cast & Wait)
    ├── Player casts line
    ├── Wait for fish to bite
    ├── Fish randomly spawn based on difficulty
    └── When fish bites → Rhythm Minigame Phase
        ↓
    Rhythm Minigame (Reel with Rhythm)
    ├── Music syncs with rhythm objects
    ├── Fish struggles = rhythm circles appear
    ├── Player hits circles to the beat
    ├── Perfect hits = faster reel, better rewards
    ├── Misses = lose progress, fish closer to escape
    └── Success → Fish Caught OR Failure → Fish Escaped
        ↓
    Round Complete
    ├── Score calculated
    ├── Fish added to catch log
    └── Next fish spawns OR Level ends
        ↓
Level Results Screen
├── Total score
├── Combo stats
├── Fish caught
└── Option to retry/next level/menu
```

---

## Fishing Phase (Calm/Waiting)

### Mechanics
- **Cast Animation** - Player clicks to cast fishing line
- **Waiting Period** - Calm, relaxing music plays
- **Visual Feedback** - Water ripples, bobber animation
- **Fish Spawning** - Based on difficulty:
  - Easy: Fish appear frequently, predictable patterns
  - Normal: Balanced spawn rate
  - Hard: Rare spawns, irregular timing
- **Difficulty Modifiers** - Time limits, multiple fish simultaneously

### Player Actions
- Click to cast
- Wait (no input required)
- Automatic transition to rhythm minigame when fish bites

### Exit Conditions
- Fish bites → Enter Rhythm Minigame
- Time limit expired → Level ends
- Player pauses → Menu

---

## Rhythm Minigame Phase (Reel with Rhythm)

### Rhythm Object Types (Inspired by osu!)

#### 1. **Circle Notes**
- Single click on beat
- Timing windows:
  - **Perfect (300):** ±50ms from beat
  - **Good (100):** ±100ms from beat
  - **Miss (0):** >100ms or too early

#### 2. **Hold Notes**
- Press and hold for duration
- Fills meter while held
- Breaking early = partial points

#### 3. **Slider Notes**
- Click and drag along a path
- Must follow the path to the beat
- Harder precision requirement

#### 4. **Stream Patterns**
- Rapid-fire circles in quick succession
- Tests speed and consistency
- Combo breaker if you miss even one

### Difficulty Progression
- **Small Fish** - Single circles, predictable patterns
- **Medium Fish** - Mix of circles and holds, moderate speed
- **Large Fish** - Complex patterns, sliders, streams, high BPM

### Scoring System
```
Hit Quality Points:
- Perfect (300) = 3x multiplier on combo
- Good (100) = 1x multiplier
- Miss (0) = combo breaks

Combo Multiplier:
- 0-10 hits: 1x
- 11-25 hits: 1.5x
- 26-50 hits: 2x
- 51+ hits: 3x

Fish Escape Mechanic:
- Player health/progress bar fills with each hit
- Misses reduce health by 15%
- If health reaches 0 before reel completes = fish escapes
- Perfect timing adds 25% health per hit
```

### Visual Feedback
- **Hit Effect** - Explosion/splash at hit location
- **Combo Counter** - Large, animated number display
- **Fish Struggle Animation** - Fish thrashes harder on misses
- **Line Tension** - Visual indication of reel progress
- **Beat Indicator** - Visual pulse synced to music beat

### Audio Feedback
- **Hit Sounds** - Satisfying "ding" or water splash
- **Combo Break** - Distinct sound for misses
- **Music Sync** - Rhythm objects perfectly synced to track

---

## User Interface

### Main Menu
- Start Game button
- Settings (volume, difficulty)
- Leaderboards
- Credits

### HUD (During Fishing)
- Score counter (top left)
- Combo counter (center)
- Current fish type (top right)
- Time/round indicator

### HUD (During Rhythm Minigame)
- Health/progress bar (center)
- Accuracy indicator (below notes)
- Current combo
- Score accumulation

### Results Screen
- Final score
- Accuracy percentage
- Combo stats
- Fish caught
- Retry/Next Level buttons

---

## Game Progression

### Level Structure
- Songs with varying BPM and difficulty
- Each song has 3-5 fishing "rounds"
- Difficulty unlocks based on performance

### Fish Variety
```
Fish Database:
- Bass (common, easy patterns)
- Trout (medium, moderate patterns)
- Salmon (hard, complex patterns)
- Legendary Fish (rare, extreme patterns)

Each fish has:
- Spawn probability
- Rhythm pattern set
- Point value
- Visual design
```

### Upgrade System (Future)
- Better rods (faster reel speed)
- Special bait (attract rarer fish)
- Line strength (more forgiving windows)

---

## Technical Specifications

### Audio Sync
- Music beat detection
- Offset calibration (for latency)
- Note timings baked into song data files

### Song Format
```json
{
  "title": "Song Name",
  "artist": "Artist Name",
  "bpm": 120,
  "difficulty": 1-5,
  "offset_ms": 0,
  "notes": [
    {
      "time_ms": 1000,
      "type": "circle",
      "x": 400,
      "y": 300
    }
  ]
}
```

### Performance Targets
- 60 FPS stable
- Sub-50ms input latency
- Memory efficient for multiple songs loaded

---

## Visual Design

### Color Palette
- Primary: Ocean blues and teals
- Accent: Golden/orange (fish, UI highlights)
- Background: Calm water gradient

### Animation Style
- Smooth, polished easing
- Water ripple effects
- Fish struggling motions
- UI pop-in animations on score hits

### Camera
- Fixed orthographic view
- Fishing line in center
- Rhythm objects spawn from edges toward center

---

## Controls

```
Input Mapping:
- Left Mouse Click / Touch → Hit rhythm notes / Cast line
- ESC → Pause menu
- R → Restart level
- Space → Confirm menu selections
```

---

## Success Criteria

### MVP (Minimum Viable Product)
- ✓ Basic fishing UI
- ✓ One rhythm minigame mechanic (circles)
- ✓ One song with complete pattern
- ✓ Scoring system
- ✓ Pause/menu functionality

### Full Release
- ✓ 5+ songs
- ✓ Multiple rhythm object types (circles, holds, sliders)
- ✓ Fish variety (3+ species)
- ✓ Visual polish and animations
- ✓ Sound design and music
- ✓ Difficulty progression
- ✓ Leaderboards
- ✓ Settings (volume, difficulty)

---

## Known Constraints & Notes

- Godot 4.x uses GDScript (Python-like)
- No external dependencies needed (Godot is self-contained)
- Audio sync is critical - may need offset calibration
- Rhythm timing tolerance must be carefully tuned for feel
- Target 60 FPS on all platforms

---

## Feature Ideas & Brainstorming

Add your feature ideas here as you think of them. Use the format below and I'll brainstorm implementation approaches!

### Feature Idea Template
```
## Feature: [Name]
**Status:** Idea / In Progress / Implemented / Backlog

**Description:**
[What is this feature? What does it do?]

**How it works:**
[Mechanics and user flow]

**Priority:** High / Medium / Low

**Notes/Questions:**
[Any additional thoughts or questions about implementation]
```

### Example Ideas (delete and replace with your own):

## Feature: Daily Challenges
**Status:** Idea

**Description:**
Special daily fishing challenges with unique constraints and rewards

**How it works:**
- Each day gets a new challenge (e.g., "catch 5 bass without missing")
- Special reward multiplier for completing daily
- Tracks streak of consecutive days completed

**Priority:** Medium

**Notes:**
Maybe add visual badge on menu for completing daily?

---

## Feature: Leaderboards
**Status:** Idea

**Description:**
Global or local leaderboards tracking high scores

**How it works:**
- Score-based ranking for each song
- Local leaderboard (saved to device)
- Optional cloud sync for global rankings

**Priority:** Medium

**Notes:**
Could be motivating for replayability
