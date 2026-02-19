extends Node
class_name EnemyBehavior

@onready var _character: Character = get_parent()
@onready var _look_around_timer: Timer = $look_around_timer
@onready var _activity_timer: Timer = $activity_timer
@onready var _jump_cooldown_timer: Timer = $jump_cooldown_timer

@export var _obstacle_ray: RayCast2D
@export var _ground_ray: RayCast2D
@export var _jump_restrictor: Area2D
@export var _ledge_behavior: LEDGE_BEHAVIOR


enum ACTIVITIES {STAND, LOOK_AROUND, WANDER, JUMP}
enum LEDGE_BEHAVIOR {TURN_AROUND, JUMP_OFF}

var _current_activity: ACTIVITIES = ACTIVITIES.STAND
var _direction: float = -1
var _is_enabled: bool = true


func stop_patroling():
	_is_enabled = false
	if _current_activity == ACTIVITIES.WANDER:
		_character.run(0)

func resume_patroling():
	_is_enabled = true
	
func is_patrolling() -> bool:
	return _is_enabled

func _ready() -> void:
	_set_random_activity()
	
		
func _process(_delta: float) -> void:
	if not _is_enabled: 
		return
		
	_set_routine()

func _set_routine() -> void:
	match _current_activity:
		ACTIVITIES.STAND:
			_stop_moving()
		ACTIVITIES.LOOK_AROUND:
			_stop_moving()
			_look_around()
		ACTIVITIES.WANDER:
			_wander_around()
		ACTIVITIES.JUMP:
			_stop_moving()
			_jump_once()

func _set_random_activity():	
	var picked_activity = false
	while !picked_activity:
		var activity_candidate = ACTIVITIES.values().pick_random()
		if activity_candidate != _current_activity:
			_current_activity = activity_candidate
			picked_activity = true
	
	var activity_duration = randi_range(2, 6)
	_wind_activity_timer(activity_duration)

func _wind_activity_timer(duration: int):
	if not _activity_timer.is_stopped():
		return

	_activity_timer.start(duration)

func _look_around():
	if _look_around_timer.is_stopped(): 
		_face_other_way()
		_look_around_timer.start(1)

func _wander_around():
	var can_move_backwards = _can_move_in_direction(-_direction)
	var can_move_futher = _can_move_in_direction(_direction)
	
	if not can_move_futher and not can_move_backwards:
		#print(get_parent().name + " stands on a tiny surface, nowhere to run. Defaults to STAND")
		_current_activity = ACTIVITIES.STAND
		return
	
	if not can_move_futher:
		_turn()
	
	_character.run(_direction)

func _jump_once():
	if _has_enemies_or_player_nearby():
		return
	if _jump_cooldown_timer.is_stopped():
		_character.jump()
		_jump_cooldown_timer.start()

func _has_enemies_or_player_nearby() -> bool:
#	Some characters using EnemyAI do not need _jump_restrictor (e.g. Piggy NPC)
	if _jump_restrictor == null:
		return false
	
	var overlapping_bodies = _jump_restrictor.get_overlapping_bodies()
	var has_other_bodies: bool = false
	for body in overlapping_bodies:
		if body is Character and body != _character:
			has_other_bodies = true
			break
	
	return has_other_bodies

func _can_move_in_direction(direction: float) -> bool:
	_position_obstacle_rays(direction)
	
	if  _obstacle_ray.is_colliding():
		return false
	
	var can_ignore_pit = false
	match _ledge_behavior:
		LEDGE_BEHAVIOR.TURN_AROUND:
			can_ignore_pit = _ground_ray.is_colliding()
		LEDGE_BEHAVIOR.JUMP_OFF:
			# allow moving furhter regardless of the possible pits on the way
			can_ignore_pit = true
	
	return can_ignore_pit

func _turn():
	_direction = -_direction
	_position_obstacle_rays(_direction)
	
func _face_other_way():
	_turn()
	_character.face_other_way()

func _stop_moving():
	if _character.velocity.x != 0:
		_character.run(0)

func _on_timer_timeout() -> void:
	_set_random_activity()


func _on_look_around_timer_timeout() -> void:
	if _current_activity == ACTIVITIES.LOOK_AROUND:
		_look_around()
	
func _position_obstacle_rays(direction: float):
	_obstacle_ray.rotation_degrees = 180 if direction > 0 else 0 
	_obstacle_ray.force_raycast_update()

	_ground_ray.position.x = abs(_ground_ray.position.x) * direction
	_ground_ray.target_position.x = abs(_ground_ray.target_position.x) * direction
	_ground_ray.force_raycast_update()
