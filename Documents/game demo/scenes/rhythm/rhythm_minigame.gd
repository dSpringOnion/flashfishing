extends Node2D
class_name RhythmMinigame

## Rhythm Minigame Scene
## Player hits rhythm notes to the beat to reel in the fish
## Based on osu! mechanics with fishing theme

# ============================================================================
# CONSTANTS
# ============================================================================

const NOTE_SPAWN_AHEAD_MS: int = 500  # Spawn notes 500ms before they're hittable
const COMBO_MULTIPLIER_BREAKPOINTS = [
	{"hits": 0, "multiplier": 1.0},
	{"hits": 10, "multiplier": 1.5},
	{"hits": 25, "multiplier": 2.0},
	{"hits": 50, "multiplier": 3.0}
]

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var combo_label: Label = $UI/ComboLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var accuracy_label: Label = $UI/AccuracyLabel
@onready var notes_container: Node2D = $NotesContainer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var current_fish: Dictionary = {}
var current_beat_map: Dictionary = {}
var current_song_path: String = ""

# Game state
var health: int = 100
var max_health: int = 100
var current_score: int = 0
var combo: int = 0
var max_combo: int = 0
var total_notes: int = 0
var notes_hit: int = 0
var perfect_hits: int = 0
var good_hits: int = 0
var miss_count: int = 0

# Timing
var music_started_at: int = 0
var current_note_index: int = 0
var active_notes: Array[Note] = []

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("RhythmMinigame initialized")
	_setup_ui()
	_connect_signals()
	_initialize_minigame()

func _process(delta: float) -> void:
	## Main game loop
	if not audio_player.playing:
		return

	var current_time_ms = _get_audio_time_ms()

	# Spawn new notes
	_spawn_notes_for_time(current_time_ms)

	# Check for expired notes
	_check_expired_notes(current_time_ms)

	# Update visual feedback
	_update_display()

	# Check win/lose conditions
	if health <= 0:
		_on_fish_escaped()
	elif notes_hit == total_notes and total_notes > 0:
		_on_fish_caught()

# ============================================================================
# INITIALIZATION
# ============================================================================

func _setup_ui() -> void:
	## Configure UI elements
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.custom_minimum_size = Vector2(400, 40)

	combo_label.text = "Combo: 0"
	score_label.text = "Score: 0"
	accuracy_label.text = "Accuracy: 0%"

func _connect_signals() -> void:
	## Connect input and system signals
	InputManager.click_detected.connect(_on_click_detected)
	GameManager.state_changed.connect(_on_game_state_changed)

func _initialize_minigame() -> void:
	## Set up minigame from GameManager state
	current_fish = GameManager.current_fish
	print("Starting rhythm minigame for: %s" % current_fish.get("common_name", "Unknown"))

	# Create test beat map (TODO: Load from file)
	_create_test_beat_map()

	# Start music playback
	_start_music()

# ============================================================================
# TEST BEAT MAP (Replace with actual beat map loading)
# ============================================================================

func _create_test_beat_map() -> void:
	## Create a simple test beat map for prototyping
	current_beat_map = {
		"title": "Test Song",
		"bpm": 120,
		"duration_ms": 10000,
		"notes": [
			{"time_ms": 1000, "type": 0},   # Circle
			{"time_ms": 1500, "type": 0},
			{"time_ms": 2000, "type": 0},
			{"time_ms": 2500, "type": 0},
			{"time_ms": 3500, "type": 0},
			{"time_ms": 4000, "type": 0},
			{"time_ms": 4500, "type": 0},
			{"time_ms": 5500, "type": 0},
			{"time_ms": 6000, "type": 0},
			{"time_ms": 6500, "type": 0},
		]
	}
	total_notes = current_beat_map["notes"].size()
	print("Test beat map created with %d notes" % total_notes)

func _start_music() -> void:
	## Start music playback (TODO: Load actual music files)
	print("Music playback started")
	# For now, create a silent timer to simulate music
	music_started_at = Time.get_ticks_msec()
	audio_player.play()

# ============================================================================
# NOTE SPAWNING
# ============================================================================

func _spawn_notes_for_time(current_time_ms: int) -> void:
	## Spawn any notes that should be visible at current time
	while current_note_index < current_beat_map["notes"].size():
		var note_data = current_beat_map["notes"][current_note_index]
		var note_spawn_time = note_data["time_ms"] - NOTE_SPAWN_AHEAD_MS

		if current_time_ms >= note_spawn_time:
			_spawn_note(note_data)
			current_note_index += 1
		else:
			break

func _spawn_note(note_data: Dictionary) -> void:
	## Create and display a note
	var note = Note.new()
	note.note_type = note_data.get("type", Note.NoteType.CIRCLE)
	note.hit_time_ms = note_data["time_ms"]
	note.spawn_time_ms = note_data["time_ms"] - NOTE_SPAWN_AHEAD_MS

	# Randomize X position slightly for variety
	note.position_x = randf_range(300.0, 900.0)
	note.position_y = 200.0

	notes_container.add_child(note)
	active_notes.append(note)
	print("Note spawned at time: %d ms" % note.hit_time_ms)

func _check_expired_notes(current_time_ms: int) -> void:
	## Remove notes that have expired
	for i in range(active_notes.size() - 1, -1, -1):
		var note = active_notes[i]
		if note.check_expired(current_time_ms):
			active_notes.remove_at(i)
			miss_count += 1
			_apply_miss_penalty()

# ============================================================================
# HIT DETECTION
# ============================================================================

func _on_click_detected(position: Vector2, time_ms: int) -> void:
	## Player clicked - check if they hit any notes
	var current_time_ms = _get_audio_time_ms()

	# Find closest note to click position
	var closest_note: Note = null
	var closest_distance: float = 100.0

	for note in active_notes:
		var distance = position.distance_to(Vector2(note.position_x, note.position_y))
		if distance < closest_distance:
			closest_distance = distance
			closest_note = note

	# If note is within click range, check if timing is correct
	if closest_note != null:
		var accuracy = closest_note.check_hit(current_time_ms)
		if accuracy != Note.HitAccuracy.MISS:
			_on_note_hit(accuracy)
			active_notes.erase(closest_note)

# ============================================================================
# SCORING & FEEDBACK
# ============================================================================

func _on_note_hit(accuracy: Note.HitAccuracy) -> void:
	## Handle successful note hit
	notes_hit += 1
	combo += 1

	var points = 0
	match accuracy:
		Note.HitAccuracy.PERFECT:
			points = 300
			perfect_hits += 1
			health = min(health + 25, max_health)
		Note.HitAccuracy.GOOD:
			points = 100
			good_hits += 1
			health = min(health + 15, max_health)

	# Apply combo multiplier
	var combo_mult = _get_combo_multiplier()
	points = int(points * combo_mult)

	current_score += points
	max_combo = max(max_combo, combo)

	print("Hit! Accuracy: %s, Points: %d, Combo: %d" % [
		Note.HitAccuracy.keys()[accuracy],
		points,
		combo
	])

func _apply_miss_penalty() -> void:
	## Handle miss
	combo = 0
	health = max(health - 15, 0)
	print("Miss! Health: %d" % health)

func _get_combo_multiplier() -> float:
	## Get current combo multiplier
	for breakpoint in COMBO_MULTIPLIER_BREAKPOINTS:
		if combo >= breakpoint["hits"]:
			return breakpoint["multiplier"]
	return 1.0

func _update_display() -> void:
	## Update UI labels
	health_bar.value = health
	combo_label.text = "Combo: %d" % combo
	score_label.text = "Score: %d" % current_score

	if total_notes > 0:
		var accuracy_percent = int((float(notes_hit) / total_notes) * 100)
		accuracy_label.text = "Accuracy: %d%%" % accuracy_percent

# ============================================================================
# TIMING UTILITIES
# ============================================================================

func _get_audio_time_ms() -> int:
	## Get current music position in milliseconds
	## Accounts for audio offset and game startup time
	if not audio_player.playing:
		return 0

	var elapsed_ms = Time.get_ticks_msec() - music_started_at
	return int(elapsed_ms) + AudioManager.get_audio_offset_ms()

# ============================================================================
# WIN/LOSE CONDITIONS
# ============================================================================

func _on_fish_caught() -> void:
	## Player successfully caught the fish
	print("FISH CAUGHT!")
	print("Final Score: %d" % current_score)
	print("Accuracy: %d%%" % int((float(notes_hit) / total_notes) * 100))

	GameManager.catch_fish(current_score)
	GameManager.current_state = GameManager.GameState.RESULTS

	# TODO: Go to results screen
	# SceneManager.change_scene("res://scenes/ui/results/results_screen.tscn")

func _on_fish_escaped() -> void:
	## Player failed to catch the fish
	print("FISH ESCAPED!")
	GameManager.escape_fish()
	GameManager.current_state = GameManager.GameState.RESULTS

	# TODO: Go to results screen
	# SceneManager.change_scene("res://scenes/ui/results/results_screen.tscn")

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	## Handle game state changes
	if new_state == GameManager.GameState.PAUSED:
		set_process(false)
		audio_player.stream_paused = true
	elif new_state == GameManager.GameState.RHYTHM:
		set_process(true)
		audio_player.stream_paused = false

# ============================================================================
# DEBUG
# ============================================================================

func print_debug_info() -> void:
	print("RhythmMinigame:")
	print("  Fish: %s" % current_fish.get("common_name", "Unknown"))
	print("  Score: %d" % current_score)
	print("  Combo: %d (max: %d)" % [combo, max_combo])
	print("  Health: %d/%d" % [health, max_health])
	print("  Notes: %d/%d hit" % [notes_hit, total_notes])
	print("  Accuracy: %.1f%% (Perfect: %d, Good: %d, Miss: %d)" % [
		(float(notes_hit) / total_notes) * 100 if total_notes > 0 else 0,
		perfect_hits,
		good_hits,
		miss_count
	])
