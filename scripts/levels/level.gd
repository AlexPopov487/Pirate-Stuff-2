class_name Level extends Area2D

@onready var _boundaries: CollisionShape2D = $boundaries
var _min: Vector2
var _max: Vector2
var _checkpoints: Array[Node]
var _player_armed: bool
var _controls_enabled_by_default: bool
var _weather := Globals.WEATHER.CLEAR
var _time := Globals.TIME.DAY
var _title_text: String = "Level"

var is_last_level: bool = false

@onready var _environment_overlay: CanvasModulate = get_node_or_null("EnvironmentOverlay")
@onready var _background_overlay: CanvasModulate =  get_node_or_null("environment/ParallaxBackground/BackgroundOverlay")
@onready var _hint_ui: HintUi = get_node_or_null("hint_ui")
@onready var _title: LevelTitle = get_node_or_null("Title")


signal level_completed

func get_controls_enabled_by_default() -> bool:
	return _controls_enabled_by_default

func get_player_armed() -> bool:
	return _player_armed

func get_min() -> Vector2:
	return _min

func get_max() -> Vector2:
	return _max
	
func get_checkpoint_position(id: int) -> Vector2:
	if id < 0 || id > _checkpoints.size():
		return Vector2.ZERO
	
	return _checkpoints[id].global_position

func set_level_completed():
	print(name + " is comppleted, emitting signal to game manager")
	level_completed.emit()
	
func get_time() -> Globals.TIME:
	return _time

func get_weather() -> Globals.WEATHER:
	return _weather

func _ready() -> void:
	var half_size: Vector2 = _boundaries.shape.get_rect().size / 2
	_min = _boundaries.position - half_size
	_max = _boundaries.position + half_size
	
	_init_level_overlay()
	_init_checkpoint_nodes()

func _init_checkpoint_nodes():
	_checkpoints = $checkpoints.get_children()
	# Not all nodes in the directory are instances of Checkpoint class. 
	# Some of them are just nodes since they require no scripting behavior.
	for i in _checkpoints.size():
		var curr: Node = _checkpoints[i]
		if curr is Checkpoint:
			curr.id = i

func _init_level_overlay():
	match _time:
		Globals.TIME.DAY:
			if _environment_overlay != null:
				_environment_overlay.visible = false
			if _background_overlay != null:
				_background_overlay.visible = false
		Globals.TIME.EVENING:
			_init_overlay(Globals.EVENING_OVERLAY_COLOR)
		Globals.TIME.NIGHT:
			_init_overlay(Globals.NIGHT_OVERLAY_COLOR)
			
	if _hint_ui != null:
		_hint_ui.hide()

func _init_overlay(color: Color) -> void:
	if _environment_overlay == null or _background_overlay == null:
		print("Failed to init overlay, overlay nodes not found")
		return
	_environment_overlay.color = color
	_background_overlay.color = color
	_environment_overlay.visible = true
	_background_overlay.visible = true
	
	
func hide_hint_wood_popup(player: Player):
	if _hint_ui == null:
		push_warning(name + " failed to hide hint popup. HintUI scene is null")
		return
		
	if player == null:
		push_warning(name + " failed to hide hint popup. Player scene is null")
		return
	
	_hint_ui.hide_ui()
	player.get_controls().set_enabled(true)


func show_hint_wood_popup(hint_type: Globals.HINT_TYPE, player: Player, text: String):
	if _hint_ui == null:
		push_error(name + " failed to show hint popup. HintUI scene is null")
		return
		
	if player == null:
		push_error(name + " failed to show hint popup. Player scene is null")
		return
		
	player.get_controls().set_enabled(false)
	match hint_type:
		Globals.HINT_TYPE.WOOD_SIGN:
			_hint_ui.show_wood_hint(text)
		Globals.HINT_TYPE.LETTER:
			_hint_ui.show_letter(text)
	
	
