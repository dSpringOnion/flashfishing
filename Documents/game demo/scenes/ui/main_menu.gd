extends Control
class_name MainMenu

## Main Menu Scene
## Entry point for the game - displays Start, Settings, and Quit options

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $VBoxContainer/TitleLabel

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("MainMenu initialized")
	_setup_ui()
	_connect_signals()

# ============================================================================
# INITIALIZATION
# ============================================================================

func _setup_ui() -> void:
	## Configure UI elements
	title_label.text = "RHYTHM FISHING"
	title_label.add_theme_font_size_override("font_size", 64)

	start_button.text = "START GAME"
	settings_button.text = "SETTINGS"
	quit_button.text = "QUIT"

	# Set button sizes
	for button in [start_button, settings_button, quit_button]:
		button.custom_minimum_size = Vector2(300, 60)
		button.add_theme_font_size_override("font_size", 24)

func _connect_signals() -> void:
	## Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

# ============================================================================
# BUTTON HANDLERS
# ============================================================================

func _on_start_pressed() -> void:
	## Start game - go to level select
	print("Start Game pressed")
	GameManager.current_state = GameManager.GameState.LEVEL_SELECT
	SceneManager.change_scene("res://scenes/ui/level_select.tscn")

func _on_settings_pressed() -> void:
	## Open settings menu
	print("Settings pressed")
	# TODO: Push overlay for settings menu
	# SceneManager.push_overlay("res://scenes/ui/settings/settings_menu.tscn")

func _on_quit_pressed() -> void:
	## Quit the game
	print("Quit pressed")
	get_tree().quit()

# ============================================================================
# DEBUG
# ============================================================================

func print_debug_info() -> void:
	print("MainMenu is active")
