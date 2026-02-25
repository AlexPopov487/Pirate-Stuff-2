extends Node2D

@export var _level_complete: AudioStream

@onready var _player: Player = $Pirate
@onready var _camera: GameCamera = $Camera2D
@onready var _coins_container: HBoxContainer = $UserInterface/CoinPanelContainer/CoinsContainer
@onready var _key: Control = $UserInterface/key
@onready var _fade: Fade = $UserInterface/fade
@onready var _map_container: MapContainer = $UserInterface/MapContainer
@onready var _vfx: Vfx = $UserInterface/VFX
@onready var _player_highlight: PointLight2D = $PlayerHighlight
@onready var _level_complete_window: LevelCompleteWindow = $UserInterface/LevelCompleteWindow
@onready var _health_gauge: HealthGauge = $UserInterface/healthGauge
@onready var _stamina_gauge: Control = $UserInterface/staminaGauge
@onready var _letterbox: Control = $UserInterface/Letterbox
@onready var _coin_panel_container: PanelContainer = $UserInterface/CoinPanelContainer
@onready var _pause_menu: PauseMenu = $PauseMenu
var _current_level: Level


func collect_coin(value: int):
	File.data.coins += value
	_coins_container.set_value(File.data.coins)
	
func collect_key():
	File.data.has_key = true
	_key.visible = true
	
func use_key():
	File.data.has_key = false
	_key.visible = false
	
func score_treasure_found():
	File.data.found_secret_treasure = true
	
func collect_map(map_type: Globals.MAP_TYPE):
	File.data.collected_maps[map_type] = true
	File.data.found_map = true
	File.data.found_map_type = map_type
	_map_container.display_map(map_type)

func _ready() -> void:
	hide_ui()
	_fade.visible = true # set to invisible in editor during development

	await Music.stop_track()
	File.reset_current_level_map_progress()
	
	File.data.current_level_idx = 1

	
	#File.data.collected_maps = {
		#Globals.MAP_TYPE.TOP_LEFT : true,
		#Globals.MAP_TYPE.TOP_RIGHT : true,
		#Globals.MAP_TYPE.BOTTOM_LEFT : true
		#}      
	await _init_level_and_reset_player()
	await _fade.fade_to_clear()


func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		_set_game_paused(!get_tree().paused)

func _set_game_paused(should_pause: bool):
	# Ignore pausing game when level is completed
	if _level_complete_window.visible:
		return
	
	get_tree().paused = should_pause
	_pause_menu.set_menu_visibility(should_pause)
	
	if !should_pause:
		var balloon: DialogueBalloon = get_tree().root.find_child("ExampleBalloon", true, false)
		if balloon:
			balloon.balloon.focus_mode = Control.FOCUS_ALL
			balloon.balloon.grab_focus()

func _init_level():
	_letterbox.visible = false
	_key.visible = false

	#	_current level is null at first launch of the game
	if (_current_level != null) :
		_current_level.free()
	var level_path: String = "res://scenes/levels/level_" + str(File.data.current_level_idx) + ".tscn"
	
	var level_scene = ResourceLoader.load(level_path).instantiate()
	var levels_dir: Node = get_node("Levels")
	levels_dir.add_child(level_scene)

	_current_level = level_scene
	
	_current_level.level_completed.connect(_on_level_completed)
	
	for level in levels_dir.get_children():
		if level.name != "level_" + str(File.data.current_level_idx):
			levels_dir.remove_child(level)
			
	_init_level_vfx()
		
	Music.start_track(_current_level.music)
	if _current_level.music_advance_start_sec != 0:
		await get_tree().create_timer(_current_level.music_advance_start_sec).timeout

func _init_level_vfx():
	_vfx.set_vfx(_current_level.get_weather())

	match _current_level.get_time():
		Globals.TIME.DAY, Globals.TIME.TWIGHLIGHT, Globals.TIME.MORNING, Globals.TIME.MIDDAY:
			_player_highlight.set_enabled(false)
		Globals.TIME.EVENING:
			_player_highlight.set_energy(Globals.PLAYER_HIGHLIGHT_EVENING_ENERGY)
			_player_highlight.set_enabled(true)
		Globals.TIME.NIGHT:
			_player_highlight.set_energy(Globals.PLAYER_HIGHLIGHT_NIGHT_ENERGY)
			_player_highlight.set_enabled(true)
		Globals.TIME.DAWN:
			_player_highlight.set_energy(Globals.PLAYER_HIGHLIGHT_DAWN_ENERGY)
			_player_highlight.set_enabled(true)
			
func _inint_level_boundaries():
	var level_min_boundary: Vector2 = _current_level.get_min()
	var level_max_boundary: Vector2 = _current_level.get_max() 
	
	_player.set_level_boundaries(level_min_boundary, level_max_boundary)
	_camera.set_level_boundaries(level_min_boundary, level_max_boundary)
	
func _init_level_ui():
	_coins_container.set_value(File.data.coins)
	_map_container.rerender_container(File.data.collected_maps)
	
func _spawn_player():
	var spawn: Vector2 = _current_level.get_checkpoint_position(File.data.last_checkbox_id)
	_player.global_position = spawn
	_camera.force_set_position(spawn.x, spawn.y)
	# reset the previous velosity (in cases when player dies during fall)
	_player.velocity = Vector2.ZERO
	_player._direction = 0

func _on_pirate_died() -> void:
	File.increase_death_count()
	_return_to_last_checkpoint()
	
func _return_to_last_checkpoint():
	_player.get_controls().set_enabled(false)
	await _fade.fade_to_black()
	
	if File.data.last_checkbox_id == 0:
		_current_level.restore_ship_position()
	
	_spawn_player()
	_player.revive()
	await _fade.fade_to_clear()
	_player.get_controls().set_enabled(true)

func _on_level_completed(is_secret_ending: bool):
	_current_level.level_completed.disconnect(_on_level_completed)
	
	get_tree().paused = true
	Music.start_track(_level_complete, 0.3)

	if is_secret_ending:
		on_secret_ending_completed()
		return
	
	_level_complete_window.display_window(LevelCompleteStats.new(
		File.data.coins,
		_current_level.get_total_coin_count(), 
		File.data.death_count,
		File.data.found_secret_treasure,
		File.data.found_map,
		_current_level.is_last_level
	))

	if _current_level.is_last_level:
		File.reset_collected_maps()
	
	var next_level_idx: int = File.data.current_level_idx + 1
	File.change_level(next_level_idx)
	File.data.found_map_type = null
	File.save_game()
	print(_current_level.name + " is completed, initializing level_" + str(File.data.current_level_idx))
	
func on_secret_ending_completed() -> void:
	File.remove_user_progress()
	_level_complete_window.display_window(LevelCompleteStats.create_secret_ending())
	
func _restart_level():
	var balloon: DialogueBalloon = get_tree().root.find_child("ExampleBalloon", true, false)
	if balloon:
		balloon.dialogue_line = null
	
	File.change_level(File.data.current_level_idx)
	File.reset_current_level_map_progress()
	
	_pause_menu.set_menu_visibility(false)
	await _fade.fade_to_black()
	await _init_level_and_reset_player()
	await _fade.fade_to_clear()

	
func _init_level_and_reset_player():
	if get_tree().paused:
		_set_game_paused(false)
	
	# Temporarily disable player node so the level can be swapped
	_player.process_mode = PROCESS_MODE_DISABLED
	_pause_menu.set_menu_visibility(false)
	_player.get_controls().set_enabled(false)
	show_ui()

	await _init_level()
	_player.process_mode = PROCESS_MODE_PAUSABLE
	_spawn_player()
	_player.revive()
	_inint_level_boundaries()
	_init_level_ui()
	_player._has_sword = _current_level.get_player_armed()
	
	if _current_level.get_controls_enabled_by_default():
		_player.get_controls().set_enabled(true)
		
	_camera.restore_settings()
	
	if _current_level.name.contains("level_0") or _current_level.name.contains("level_1"):
		_current_level.set_player(_player)
		_current_level.start_init_script()

func _exit_to_main_menu():
	Music.stop_track()
	_pause_menu.set_menu_visibility(false)
	await _fade.fade_to_black()
	# Resetting level to the same one to reset user's progress.
	File.change_level(File.data.current_level_idx)	
	File.reset_current_level_map_progress()


	if get_tree().paused:
		_set_game_paused(false)

	get_tree().change_scene_to_file(Globals.TITLE_SCENE_PATH)

func _on_level_complete_window_next_level_button_pressed() -> void:
	_level_complete_window.visible = false
	await _fade.fade_to_black()
#	safety timer to ensure that LevelCompleteWindow menu music has started playing and now can be faded out
	await get_tree().create_timer(1).timeout
	await Music.stop_track()
	await _init_level_and_reset_player()
	await _fade.fade_to_clear()


func _on_last_level_complete() -> void:
	await _fade.fade_to_black()
	var last_level_idx = File.data.current_level_idx
	# Mimic switching to a new level where necessary but preserving all the statistics
	File.data.current_level_idx = last_level_idx + 1
	File.data.last_checkbox_id = 0
	var level10_coin_count = _current_level.get_total_coin_count()
	
	await _init_level_and_reset_player()
	# Reset current level idx, since levels 10 and 11 should be considered a single level.
	File.data.current_level_idx = last_level_idx
	_current_level._total_coins_on_level = level10_coin_count

	hide_ui()
	var hint: Hint = _current_level.get_node("environment/hints/Hint")
	hint.disable_sound(true)
	hint._player = _player
	hint.toggle_hint_visibility()
	
	_camera.override_zoom(2,0.1)
	_camera.set_camera_behavior(GameCamera.CAMERA_BEHAVIOR.STATIC)
	var viewport_center_x = get_viewport_rect().size.x / 2
	var viewport_center_y = get_viewport_rect().size.y / 2
	_camera.force_set_static_position(viewport_center_x , viewport_center_y)
	
	await _fade.fade_to_clear()

func _on_intro_complete() -> void:
	Music.stop_track()
	await _fade.fade_to_black()
	await  Music.volume_fade_finished
	var last_level_idx = File.data.current_level_idx
	# Mimic switching to a new level where necessary but preserving all the statistics
	File.data.current_level_idx = last_level_idx + 1
	File.data.last_checkbox_id = 0
	
	await _init_level_and_reset_player()
	await _fade.fade_to_clear()
	
func hide_ui():
	_health_gauge.visible = false
	_stamina_gauge.visible = false
	_coins_container.visible = false
	_coin_panel_container.visible = false
	_map_container.visible = false
	
func show_ui():
	_health_gauge.visible = true
	_stamina_gauge.visible = true
	_coins_container.visible = true
	_coin_panel_container.visible = true
	_map_container.visible = true
	
func show_letterbox():
	_letterbox.visible = true
	
