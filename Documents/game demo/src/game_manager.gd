extends Node
class_name GameManager

## Central game state manager
## Handles game flow, state transitions, and global coordination
## Accessed globally via: GameManager.method_name()

# ============================================================================
# ENUMS & CONSTANTS
# ============================================================================

enum GameState {
	MENU,
	LEVEL_SELECT,
	FISHING,
	RHYTHM,
	RESULTS,
	PAUSED
}

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

var current_state: GameState = GameState.MENU:
	set(value):
		if value != current_state:
			_on_state_transition(current_state, value)
			current_state = value
			state_changed.emit(value)

var current_area: String = "area_1"  # Fishing location
var current_level: String = ""       # Beat map ID
var current_fish: Dictionary = {}    # Active fish being caught
var player_data: PlayerData = null   # Player progression

# ============================================================================
# SIGNALS
# ============================================================================

signal state_changed(new_state: GameState)
signal area_changed(area: String)
signal fish_spawned(fish: Dictionary)
signal fish_caught(fish: Dictionary, score: int)
signal level_completed(score: int)
signal game_paused()
signal game_resumed()

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("GameManager initialized")
	_initialize_systems()

func _exit_tree() -> void:
	print("GameManager shutdown")

# ============================================================================
# INITIALIZATION
# ============================================================================

func _initialize_systems() -> void:
	## Initialize player data and load progression
	player_data = PlayerData.new()
	# In future: load from save file
	print("Systems initialized: Player data ready")

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

func _on_state_transition(old_state: GameState, new_state: GameState) -> void:
	## Called when transitioning between states
	var old_name = GameState.keys()[old_state]
	var new_name = GameState.keys()[new_state]
	print("State transition: %s → %s" % [old_name, new_name])

func change_state(new_state: GameState) -> void:
	## Explicitly change game state
	current_state = new_state

func get_state_name() -> String:
	## Get human-readable state name
	return GameState.keys()[current_state]

# ============================================================================
# AREA MANAGEMENT
# ============================================================================

func set_current_area(area: String) -> void:
	## Change fishing area
	if area != current_area:
		current_area = area
		area_changed.emit(area)
		print("Area changed to: %s" % area)

func get_current_area() -> String:
	return current_area

# ============================================================================
# FISHING OPERATIONS
# ============================================================================

func spawn_fish(fish_data: Dictionary) -> void:
	## Fish spawned during fishing phase
	current_fish = fish_data
	fish_spawned.emit(fish_data)
	print("Fish spawned: %s" % fish_data.get("common_name", "Unknown"))

func catch_fish(score: int) -> void:
	## Fish successfully caught after rhythm minigame
	var fish_name = current_fish.get("common_name", "Unknown Fish")
	print("Fish caught: %s (Score: %d)" % [fish_name, score])

	# Update player progression
	if player_data:
		player_data.add_fish_caught(current_fish.get("id"), score)

	fish_caught.emit(current_fish, score)
	current_fish = {}

func escape_fish() -> void:
	## Fish escaped during rhythm minigame
	var fish_name = current_fish.get("common_name", "Unknown Fish")
	print("Fish escaped: %s" % fish_name)
	current_fish = {}

# ============================================================================
# LEVEL MANAGEMENT
# ============================================================================

func set_current_level(level_id: String) -> void:
	## Set active beat map/level
	current_level = level_id
	print("Level set to: %s" % level_id)

func get_current_level() -> String:
	return current_level

func complete_level(final_score: int) -> void:
	## Called when level ends (win or lose)
	if player_data:
		player_data.update_high_score(current_level, final_score)

	level_completed.emit(final_score)
	print("Level completed with score: %d" % final_score)

# ============================================================================
# PAUSE SYSTEM
# ============================================================================

func pause_game() -> void:
	## Pause the game
	if current_state != GameState.PAUSED:
		get_tree().paused = true
		current_state = GameState.PAUSED
		game_paused.emit()
		print("Game paused")

func resume_game() -> void:
	## Resume the game
	if current_state == GameState.PAUSED:
		get_tree().paused = false
		# Restore previous state (for now, just go to menu)
		current_state = GameState.MENU
		game_resumed.emit()
		print("Game resumed")

# ============================================================================
# DEBUG & UTILITIES
# ============================================================================

func get_debug_info() -> Dictionary:
	## Return debug information
	return {
		"current_state": get_state_name(),
		"current_area": current_area,
		"current_level": current_level,
		"current_fish": current_fish.get("common_name", "None"),
		"player_score": player_data.total_score if player_data else 0
	}

func print_debug_info() -> void:
	## Print debug information to console
	var info = get_debug_info()
	print("\n=== GAME DEBUG INFO ===")
	for key in info:
		print("%s: %s" % [key, info[key]])
	print("=======================\n")
