extends Control
class_name LevelSelect

## Level Select Scene
## Allows player to choose area and rod configuration

# ============================================================================
# ENUMS
# ============================================================================

enum RodType {
	CASUAL,
	HARDCORE
}

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var rod_selector: HBoxContainer = $VBoxContainer/RodSelector
@onready var area_selector: VBoxContainer = $VBoxContainer/AreaSelector
@onready var back_button: Button = $VBoxContainer/BackButton

var casual_rod_button: Button
var hardcore_rod_button: Button
var area_buttons: Array[Button] = []
var selected_rod: RodType = RodType.CASUAL
var selected_area: String = "area_1"

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("LevelSelect initialized")
	_setup_ui()
	_connect_signals()

# ============================================================================
# INITIALIZATION
# ============================================================================

func _setup_ui() -> void:
	## Configure UI elements
	title_label.text = "SELECT FISHING AREA & ROD"
	title_label.add_theme_font_size_override("font_size", 48)

	# Create rod selection buttons
	var casual_label = Label.new()
	casual_label.text = "Rod Type:"
	casual_label.add_theme_font_size_override("font_size", 24)
	rod_selector.add_child(casual_label)

	casual_rod_button = Button.new()
	casual_rod_button.text = "Casual (Forgiving)"
	casual_rod_button.custom_minimum_size = Vector2(200, 50)
	casual_rod_button.add_theme_font_size_override("font_size", 18)
	casual_rod_button.modulate = Color.GREEN  # Selected
	rod_selector.add_child(casual_rod_button)

	hardcore_rod_button = Button.new()
	hardcore_rod_button.text = "Hardcore (Challenging)"
	hardcore_rod_button.custom_minimum_size = Vector2(200, 50)
	hardcore_rod_button.add_theme_font_size_override("font_size", 18)
	hardcore_rod_button.modulate = Color.GRAY  # Not selected
	rod_selector.add_child(hardcore_rod_button)

	# Create area selection buttons
	var area_label = Label.new()
	area_label.text = "Fishing Area:"
	area_label.add_theme_font_size_override("font_size", 24)
	area_selector.add_child(area_label)

	var areas = [
		{"id": "area_1", "name": "Calm Creek", "description": "Peaceful stream for beginners"},
		{"id": "area_2", "name": "Golden River", "description": "Moderate challenge, jazz vibes"},
		{"id": "area_3", "name": "Coastal Bay", "description": "Advanced, high energy"},
		{"id": "area_4", "name": "Deep Ocean", "description": "Expert only, legendary fish"}
	]

	for area_data in areas:
		var area_button = Button.new()
		var is_unlocked = GameManager.player_data.is_area_unlocked(area_data["id"])
		var text = "%s - %s" % [area_data["name"], area_data["description"]]
		if not is_unlocked:
			text += " (LOCKED)"
			area_button.disabled = true

		area_button.text = text
		area_button.custom_minimum_size = Vector2(400, 60)
		area_button.add_theme_font_size_override("font_size", 18)
		area_button.meta["area_id"] = area_data["id"]

		# Highlight first unlocked area
		if area_data["id"] == "area_1":
			area_button.modulate = Color.GREEN
			selected_area = area_data["id"]

		area_selector.add_child(area_button)
		area_buttons.append(area_button)

	back_button.text = "BACK TO MENU"
	back_button.custom_minimum_size = Vector2(300, 50)
	back_button.add_theme_font_size_override("font_size", 20)

func _connect_signals() -> void:
	## Connect button signals
	casual_rod_button.pressed.connect(_on_casual_rod_pressed)
	hardcore_rod_button.pressed.connect(_on_hardcore_rod_pressed)
	back_button.pressed.connect(_on_back_pressed)

	for area_button in area_buttons:
		area_button.pressed.connect(_on_area_selected.bindv([area_button]))

# ============================================================================
# ROD SELECTION
# ============================================================================

func _on_casual_rod_pressed() -> void:
	## Select casual rod
	selected_rod = RodType.CASUAL
	casual_rod_button.modulate = Color.GREEN
	hardcore_rod_button.modulate = Color.GRAY
	print("Selected rod: CASUAL")

func _on_hardcore_rod_pressed() -> void:
	## Select hardcore rod
	selected_rod = RodType.HARDCORE
	casual_rod_button.modulate = Color.GRAY
	hardcore_rod_button.modulate = Color.GREEN
	print("Selected rod: HARDCORE")

# ============================================================================
# AREA SELECTION
# ============================================================================

func _on_area_selected(button: Button) -> void:
	## Select fishing area
	var area_id = button.meta["area_id"]
	if GameManager.player_data.is_area_unlocked(area_id):
		selected_area = area_id
		# Highlight selected button
		for area_button in area_buttons:
			if area_button == button:
				area_button.modulate = Color.GREEN
			else:
				area_button.modulate = Color.WHITE

		print("Selected area: %s" % area_id)
		# Auto-start fishing phase
		_start_fishing()

func _start_fishing() -> void:
	## Start fishing phase with selected area and rod
	GameManager.set_current_area(selected_area)
	GameManager.current_state = GameManager.GameState.FISHING
	SceneManager.change_scene("res://scenes/fishing/fishing_phase.tscn")
	print("Starting fishing in area: %s with rod: %s" % [selected_area, RodType.keys()[selected_rod]])

# ============================================================================
# NAVIGATION
# ============================================================================

func _on_back_pressed() -> void:
	## Return to main menu
	print("Back to menu pressed")
	GameManager.current_state = GameManager.GameState.MENU
	SceneManager.change_scene("res://scenes/ui/main_menu.tscn")
