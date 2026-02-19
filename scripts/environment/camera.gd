extends Camera2D
class_name GameCamera

enum CAMERA_BEHAVIOR {FOLLOWING, STATIC}
const ZOOM_DEFAULT: float = 3.0

@export var _subject: Character
@export var _offset: Vector2 # in tiles
@onready var _look_ahead_distance: float
@onready var _current_camera_behavior: CAMERA_BEHAVIOR = CAMERA_BEHAVIOR.FOLLOWING

@export_category("Camera transition")
@export var _transition_type: Tween.TransitionType
@export var _ease_type: Tween.EaseType
@export var _speed_horizontal: float = 1
@export var _speed_vertical: float = 1


@onready var _current_floor_height: float = position.y
var _horizontal_tween: Tween
var _vertial_tween: Tween
# camera override requires a separate tween that should not be interrupted
var _camera_override_zoom: Tween

var _min_level_boundary: Vector2
var _max_level_boundary: Vector2
# if player is on platrom, camera should always follow y axis
var _is_subject_on_platform: bool 
var _current_zoom: float = ZOOM_DEFAULT


func set_level_boundaries(min_boundary: Vector2, max_boundary: Vector2):
	var half_camera_area = get_viewport_rect().size / zoom / 2
	_min_level_boundary = min_boundary + half_camera_area
	_max_level_boundary = max_boundary - half_camera_area 

func force_set_position(subject_x: float, subject_y: float):
	position.x = subject_x + _look_ahead_distance
	_current_floor_height = subject_y

func force_set_static_position(pos_x: float, pos_y: float):
	position.x = pos_x
	position.y = pos_y

func override_zoom(value: float, speed: float):
	if _camera_override_zoom && _camera_override_zoom.is_running():
		_camera_override_zoom.kill()
	_camera_override_zoom = create_tween().set_ease(_ease_type).set_trans(_transition_type)
	_camera_override_zoom.tween_property(self, "zoom",  Vector2(value, value), speed)
	
func restore_zoom(speed: float):
	if _camera_override_zoom && _camera_override_zoom.is_running():
		_camera_override_zoom.kill()
	_camera_override_zoom = create_tween().set_ease(_ease_type).set_trans(_transition_type)
	_camera_override_zoom.tween_property(self, "zoom",  Vector2(ZOOM_DEFAULT, ZOOM_DEFAULT), speed)

func set_camera_behavior(behavior: CAMERA_BEHAVIOR):
	_current_camera_behavior = behavior

func restore_settings():
	restore_zoom(0.1)
	set_camera_behavior(CAMERA_BEHAVIOR.FOLLOWING)

func _ready() -> void:
	_current_camera_behavior = CAMERA_BEHAVIOR.FOLLOWING
	zoom.x = _current_zoom
	zoom.y = _current_zoom
	
	_offset *= Globals.ppt
	_look_ahead_distance = _offset.x

func _process(_delta: float) -> void:
	match _current_camera_behavior:
		CAMERA_BEHAVIOR.FOLLOWING:
			if _is_subject_on_platform:
				if _vertial_tween && _vertial_tween.is_running():
					_vertial_tween.kill()
				_current_floor_height = _subject.position.y
				
			position.x = _subject.position.x + _look_ahead_distance
			position.y = _offset.y + _current_floor_height
		CAMERA_BEHAVIOR.STATIC:
			pass

	_check_level_boundaries()
	

func _on_subject_changed_direction(is_facing_left: bool) -> void:
	if _horizontal_tween && _horizontal_tween.is_running():
		_horizontal_tween.kill()
	_horizontal_tween = create_tween().set_ease(_ease_type).set_trans(_transition_type)
	_horizontal_tween.tween_property(self, "_look_ahead_distance",  _offset.x * (-1 if is_facing_left else 1), _speed_horizontal)

func _on_subject_landed(floor_pos_y: float) -> void:
	_follow_subject_y(floor_pos_y)

func _check_level_boundaries():
	if _min_level_boundary and _max_level_boundary:
		position.x = clamp(position.x, _min_level_boundary.x, _max_level_boundary.x)
		position.y = clamp(position.y, _min_level_boundary.y, _max_level_boundary.y)

func _follow_subject_y(floor_pos_y: float):
	if _vertial_tween && _vertial_tween.is_running():
		_vertial_tween.kill()
	_vertial_tween = create_tween().set_ease(_ease_type).set_trans(_transition_type)
	_vertial_tween.tween_property(self, "_current_floor_height",  floor_pos_y, _speed_vertical)

func _on_pirate__is_on_platform(is_on_platform: bool) -> void:
	_is_subject_on_platform = is_on_platform
	
