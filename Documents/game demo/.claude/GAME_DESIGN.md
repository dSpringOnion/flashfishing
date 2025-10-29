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

### Fish Variety & Genus System
```
Fish Database organized by Genus & Tier:

Perch Genus (Acoustic vibe):
- Perch (Tier 1) - Simple taps, calm rhythms
- Golden Perch (Tier 2) - Adds hold notes
- Nile Perch (Tier 3) - Complex patterns

Salmon Genus (Jazz vibe):
- Atlantic Salmon (Tier 2) - Moderate complexity
- Chinook Salmon (Tier 3) - Syncopated patterns
- King Salmon (Tier 4) - Advanced jazz rhythms

Drum Genus (Drum & Bass vibe):
- Red Drum (Tier 3) - Fast streams, high energy
- Black Drum (Tier 4) - Extreme complexity, sliders

Each fish has:
- Spawn probability (base, boosted by mastery/area)
- Rhythm pattern set (synced to genre music)
- Point value
- Visual design
- Size variants (small, medium, large, legendary)
- Unlock conditions (area/tier progression)
```

### Size Variants & Rarity System
- **Score-based Yield** - Higher accuracy = higher chance for larger/rarer variants
  - Perfect accuracy (95%+) = 50% chance for legendary variant
  - Good accuracy (80-95%) = 25% chance for large variant
  - Normal accuracy (<80%) = standard/small variants guaranteed
- Each catch is NOT guaranteed but probability scales with performance
- Larger fish = better points and mastery progression

### Mastery & Progression System
- **Mastery Levels** - Track progress per fish species/genus
- **Mastery Unlocks:**
  - Better rods (faster reel speed, more forgiving timing windows)
  - Special baits (increase spawn rate of specific fish)
  - New fishing locations/areas
  - Cosmetics and customization

### Area Progression System
- **Area Tiers** - Multiple fishing locations unlock as you progress
- **Progression Gates:**
  - Area 1: Unlock with any fish caught
  - Area 2: Unlock with 50 mastery points across all fish
  - Area 3: Unlock with specific fish mastery (e.g., catch rare variants)
- **Each Area Introduces:**
  - New fish genus with new mechanics
  - Higher difficulty patterns
  - New music genre/aesthetic
  - Themed visual environment

---

## Technical Specifications

### Audio Sync
- Music beat detection
- Offset calibration (for latency)
- Note timings baked into song data files

### Song Format & Music Composition
- **Music Framework:** Strudel (live coding music environment)
- **Workflow:** Create music patterns in Strudel → Export as tracks + beat maps
- **Beat Map Format:**
```json
{
  "title": "Song Name",
  "artist": "Artist Name",
  "bpm": 120,
  "genre": "acoustic|jazz|dnb",
  "difficulty": 1-5,
  "offset_ms": 0,
  "target_fish_genus": ["Perch", "Salmon"],
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
- **Genre Mapping:** Fish genus tied to music genre for thematic coherence
  - Perch → Acoustic (calm, mellow)
  - Salmon → Jazz (syncopated, complex)
  - Drum → Drum & Bass (fast, energetic)

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

---

## Planned Features (from Brainstorming)

These ideas have been integrated into the game design above. Check the sections they're referenced in:

### ✅ Score-based Yield & Rarity System
**Status:** Planned
**Details:** See "Size Variants & Rarity System" section
- Higher accuracy = higher chance for larger/rarer fish variants
- Probability-based (not guaranteed) for a satisfying progression curve
- Incentivizes skill improvement

### ✅ Mastery & Progression System
**Status:** Planned
**Details:** See "Mastery & Progression System" section
- Track progress per fish species
- Unlocks: better rods, special baits, new areas, cosmetics

### ✅ Area Progression with Mechanic Introduction
**Status:** Planned
**Details:** See "Area Progression System" section
- Each area unlocks new fish genus with new mechanics
- Tier 1: Circles (taps) → Tier 2: Holds → Tier 3: Sliders → Tier 4: Streams
- Natural difficulty curve for players to learn

### ✅ Fish Genus System with Genre Mapping
**Status:** Planned
**Details:** See "Fish Variety & Genus System" section
- Each genus tied to music genre (Perch=Acoustic, Salmon=Jazz, Drum=Drum&Bass)
- Same genus shares similar beat maps for recognition/collection appeal
- Higher tier species introduce genre-appropriate mechanic complexity

### ✅ Strudel-based Music Composition
**Status:** Planned
**Details:** See "Song Format & Music Composition" section
- Use Strudel for live coding music patterns
- Export as audio tracks + beat map JSON
- Genre and target fish genus metadata in beat maps

---

## Feature Ideas & Brainstorming

**Just write your ideas here!** No formatting needed. I'll read them and figure out how to implement them.

### Quick Ideas / Brain Dump
-
-
-

### Ideas Worth Exploring
-
-
-
