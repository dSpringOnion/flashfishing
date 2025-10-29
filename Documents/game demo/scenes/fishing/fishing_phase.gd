extends Node2D
class_name FishingPhase

## Fishing Phase Scene
## Player casts line and waits for fish to bite
## When fish bites, transitions to rhythm minigame

# ============================================================================
# CONSTANTS
# ============================================================================

const FISH_SPAWN_CHECK_INTERVAL: float = 1.0  # Check for spawns every 1 second
const MIN_SPAWN_DELAY: float = 2.0             # Minimum time before first fish
const MAX_SPAWN_DELAY: float = 8.0             # Maximum time between fish

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

@onready var cast_button: Button = $UI/CastButton
@onready var timer_label: Label = $UI/TimerLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var area_label: Label = $UI/AreaLabel
@onready var status_label: Label = $UI/StatusLabel

var time_remaining: int = 60  # Seconds per round
var has_cast: bool = false
var is_waiting_for_bite: bool = false
var next_spawn_time: float = MIN_SPAWN_DELAY
var time_since_last_spawn: float = 0.0

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("FishingPhase initialized")
	_setup_ui()
	_connect_signals()
	_initialize_fishing()

func _process(delta: float) -> void:
	## Main game loop
	if not has_cast:
		return

	# Update timer
	time_remaining -= delta
	if time_remaining <= 0:
		_on_time_expired()
		return

	timer_label.text = "Time: %02d:%02d" % [int(time_remaining) / 60, int(time_remaining) % 60]

	# Check for fish spawn
	if is_waiting_for_bite:
		time_since_last_spawn += delta
		if time_since_last_spawn >= next_spawn_time:
			_spawn_fish()

# ============================================================================
# INITIALIZATION
# ============================================================================

func _setup_ui() -> void:
	## Configure UI elements
	area_label.text = "Area: %s" % GameManager.current_area
	score_label.text = "Score: %d" % GameManager.player_data.total_score
	status_label.text = "Click CAST to start fishing"
	cast_button.text = "CAST"
	cast_button.custom_minimum_size = Vector2(200, 50)
	cast_button.add_theme_font_size_override("font_size", 20)

func _connect_signals() -> void:
	## Connect button and system signals
	cast_button.pressed.connect(_on_cast_pressed)
	GameManager.state_changed.connect(_on_game_state_changed)

func _initialize_fishing() -> void:
	## Initialize fishing state
	print("Fishing phase started in area: %s" % GameManager.current_area)

# ============================================================================
# FISHING MECHANICS
# ============================================================================

func _on_cast_pressed() -> void:
	## Player casts fishing line
	if not has_cast:
		print("Casting line...")
		has_cast = true
		is_waiting_for_bite = true
		cast_button.disabled = true
		cast_button.text = "WAITING..."
		status_label.text = "Waiting for a bite..."
		_calculate_next_spawn()

func _calculate_next_spawn() -> void:
	## Calculate when next fish will spawn
	next_spawn_time = randf_range(MIN_SPAWN_DELAY, MAX_SPAWN_DELAY)
	time_since_last_spawn = 0.0
	print("Next fish spawn in: %.1f seconds" % next_spawn_time)

func _spawn_fish() -> void:
	## Spawn a fish and transition to rhythm minigame
	print("Fish spawned!")

	# TODO: Get random fish from area's fish pool
	# For now, use a test fish
	var test_fish = {
		"id": "yellow_perch_01",
		"common_name": "Yellow Perch",
		"tier": 1,
		"genus": "Perch"
	}

	GameManager.spawn_fish(test_fish)
	status_label.text = "A %s is biting!" % test_fish["common_name"]

	# Transition to rhythm minigame
	await get_tree().create_timer(0.5).timeout
	_transition_to_rhythm_minigame()

func _transition_to_rhythm_minigame() -> void:
	## Switch to rhythm minigame
	print("Transitioning to rhythm minigame...")
	GameManager.current_state = GameManager.GameState.RHYTHM
	# TODO: Load rhythm minigame scene when ready
	# SceneManager.change_scene("res://scenes/rhythm/rhythm_minigame.tscn")

func _on_time_expired() -> void:
	## Time ran out - level failed
	print("Time expired - fishing round ended")
	status_label.text = "Time's up!"
	has_cast = false
	cast_button.disabled = false
	is_waiting_for_bite = false
	# TODO: Go to results screen
	# GameManager.current_state = GameManager.GameState.RESULTS

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	## Handle game state changes
	if new_state == GameManager.GameState.PAUSED:
		set_process(false)
		set_physics_process(false)
	elif new_state == GameManager.GameState.FISHING:
		set_process(true)
		set_physics_process(true)

# ============================================================================
# DEBUG
# ============================================================================

func print_debug_info() -> void:
	print("FishingPhase:")
	print("  Area: %s" % GameManager.current_area)
	print("  Time remaining: %d" % time_remaining)
	print("  Has cast: %s" % has_cast)
	print("  Waiting for bite: %s" % is_waiting_for_bite)
