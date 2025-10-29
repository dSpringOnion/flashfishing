extends Resource
class_name PlayerData

## Stores player progression, mastery, and high scores
## Can be saved/loaded from disk

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

var total_score: int = 0
var current_rod_casual: int = 0  # Casual rod tier (0-4)
var current_rod_hardcore: int = 0  # Hardcore rod tier (0-4)

## Fish caught: { "fish_id": { "total_caught": int, "best_size": float, "legendary_caught": bool } }
var fish_caught: Dictionary = {}

## Mastery points per genus: { "Perch": 50, "Salmon": 30, ... }
var mastery: Dictionary = {}

## High scores per level: { "level_id": score }
var high_scores: Dictionary = {}

## Area unlocks: { "area_1": true, "area_2": false, ... }
var area_unlocks: Dictionary = {
	"area_1": true,   # Always unlocked
	"area_2": false,
	"area_3": false,
	"area_4": false
}

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init() -> void:
	# Initialize empty mastery for all genera
	mastery = {
		"Perch": 0,
		"Salmon": 0,
		"Drum": 0,
		"Legendary": 0
	}

# ============================================================================
# FISH TRACKING
# ============================================================================

func add_fish_caught(fish_id: String, score: int) -> void:
	## Record a fish catch
	if not fish_caught.has(fish_id):
		fish_caught[fish_id] = {
			"total_caught": 0,
			"best_size": 0.0,
			"legendary_caught": false
		}

	var fish_record = fish_caught[fish_id]
	fish_record["total_caught"] += 1

	# TODO: Update best_size when size variants implemented
	# TODO: Update legendary_caught based on fish size

func get_fish_caught(fish_id: String) -> int:
	## Get total times a specific fish was caught
	if fish_caught.has(fish_id):
		return fish_caught[fish_id]["total_caught"]
	return 0

func get_total_fish_caught() -> int:
	## Get total number of fish caught (all species combined)
	var total = 0
	for fish_data in fish_caught.values():
		total += fish_data["total_caught"]
	return total

# ============================================================================
# MASTERY SYSTEM
# ============================================================================

func add_mastery(genus: String, amount: int) -> void:
	## Add mastery points for a fish genus
	if mastery.has(genus):
		mastery[genus] += amount
	else:
		mastery[genus] = amount

	# TODO: Check for mastery level thresholds and unlock rewards

func get_mastery(genus: String) -> int:
	## Get mastery points for a genus
	return mastery.get(genus, 0)

func get_mastery_level(genus: String) -> int:
	## Convert mastery points to level (e.g., 0-20 = level 1)
	var points = get_mastery(genus)
	return int(points / 20) + 1  # Adjust formula as needed

# ============================================================================
# HIGH SCORES
# ============================================================================

func update_high_score(level_id: String, score: int) -> bool:
	## Update high score for a level
	## Returns true if it's a new personal best
	var current_best = high_scores.get(level_id, 0)
	if score > current_best:
		high_scores[level_id] = score
		total_score += score
		return true
	return false

func get_high_score(level_id: String) -> int:
	## Get best score for a level
	return high_scores.get(level_id, 0)

# ============================================================================
# AREA UNLOCKS
# ============================================================================

func unlock_area(area: String) -> void:
	## Unlock a new fishing area
	if area_unlocks.has(area):
		area_unlocks[area] = true
		print("Area unlocked: %s" % area)

func is_area_unlocked(area: String) -> bool:
	## Check if area is unlocked
	return area_unlocks.get(area, false)

func get_unlocked_areas() -> Array[String]:
	## Get all unlocked areas
	var unlocked: Array[String] = []
	for area in area_unlocks.keys():
		if area_unlocks[area]:
			unlocked.append(area)
	return unlocked

# ============================================================================
# ROD PROGRESSION
# ============================================================================

func set_rod_tier(rod_path: String, tier: int) -> void:
	## Set rod tier (0-4)
	match rod_path:
		"casual":
			current_rod_casual = clamp(tier, 0, 4)
		"hardcore":
			current_rod_hardcore = clamp(tier, 0, 4)

func get_rod_tier(rod_path: String) -> int:
	## Get current rod tier
	match rod_path:
		"casual":
			return current_rod_casual
		"hardcore":
			return current_rod_hardcore
	return 0

# ============================================================================
# DEBUG & UTILITIES
# ============================================================================

func get_debug_info() -> Dictionary:
	## Return debug information
	return {
		"total_score": total_score,
		"total_fish_caught": get_total_fish_caught(),
		"mastery": mastery,
		"rod_casual_tier": current_rod_casual,
		"rod_hardcore_tier": current_rod_hardcore,
		"areas_unlocked": get_unlocked_areas()
	}

func print_debug_info() -> void:
	## Print player data to console
	var info = get_debug_info()
	print("\n=== PLAYER DATA ===")
	for key in info:
		print("%s: %s" % [key, info[key]])
	print("===================\n")

func reset() -> void:
	## Reset all player data (for testing)
	total_score = 0
	current_rod_casual = 0
	current_rod_hardcore = 0
	fish_caught = {}
	mastery = {
		"Perch": 0,
		"Salmon": 0,
		"Drum": 0,
		"Legendary": 0
	}
	high_scores = {}
	area_unlocks = {
		"area_1": true,
		"area_2": false,
		"area_3": false,
		"area_4": false
	}
	print("Player data reset")
