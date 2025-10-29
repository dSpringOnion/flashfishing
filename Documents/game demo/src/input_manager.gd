extends Node
class_name InputManager

## Centralized input handling for the game
## All input goes through this system
## Accessed globally via: InputManager.method_name()

# ============================================================================
# ENUMS & CONSTANTS
# ============================================================================

enum InputContext {
	MENU,      # Menu navigation
	FISHING,   # Casting and waiting for fish
	RHYTHM,    # Hitting rhythm notes
	PAUSED     # Pause menu
}

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

var input_enabled: bool = true
var current_context: InputContext = InputContext.MENU

# Timing data (for rhythm detection)
var _last_click_time: int = 0
var _last_click_position: Vector2 = Vector2.ZERO

# ============================================================================
# SIGNALS
# ============================================================================

signal click_detected(position: Vector2, time_ms: int)
signal hold_started(position: Vector2)
signal hold_released(position: Vector2)
signal pause_pressed()
signal restart_pressed()

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("InputManager initialized")
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	## Process all input events
	if not input_enabled:
		return

	if event is InputEventMouseButton:
		_handle_mouse_click(event)
	elif event is InputEventKey:
		_handle_key_press(event)

# ============================================================================
# INPUT HANDLERS
# ============================================================================

func _handle_mouse_click(event: InputEventMouseButton) -> void:
	## Handle mouse clicks (also works for touch)
	if not event.pressed:
		return

	var click_position = event.position
	var click_time = Time.get_ticks_msec()

	match current_context:
		InputContext.MENU:
			# Menu clicks handled by UI buttons directly
			pass

		InputContext.FISHING:
			# Used for casting
			click_detected.emit(click_position, click_time)

		InputContext.RHYTHM:
			# Critical for rhythm detection
			click_detected.emit(click_position, click_time)
			_last_click_time = click_time
			_last_click_position = click_position

		InputContext.PAUSED:
			# Pause menu clicks handled by UI buttons
			pass

func _handle_key_press(event: InputEventKey) -> void:
	## Handle keyboard input
	if not event.pressed:
		return

	match event.keycode:
		KEY_ESCAPE:
			pause_pressed.emit()
			get_tree().root.set_input_as_handled()

		KEY_R:
			# Restart level (useful for testing)
			if current_context == InputContext.RHYTHM:
				restart_pressed.emit()
				get_tree().root.set_input_as_handled()

# ============================================================================
# CONTEXT MANAGEMENT
# ============================================================================

func set_input_context(context: InputContext) -> void:
	## Change input handling context
	current_context = context
	print("Input context: %s" % InputContext.keys()[context])

func enable_input() -> void:
	input_enabled = true

func disable_input() -> void:
	input_enabled = false

# ============================================================================
# TIMING & POSITION DATA
# ============================================================================

func get_last_click_time() -> int:
	## Get milliseconds since last click
	return Time.get_ticks_msec() - _last_click_time

func get_last_click_position() -> Vector2:
	## Get position of last click
	return _last_click_position

func get_current_time_ms() -> int:
	## Get current time in milliseconds
	return Time.get_ticks_msec()

# ============================================================================
# DEBUG & UTILITIES
# ============================================================================

func print_debug_info() -> void:
	print("\n=== INPUT MANAGER ===")
	print("Input enabled: %s" % input_enabled)
	print("Current context: %s" % InputContext.keys()[current_context])
	print("Last click time: %d ms ago" % get_last_click_time())
	print("Last click position: %s" % _last_click_position)
	print("====================\n")
