extends Node
class_name SceneManager

## Handles scene loading, transitions, and management
## Provides a clean interface for scene changes throughout the game
## Accessed globally via: SceneManager.change_scene(path)

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

## Currently active scene
var current_scene: Node = null

## Previous scene (for back navigation)
var previous_scene_path: String = ""

## Scene transition duration (fade in/out)
var transition_duration: float = 0.3

## Stack of scenes (for pause menu, overlays, etc)
var scene_stack: Array[String] = []

# ============================================================================
# SIGNALS
# ============================================================================

signal scene_changed(new_scene_path: String)
signal scene_loading_started(scene_path: String)
signal scene_loading_finished(scene: Node)
signal transition_started()
signal transition_finished()

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("SceneManager initialized")
	# Get the current scene
	current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)

func _exit_tree() -> void:
	print("SceneManager shutdown")

# ============================================================================
# SCENE MANAGEMENT
# ============================================================================

func change_scene(scene_path: String, transition_duration_override: float = -1.0) -> void:
	## Change to a new scene with fade transition
	var duration = transition_duration if transition_duration_override < 0 else transition_duration_override

	scene_loading_started.emit(scene_path)
	transition_started.emit()

	# Fade out current scene
	await _fade_out(duration)

	# Load and set new scene
	var new_scene = load(scene_path).instantiate()
	var root = get_tree().root

	# Remove old scene
	if current_scene != null:
		previous_scene_path = current_scene.scene_file_path
		current_scene.queue_free()

	# Add new scene
	root.add_child(new_scene)
	current_scene = new_scene

	# Fade in new scene
	await _fade_in(duration)

	scene_changed.emit(scene_path)
	scene_loading_finished.emit(new_scene)
	transition_finished.emit()

	print("Scene changed to: %s" % scene_path)

func reload_scene() -> void:
	## Reload the current scene
	if current_scene != null:
		var scene_path = current_scene.scene_file_path
		change_scene(scene_path)

func go_back() -> void:
	## Go back to previous scene
	if previous_scene_path != "":
		change_scene(previous_scene_path)
	else:
		print("WARNING: No previous scene to return to")

# ============================================================================
# OVERLAY & STACK MANAGEMENT
# ============================================================================

func push_overlay(overlay_scene_path: String) -> void:
	## Add an overlay scene on top of current scene (e.g., pause menu)
	var overlay = load(overlay_scene_path).instantiate()
	scene_stack.append(overlay_scene_path)
	get_tree().root.add_child(overlay)
	print("Overlay pushed: %s" % overlay_scene_path)

func pop_overlay() -> void:
	## Remove the top overlay
	if scene_stack.is_empty():
		print("WARNING: Scene stack is empty")
		return

	var overlay_path = scene_stack.pop_back()
	# Find and remove the overlay (assumes it's the last child)
	var root = get_tree().root
	var last_child = root.get_child(root.get_child_count() - 1)
	if last_child.scene_file_path == overlay_path:
		last_child.queue_free()
	print("Overlay popped: %s" % overlay_path)

# ============================================================================
# SCENE PRELOADING
# ============================================================================

func preload_scene(scene_path: String) -> Resource:
	## Preload a scene for faster loading later
	var scene = preload(scene_path)
	print("Scene preloaded: %s" % scene_path)
	return scene

# ============================================================================
# TRANSITION EFFECTS
# ============================================================================

func _fade_out(duration: float) -> void:
	## Fade out current scene
	if duration <= 0:
		return

	var root = get_tree().root
	var fade_layer = CanvasLayer.new()
	fade_layer.layer = 999  # Top layer
	root.add_child(fade_layer)

	var fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.color.a = 0.0
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_layer.add_child(fade_rect)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fade_rect, "color:a", 1.0, duration)

	await tween.finished

	fade_layer.queue_free()

func _fade_in(duration: float) -> void:
	## Fade in new scene
	if duration <= 0:
		return

	var root = get_tree().root
	var fade_layer = CanvasLayer.new()
	fade_layer.layer = 999
	root.add_child(fade_layer)

	var fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.color.a = 1.0
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_layer.add_child(fade_rect)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fade_rect, "color:a", 0.0, duration)

	await tween.finished

	fade_layer.queue_free()

# ============================================================================
# UTILITY METHODS
# ============================================================================

func get_current_scene_name() -> String:
	## Get name of current scene
	if current_scene != null:
		return current_scene.name
	return "None"

func get_current_scene_path() -> String:
	## Get file path of current scene
	if current_scene != null:
		return current_scene.scene_file_path
	return ""

# ============================================================================
# DEBUG & UTILITIES
# ============================================================================

func print_debug_info() -> void:
	print("\n=== SCENE MANAGER ===")
	print("Current scene: %s" % get_current_scene_name())
	print("Scene path: %s" % get_current_scene_path())
	print("Previous scene: %s" % previous_scene_path)
	print("Stack depth: %d" % scene_stack.size())
	print("====================\n")
