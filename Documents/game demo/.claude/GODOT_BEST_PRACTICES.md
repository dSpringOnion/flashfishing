# Godot 4.x Best Practices Guide for Rhythm Fishing

Based on official Godot documentation, community resources, and game development patterns.

---

## Project Organization

### Folder Structure
```
rhythm-fishing/
├── src/                          # Autoload scripts (singletons)
│   ├── game_manager.gd
│   ├── scene_manager.gd
│   ├── input_manager.gd
│   ├── audio_manager.gd
│   └── progression_manager.gd
├── scenes/                       # Scene files (.tscn)
│   ├── ui/
│   ├── fishing/
│   ├── rhythm/
│   └── ...
├── assets/                       # Game assets (not source files)
│   ├── sprites/
│   ├── audio/
│   └── fonts/
├── data/                         # Data files (JSON, resources)
│   ├── fish/
│   ├── beat_maps/
│   └── settings.json
└── project.godot
```

### Naming Conventions
- **Folders:** snake_case (e.g., `game_manager`, `ui_scenes`)
- **Scene files (.tscn):** snake_case (e.g., `main_menu.tscn`)
- **Script files (.gd):** snake_case (e.g., `game_manager.gd`)
- **Node names in scenes:** PascalCase (e.g., `MainContainer`, `PlayButton`)
- **Class names (class_name declaration):** PascalCase matching filename without .gd

Example:
```
File: scenes/ui/main_menu.gd
class_name MainMenu
```

### Organization Strategy
- **DO NOT** organize by asset type (all sprites in one folder, all scenes in another)
- **DO** organize by game feature/system (all menu-related scenes and scripts together)
- **Example:** `scenes/ui/main_menu/main_menu.tscn` + `scenes/ui/main_menu/main_menu.gd`

---

## Godot Architecture Patterns

### 1. Autoload/Singleton System

**What it is:**
- Godot's built-in singleton system
- Automatically instantiates scenes/scripts at game start
- Persists across scene changes
- Accessed via global name

**When to use:**
✅ Global game state (GameManager)
✅ Configuration/settings
✅ Event buses (via signals)
✅ Services that many nodes access
✅ Save/persistence systems

**When NOT to use:**
❌ Data that needs to be saved/loaded from files (use Resources instead)
❌ Per-instance data (create regular nodes instead)
❌ Things that don't need global lifetime

**Setup in Project Settings:**
```
Project → Project Settings → Autoload tab
- Add script file
- Name it (this becomes the global variable name)
- GDScript must extend Node
```

**Best Practices:**
- Keep autoloads minimal and focused
- Use signals for communication (don't tightly couple)
- Don't store player save data in autoloads directly
- Each autoload should have a single responsibility

---

### 2. Signals & Observer Pattern

**Godot 4 Features:**
- Typed signals with parameters
- `await` keyword for asynchronous operations (replaces yield)
- Built-in observer pattern implementation

**Best Practices:**

#### Define Signals Clearly
```gdscript
extends Node
class_name GameManager

# Typed signals with clear names
signal game_state_changed(new_state: GameState)
signal fish_caught(fish_data: Dictionary)
signal level_completed(score: int)
signal audio_ready()

enum GameState { MENU, FISHING, RHYTHM, RESULTS }
```

#### Connect Carefully
```gdscript
# Good: Connect with signal name (type-safe in Godot 4)
button.pressed.connect(_on_button_pressed)

# Avoid: String-based connections (error-prone)
button.connect("pressed", Callable(self, "_on_button_pressed"))
```

#### Use Await for Async Operations
```gdscript
# Wait for a signal to emit before continuing
await game_manager.fish_caught
print("Fish caught!")

# Wait with timeout
if await game_manager.audio_ready.wait_timeout(5.0):
    print("Audio loaded")
else:
    print("Audio loading timed out")
```

#### Avoid Over-Signaling
- Don't emit signals excessively
- If you're emitting a signal just to re-emit from a parent, don't do it
- Use signals for major state changes, not every small event

---

### 3. Scene & Node Composition

**Godot Philosophy:**
- Scenes are first-class citizens
- Favor composition over inheritance
- Build complex behavior from simple, reusable scenes

**Best Practices:**

#### Scene Hierarchy
```
Use meaningful, single-responsibility scenes:

GoodDesign:
- MainMenu (self-contained scene)
- FishingPhase (self-contained scene)
- RhythmMinigame (self-contained scene)
- Note (reusable component)
- HUDDisplay (reusable component)

AvoidDesign:
- Everything in one giant scene
- Deeply nested scenes (more than 2-3 levels)
```

#### Node Structure in Scenes
```gdscript
# Logical, clear hierarchy
FishingPhase
├── Background (CanvasLayer)
├── GameArea
│   ├── Bobber
│   ├── Water (AnimatedSprite)
│   └── Fish (AnimatedSprite)
├── HUD
│   ├── ScoreLabel
│   ├── TimerLabel
│   └── CastButton
└── AudioPlayer
```

#### Instancing
```gdscript
# In editor: Drag scene into another scene
# In code:
var note = preload("res://scenes/rhythm/note.tscn").instantiate()
add_child(note)

# Store references to avoid repeated loads
var note_scene = preload("res://scenes/rhythm/note.tscn")
# Use note_scene.instantiate() multiple times
```

---

### 4. State Management & State Machine

**Pattern Choice for Rhythm Fishing:**
Use **Enum-based approach** for simplicity, with signals for state transitions

**Why:**
- Rhythm Fishing has simple, well-defined states
- Enum is performant and easy to debug
- Signals handle communication cleanly
- Easier than complex State node pattern

**Implementation:**

```gdscript
extends Node
class_name GameManager

enum GameState { MENU, LEVEL_SELECT, FISHING, RHYTHM, RESULTS, PAUSED }

var current_state: GameState = GameState.MENU:
    set(value):
        if value != current_state:
            _on_state_changed(current_state, value)
            current_state = value
            state_changed.emit(value)

signal state_changed(new_state: GameState)

func _on_state_changed(old_state: GameState, new_state: GameState) -> void:
    print("State transition: %s → %s" % [old_state, new_state])
    match new_state:
        GameState.MENU:
            _setup_menu()
        GameState.FISHING:
            _setup_fishing()
        GameState.RHYTHM:
            _setup_rhythm()
        # ... etc
```

---

### 5. Error Handling & Type Safety

**Use Static Typing:**
```gdscript
# Good: Type hints for clarity and safety
func calculate_score(hits: int, combo: int) -> int:
    return hits * combo

# Avoid: Loose typing
func calculate_score(hits, combo):
    return hits * combo
```

**Null Safety:**
```gdscript
# Check before accessing
if node != null:
    node.position = Vector2(100, 100)

# Or use optional chaining pattern
var fish_data: Dictionary = get_fish_or_null()
if fish_data:
    print(fish_data.get("name", "Unknown"))
```

**Return Types for Clear Contracts:**
```gdscript
# Clear what function returns
func load_fish_database() -> Array[Dictionary]:
    return []

func get_current_fish() -> Dictionary:
    return current_fish_data

func is_valid_beat_timing(actual_ms: int, expected_ms: int) -> bool:
    return abs(actual_ms - expected_ms) <= 100
```

---

## Core Principles for Rhythm Fishing

### 1. Separation of Concerns
- **GameManager** - State and high-level logic only
- **SceneManager** - Scene loading and transitions
- **InputManager** - Input handling
- **AudioManager** - Audio playback and sync
- **FishingPhase** - Fishing mechanics only
- **RhythmMinigame** - Rhythm mechanics only

Each system should have ONE primary responsibility.

### 2. Communication via Signals
```gdscript
# Instead of:
audio_manager.stop_music()  # Direct call

# Use:
game_manager.state_changed.emit(GameState.MENU)  # Signal
# AudioManager listens and reacts
```

### 3. Decoupling Systems
- Scenes don't directly reference each other
- Systems communicate via GameManager signals
- No scene should need to know about another scene's internals

Example:
```gdscript
# FishingPhase doesn't know about RhythmMinigame
# When fish bites:
game_manager.current_fish = spawned_fish
game_manager.current_state = GameState.RHYTHM

# RhythmMinigame listens for state change:
game_manager.state_changed.connect(_on_game_state_changed)
```

### 4. Data vs. Logic Separation
```gdscript
# Store data
var fish_data = {
    "id": "yellow_perch",
    "spawn_chance": 100
}

# Keep logic in managers
# Don't put game logic inside data files
```

---

## Performance Considerations

### Memory Management
- Use `preload()` for assets loaded at startup
- Use `load()` for optional/dynamic assets
- Always `queue_free()` instead of `free()` for nodes
- Store frequently-used scenes in variables to avoid repeated preloads

### Frame Rate & Timing
- Use `_process()` for gameplay logic
- Use `_physics_process()` for physics (60 Hz even if render drops)
- Use `get_ticks_msec()` for timing-critical operations
- For audio sync: use `AudioStreamPlayer.get_playback_position()`

### Signals Performance
- Signal emission is very fast (micro-optimizations unnecessary)
- Avoid creating signals dynamically
- Disconnect signals when nodes are freed

---

## Testing & Debugging

### Debug Prints
```gdscript
# Use print() liberally during development
print("State: ", current_state)
print("Fish caught: ", current_fish)

# Use assert() for assumptions
assert(current_state != null, "State should never be null")
```

### Scene Debugging
- Godot debugger shows scene tree
- Inspect node properties in real-time
- Use breakpoints in VSCode

---

## Code Style for Rhythm Fishing

```gdscript
extends Node
class_name GameManager

# Constants at top
const MAX_HEALTH: int = 100
const DEFAULT_BPM: int = 120

# Member variables (private with underscore)
var _current_state: GameState = GameState.MENU
var _player_data: PlayerData

# Signals after variables
signal state_changed(new_state: GameState)
signal fish_caught(fish: Dictionary)

# _ready() runs when node enters scene tree
func _ready() -> void:
    _initialize_systems()

# _process() runs every frame
func _process(delta: float) -> void:
    pass

# Public methods
func change_state(new_state: GameState) -> void:
    _current_state = new_state
    state_changed.emit(new_state)

# Private methods (with underscore prefix)
func _initialize_systems() -> void:
    pass

# Lifecycle methods at end
func _exit_tree() -> void:
    # Cleanup
    pass
```

---

## Summary: What We'll Follow

1. ✅ **Autoload singletons** for core managers (GameManager, SceneManager, etc.)
2. ✅ **Signals & await** for inter-system communication
3. ✅ **Enum-based state machine** for game flow
4. ✅ **Scene composition** over inheritance
5. ✅ **Static typing** for safety
6. ✅ **Clear separation of concerns** (each system has one job)
7. ✅ **snake_case** for files and folders
8. ✅ **PascalCase** for node names and class names
9. ✅ **Preload** for frequently-used scenes
10. ✅ **queue_free()** for node cleanup

---

## Resources Referenced
- Official Godot 4 Documentation (Project Organization, Singletons, Signals)
- GDQuest design patterns tutorials
- Godot community best practices
- Game Development Patterns with Godot 4 (book)
