extends Node
class_name AudioManager

## Centralized audio playback and synchronization
## Handles music, SFX, and critical audio sync for rhythm game
## Accessed globally via: AudioManager.method_name()

# ============================================================================
# MEMBER VARIABLES
# ============================================================================

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

## Audio offset for latency compensation (milliseconds)
var audio_offset_ms: int = 0

## Current playing music (for reference)
var current_music: String = ""

## Master volume (0.0 - 1.0)
var master_volume: float = 1.0

# ============================================================================
# SIGNALS
# ============================================================================

signal music_started(track_name: String)
signal music_stopped()
signal sfx_played(effect_name: String)

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("AudioManager initialized")
	_initialize_audio_players()
	_load_audio_bus_settings()

func _exit_tree() -> void:
	# Cleanup audio players
	if music_player:
		music_player.queue_free()
	if sfx_player:
		sfx_player.queue_free()

# ============================================================================
# INITIALIZATION
# ============================================================================

func _initialize_audio_players() -> void:
	## Create audio stream players
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

func _load_audio_bus_settings() -> void:
	## Load master volume and audio settings
	# TODO: Load from settings file
	set_master_volume(1.0)

# ============================================================================
# MUSIC PLAYBACK
# ============================================================================

func play_music(music_name: String, loop: bool = true) -> void:
	## Start playing music track
	var music_path = "res://assets/audio/music/%s.ogg" % music_name

	var audio_stream = load(music_path)
	if audio_stream == null:
		push_error("Could not load music: %s" % music_path)
		return

	# Validate it's an audio stream
	if not audio_stream is AudioStream:
		push_error("Loaded resource is not an AudioStream: %s" % music_path)
		return

	music_player.stream = audio_stream
	music_player.bus = "Music"
	music_player.volume_db = 0
	music_player.play()
	current_music = music_name

	music_started.emit(music_name)
	print("Music started: %s" % music_name)

func stop_music() -> void:
	## Stop currently playing music
	if music_player.playing:
		music_player.stop()
		current_music = ""
		music_stopped.emit()
		print("Music stopped")

func pause_music() -> void:
	## Pause music (keep playback position)
	if music_player.playing:
		music_player.stream_paused = true

func resume_music() -> void:
	## Resume paused music
	if music_player.stream_paused:
		music_player.stream_paused = false

func is_music_playing() -> bool:
	return music_player.playing

# ============================================================================
# SFX PLAYBACK
# ============================================================================

func play_sfx(sfx_name: String, volume_db: float = 0.0) -> void:
	## Play a sound effect
	var sfx_path = "res://assets/audio/sfx/%s.ogg" % sfx_name

	var audio_stream = load(sfx_path)
	if audio_stream == null:
		push_error("Could not load SFX: %s" % sfx_path)
		return

	# Validate it's an audio stream
	if not audio_stream is AudioStream:
		push_error("Loaded resource is not an AudioStream: %s" % sfx_path)
		return

	sfx_player.stream = audio_stream
	sfx_player.volume_db = volume_db
	sfx_player.play()

	sfx_played.emit(sfx_name)
	print("SFX played: %s" % sfx_name)

func stop_sfx() -> void:
	## Stop currently playing SFX
	if sfx_player.playing:
		sfx_player.stop()

# ============================================================================
# AUDIO SYNC (CRITICAL FOR RHYTHM GAME)
# ============================================================================

func get_music_position_ms() -> int:
	## Get current music playback position in milliseconds
	## CRITICAL: This is used for rhythm note timing
	if not music_player.playing:
		return 0

	var position_seconds = music_player.get_playback_position()
	var position_ms = int(position_seconds * 1000.0)

	# Apply latency offset compensation
	return position_ms + audio_offset_ms

func set_music_position_ms(position_ms: int) -> void:
	## Seek to a specific position in the music
	if music_player.stream == null:
		return

	var position_seconds = float(position_ms) / 1000.0
	music_player.seek(position_seconds)

func set_audio_offset_ms(offset: int) -> void:
	## Set latency offset for audio sync
	## Players can calibrate this in settings
	audio_offset_ms = offset
	print("Audio offset set to: %d ms" % offset)

func get_audio_offset_ms() -> int:
	return audio_offset_ms

func get_music_length_ms() -> int:
	## Get total length of current music in milliseconds
	if music_player.stream == null:
		return 0

	var length_seconds = music_player.stream.get_length()
	return int(length_seconds * 1000.0)

# ============================================================================
# VOLUME CONTROL
# ============================================================================

func set_master_volume(volume: float) -> void:
	## Set master volume (0.0 - 1.0)
	master_volume = clamp(volume, 0.0, 1.0)
	var volume_db = linear2db(master_volume)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func set_music_volume(volume: float) -> void:
	## Set music volume (0.0 - 1.0)
	var volume_db = linear2db(clamp(volume, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_db)

func set_sfx_volume(volume: float) -> void:
	## Set SFX volume (0.0 - 1.0)
	var volume_db = linear2db(clamp(volume, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume_db)

# ============================================================================
# DEBUG & UTILITIES
# ============================================================================

func print_debug_info() -> void:
	print("\n=== AUDIO MANAGER ===")
	print("Music playing: %s" % current_music)
	print("Music position: %d ms" % get_music_position_ms())
	print("Music length: %d ms" % get_music_length_ms())
	print("Audio offset: %d ms" % audio_offset_ms)
	print("Master volume: %.1f" % master_volume)
	print("====================\n")
