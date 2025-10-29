extends Node2D
class_name Note

## Individual rhythm note (circle, hold, slider, etc)
## Player clicks to hit the note at the right time

# ============================================================================
# ENUMS
# ============================================================================

enum NoteType {
	CIRCLE,      # Single tap
	HOLD,        # Hold for duration
	SLIDER,      # Drag along path
	STREAM       # Rapid-fire circles
}

enum HitAccuracy {
	PERFECT,     # ±50ms
	GOOD,        # ±100ms
	MISS         # >100ms
}

# ============================================================================
# CONSTANTS
# ============================================================================

const PERFECT_WINDOW: int = 50    # milliseconds
const GOOD_WINDOW: int = 100      # milliseconds
const NOTE_RADIUS: float = 30.0
const NOTE_SPEED: float = 400.0   # pixels per second toward hit zone

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

var note_type: NoteType = NoteType.CIRCLE
var spawn_time_ms: int = 0        # When note should spawn
var hit_time_ms: int = 0          # When note should be hit
var position_x: float = 400.0     # Screen X position
var position_y: float = 300.0     # Screen Y position
var is_hit: bool = false
var is_expired: bool = false

# Colors based on accuracy
var color: Color = Color.WHITE

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	position = Vector2(position_x, position_y)
	_setup_visual()

func _process(delta: float) -> void:
	if is_hit or is_expired:
		return

	# Update position (move toward hit zone for visual feedback)
	# In a full implementation, notes would animate across screen
	_update_visual()

# ============================================================================
# INITIALIZATION
# ============================================================================

func _setup_visual() -> void:
	## Create visual representation of note
	var circle = CircleShape2D.new()
	circle.radius = NOTE_RADIUS

	# Create a simple colored circle for the note
	var sprite = ColorRect.new()
	sprite.custom_minimum_size = Vector2(NOTE_RADIUS * 2, NOTE_RADIUS * 2)
	sprite.color = color
	add_child(sprite)

	# Add a border for clarity
	var border = ColorRect.new()
	border.custom_minimum_size = Vector2(NOTE_RADIUS * 2 + 4, NOTE_RADIUS * 2 + 4)
	border.color = Color.TRANSPARENT
	border.modulate = Color.WHITE
	add_child(border)

func _update_visual() -> void:
	## Update visual state (called every frame)
	# In full implementation: animate scaling, opacity, etc
	pass

# ============================================================================
# HIT DETECTION
# ============================================================================

func check_hit(current_time_ms: int) -> HitAccuracy:
	## Check if player hit this note
	## Returns hit accuracy or MISS
	if is_hit or is_expired:
		return HitAccuracy.MISS

	var time_diff = abs(current_time_ms - hit_time_ms)

	if time_diff <= PERFECT_WINDOW:
		_on_hit(HitAccuracy.PERFECT)
		return HitAccuracy.PERFECT
	elif time_diff <= GOOD_WINDOW:
		_on_hit(HitAccuracy.GOOD)
		return HitAccuracy.GOOD
	else:
		return HitAccuracy.MISS

func check_expired(current_time_ms: int) -> bool:
	## Check if note has expired (player missed the window)
	if is_hit:
		return false

	if current_time_ms > hit_time_ms + GOOD_WINDOW:
		_on_expired()
		return true

	return false

# ============================================================================
# STATE CHANGES
# ============================================================================

func _on_hit(accuracy: HitAccuracy) -> void:
	## Note was hit successfully
	is_hit = true
	match accuracy:
		HitAccuracy.PERFECT:
			color = Color.GREEN
			print("PERFECT!")
		HitAccuracy.GOOD:
			color = Color.YELLOW
			print("GOOD!")

	_update_visual()
	queue_free()

func _on_expired() -> void:
	## Note was missed (player didn't hit in time)
	is_expired = true
	color = Color.RED
	_update_visual()
	print("MISS!")
	queue_free()

# ============================================================================
# UTILITY
# ============================================================================

func get_note_type_name() -> String:
	return NoteType.keys()[note_type]

func get_hit_accuracy_name(accuracy: HitAccuracy) -> String:
	return HitAccuracy.keys()[accuracy]

func print_debug_info() -> void:
	print("Note:")
	print("  Type: %s" % get_note_type_name())
	print("  Hit time: %d ms" % hit_time_ms)
	print("  Position: (%.0f, %.0f)" % [position_x, position_y])
	print("  Hit: %s, Expired: %s" % [is_hit, is_expired])
