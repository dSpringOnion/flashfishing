extends Node2D
class_name Main

## Main entry point for the game
## Initializes all core systems and transitions to main menu

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("\n" + "="*50)
	print("RHYTHM FISHING - Game Started")
	print("="*50 + "\n")

	_initialize_core_systems()
	_setup_input_context()
	_transition_to_main_menu()

	print_all_debug_info()

# ============================================================================
# INITIALIZATION
# ============================================================================

func _initialize_core_systems() -> void:
	## Initialize all core game systems
	print("Initializing core systems...")

	# All autoload managers are already initialized:
	# - GameManager
	# - InputManager
	# - AudioManager
	# - SceneManager

	# Connect GameManager signals
	GameManager.state_changed.connect(_on_game_state_changed)
	GameManager.fish_caught.connect(_on_fish_caught)

	# Connect InputManager signals
	InputManager.pause_pressed.connect(_on_pause_pressed)

	# Create initial player data if needed
	if GameManager.player_data == null:
		GameManager.player_data = PlayerData.new()

	print("Core systems initialized successfully")

func _setup_input_context() -> void:
	## Initialize input handling context
	InputManager.set_input_context(InputManager.InputContext.MENU)

# ============================================================================
# SCENE TRANSITIONS
# ============================================================================

func _transition_to_main_menu() -> void:
	## Load main menu scene
	print("Transitioning to main menu...")
	GameManager.current_state = GameManager.GameState.MENU
	# Load main menu asynchronously
	SceneManager.change_scene("res://scenes/ui/main_menu.tscn", 0.0)

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	## Handle game state changes
	var state_name = GameManager.GameState.keys()[new_state]
	print("Game state changed: %s" % state_name)

	match new_state:
		GameManager.GameState.MENU:
			InputManager.set_input_context(InputManager.InputContext.MENU)

		GameManager.GameState.LEVEL_SELECT:
			InputManager.set_input_context(InputManager.InputContext.MENU)

		GameManager.GameState.FISHING:
			InputManager.set_input_context(InputManager.InputContext.FISHING)

		GameManager.GameState.RHYTHM:
			InputManager.set_input_context(InputManager.InputContext.RHYTHM)

		GameManager.GameState.RESULTS:
			InputManager.set_input_context(InputManager.InputContext.MENU)

		GameManager.GameState.PAUSED:
			InputManager.set_input_context(InputManager.InputContext.PAUSED)

func _on_fish_caught(fish: Dictionary, score: int) -> void:
	## Handle fish caught event
	var fish_name = fish.get("common_name", "Unknown")
	print("Fish caught event: %s (Score: %d)" % [fish_name, score])

func _on_pause_pressed() -> void:
	## Handle pause key press
	if GameManager.current_state == GameManager.GameState.PAUSED:
		GameManager.resume_game()
	elif GameManager.current_state in [GameManager.GameState.FISHING, GameManager.GameState.RHYTHM]:
		GameManager.pause_game()

# ============================================================================
# DEBUG UTILITIES
# ============================================================================

func print_all_debug_info() -> void:
	## Print all debug information
	print("\n" + "="*50)
	print("DEBUG INFO")
	print("="*50)
	GameManager.print_debug_info()
	InputManager.print_debug_info()
	AudioManager.print_debug_info()
	SceneManager.print_debug_info()
	GameManager.player_data.print_debug_info()
	print("="*50 + "\n")
