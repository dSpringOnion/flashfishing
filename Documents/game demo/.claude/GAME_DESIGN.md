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
  - Rod upgrades (dual-path system - see below)
  - Special baits (increase spawn rate of specific fish)
  - New fishing locations/areas
  - Cosmetics and customization

### Rod Upgrade System (Dual Path)

#### **Path 1: Casual/Accessibility Rods**
- **Focus:** Easier gameplay, forgiving mechanics
- **Benefits:**
  - Larger timing windows (±75ms instead of ±50ms for Perfect)
  - Slower reel speed (more time to hit notes)
  - More health per hit (easier to avoid fish escape)
  - Lower skill floor = more accessible
- **Score Impact:** Standard multipliers (no penalty, no bonus)
- **Use Case:** Players wanting relaxing experience or learning rhythm patterns

#### **Path 2: Hardcore/Mastery Rods**
- **Focus:** Challenge + reward hardcore players
- **Changes:**
  - Smaller timing windows (±40ms for Perfect, ±80ms for Good)
  - Faster reel speed (punishing if you miss timing)
  - Less health per hit (one mistake costs more)
  - Dangerous but skillful
- **Score Impact:** Increased multiplier scaling
  - Casual: 1x base multiplier
  - Hardcore: 1.5x-2x base multiplier depending on rod tier
  - Hardcore Perfect = 4x multiplier (vs 3x casual)
- **Prestige Factor:** Leaderboard badge/title for hardcore rod clears
- **Use Case:** Hardcore players seeking challenge and high scores

#### **Rod Progression in Each Path**
```
Casual Path:                    Hardcore Path:
1. Beginner Rod (baseline)      1. Beginner Rod (baseline)
   ↓                               ↓
2. Comfort Rod                  2. Challenge Rod
   (large windows)                 (smaller windows, +1.5x mult)
   ↓                               ↓
3. Expert Comfort Rod           3. Master Rod
   (huge forgiveness)              (tight windows, +1.75x mult)
   ↓                               ↓
4. Zen Master Rod               4. Legendary Rod
   (ultimate chill)                (extreme difficulty, +2x mult)
```

#### **Player Choice**
- Choice can be made in settings/gear selection before each level
- Different leaderboards for casual vs hardcore (or separate leaderboard categories)
- Players can master both paths if they want
- Progression doesn't lock you into one path

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

### ✅ Dual-Path Rod Progression System
**Status:** Planned
**Details:** See "Rod Upgrade System (Dual Path)" section
- **Casual Path:** Forgiving timing windows, more health, lower skill floor
- **Hardcore Path:** Tighter windows, faster reel, higher score multipliers (1.5x-2x)
- Players choose path before each level
- Separate progression tracks but both unlock through mastery
- Prestige badges for hardcore clears
- Enables accessibility without compromising hardcore appeal

---

---

## Story & World Setting

### Game Narrative
You're a seasoned angler discovering a magical fishing expedition across diverse ecosystems. Each location holds unique fish species, each with their own personality, difficulty level, and music personality. Master the rhythm of nature to catch them all.

### Visual Themes & Progression Flow
```
BEGINNER JOURNEY:
Calm Creek → Peaceful River → Coastal Bay → Deep Ocean

Visual Progression:
Pastel/Serene → Warm/Golden → Dynamic/Colorful → Dark/Mysterious
```

---

## Fishing Areas & Ecosystems

### Area 1: Calm Creek (Beginner)
**Setting:** Peaceful freshwater stream in spring/summer
**Visual Aesthetic:** Soft pastels, gentle water, wildflowers, warm sunlight
**Music Vibe:** Acoustic guitar, lo-fi, ambient sounds
**Difficulty:** 1-2 stars

#### Fish Genus: **Perch** (Percidae Family)
Calm, deliberate movements. Players learn basic mechanics here.

**Tier 1 Species:**
- **Yellow Perch** (*Perca flavescens*)
  - Size: Small (4-8 inches)
  - Rarity: Very Common
  - Pattern: Simple circles (taps), acoustic folk rhythm
  - Visual: Golden-yellow with green stripes
  - Spawn probability: Base 100%
  - Behavior: Curious, easy to catch

**Tier 2 Species:**
- **White Perch** (*Morone americana*)
  - Size: Medium (6-10 inches)
  - Rarity: Common
  - Pattern: Mix of circles + hold notes, fingerpicking acoustic
  - Visual: Silver body with darker stripes
  - Spawn probability: 60% (unlock after catching 5 Yellow Perch)
  - Behavior: More cautious than Yellow Perch

**Tier 3 Species:**
- **Black Crappie** (*Pomoxis nigromaculatus*) [Sunfish family]
  - Size: Medium-Large (8-12 inches)
  - Rarity: Uncommon
  - Pattern: Circles + holds + short streams, classical acoustic arrangements
  - Visual: Dark with mottled patterns, distinctive shape
  - Spawn probability: 30% (unlock after mastery level 2)
  - Behavior: Crafty, requires precision

---

### Area 2: Golden River (Intermediate)
**Setting:** Flowing river during golden hour (dawn/dusk)
**Visual Aesthetic:** Warm golds, amber lighting, rustling reeds, dynamic water flow
**Music Vibe:** Jazz, blues, syncopated rhythms, upright bass
**Difficulty:** 3-4 stars

#### Fish Genus: **Salmon** (Salmonidae Family)
Determined, powerful movements. Players learn complex patterns.

**Tier 2 Species:**
- **Atlantic Salmon** (*Salmo salar*)
  - Size: Large (20-30 inches)
  - Rarity: Uncommon
  - Pattern: Circles + holds + sliders, smooth jazz melodies
  - Visual: Silvery with brown spots, powerful frame
  - Spawn probability: 40% (unlock by reaching Area 2)
  - Behavior: Strong fighter, requires stamina

**Tier 3 Species:**
- **Chinook/King Salmon** (*Oncorhynchus tshawytscha*)
  - Size: Very Large (36-50+ inches)
  - Rarity: Rare
  - Pattern: Complex sliders + streams, bebop jazz complexity
  - Visual: Dark greenish-brown, massive, intimidating
  - Spawn probability: 20% (high accuracy = higher chance for legendary variant)
  - Behavior: Legendary strength, most challenging in this area

**Tier 4 Species:**
- **Coho Salmon** (*Oncorhynchus kisutch*)
  - Size: Large (24-36 inches)
  - Rarity: Uncommon-Rare
  - Pattern: Balanced circles/holds/sliders, swinging jazz rhythms
  - Visual: Silver with dark back, distinctive black gums
  - Spawn probability: 35% (unlock after Mastery level 2)
  - Behavior: Acrobatic, flashy movements

---

### Area 3: Coastal Bay (Advanced)
**Setting:** Estuary where river meets ocean, salt/fresh water mixing
**Visual Aesthetic:** Dynamic blues, crashing waves, seagulls, reef rocks
**Music Vibe:** Drum & Bass, Breakbeats, High-energy electronic
**Difficulty:** 4-5 stars

#### Fish Genus: **Drum** (Sciaenidae Family)
Explosive, energetic movements. Players face intense rhythm challenges.

**Tier 3 Species:**
- **Freshwater Drum** (*Aplodinotus grunniens*)
  - Size: Medium-Large (12-18 inches)
  - Rarity: Uncommon
  - Pattern: Rapid streams, early drum & bass (120 BPM)
  - Visual: Silvery-brown with hard head, distinctive appearance
  - Spawn probability: 50% (unlock by reaching Area 3)
  - Behavior: Quick, responsive, tests speed

**Tier 4 Species:**
- **Red Drum/Redfish** (*Sciaenops ocellatus*)
  - Size: Very Large (24-40+ inches)
  - Rarity: Rare
  - Pattern: Complex streams + sliders, liquid drum & bass (170 BPM)
  - Visual: Copper-bronze color, distinctive black spot(s) near tail
  - Spawn probability: 25% (high mastery = legendary variant chance)
  - Behavior: Powerful, aggressive, high-stakes

**Tier 4 Species:**
- **Black Drum** (*Pogonias cromis*)
  - Size: Massive (30-50+ inches)
  - Rarity: Very Rare
  - Pattern: Extreme streams + complex sliders, breakcore (200+ BPM)
  - Visual: Dark gray-black, massive, prehistoric looking
  - Spawn probability: 10% (legendary fish, requires mastery + high accuracy)
  - Behavior: Ultimate challenge, rewards 3x multiplier on hardcore rods

---

### Area 4: Deep Ocean (Expert/Legendary)
**Setting:** Open ocean, deep waters, bioluminescent creatures
**Visual Aesthetic:** Deep blues/purples, mysterious glows, otherworldly
**Music Vibe:** Orchestral, Experimental, Ambient Hyperpop fusion
**Difficulty:** 5 stars

#### Fish Genus: **Predators** (Mixed families, Legendary status)
Mythical, pattern-breaking movements. Only for masters.

**Tier 5 Species (Legendary):**
- **Swordfish** (*Xiphias gladius*)
  - Size: Legendary (60-72+ inches)
  - Rarity: Extremely Rare (only 5% spawn chance)
  - Pattern: Chaotic sliders + reverse notes, orchestral ambience + glitch
  - Visual: Massive, dark, iconic sword-like bill
  - Spawn probability: 5% (requires mastery level 3+ on all Area 3 fish)
  - Behavior: Unpredictable, demands perfect accuracy

- **Phantom Pike** (Fantasy species)
  - Size: Mysterious
  - Rarity: Mythical (1% spawn chance)
  - Pattern: Random pattern mixing all mechanics, avant-garde experimental
  - Visual: Ethereal, glowing, genre-defying
  - Spawn probability: 1% (Easter egg, pure RNG luck)
  - Behavior: Reality-bending, for bragging rights

---

## Fish Database Technical Reference

```
Fish Structure:
{
  "id": "yellow_perch_01",
  "common_name": "Yellow Perch",
  "scientific_name": "Perca flavescens",
  "genus": "Perch",
  "tier": 1,
  "area": "Calm Creek",
  "size_inches": [4, 8],
  "color": "Golden-yellow with green stripes",
  "rarity": "Very Common",
  "spawn_chance": 100,
  "unlock_condition": "None",
  "music_genre": "Acoustic Folk",
  "pattern_type": ["circle"],
  "pattern_difficulty": 1,
  "bpm_range": [90, 110],
  "base_points": 100,
  "size_variant_multiplier": 1.0,
  "mastery_reward": 5
}
```

---

## Area Progression Gates

```
Area 1: Calm Creek
├── Unlock: Game start
├── Min mastery to progress: 5 total points
└── Storyline: "Learn the basics in peaceful waters"

Area 2: Golden River
├── Unlock: Complete Area 1, catch 10+ Perch genus fish
├── Min mastery to progress: 30 total points OR 10 points in Perch genus
└── Storyline: "Follow the river upstream to discover stronger fish"

Area 3: Coastal Bay
├── Unlock: Complete Area 2, reach mastery level 2 in any fish
├── Min mastery to progress: 60 total points OR 20 points in Salmon genus
└── Storyline: "The ocean calls with its rhythmic energy"

Area 4: Deep Ocean
├── Unlock: Complete Area 3, reach mastery level 3 in Drum genus
├── Min mastery to progress: 100+ total points
└── Storyline: "Beyond all known waters, legends await"
```

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
