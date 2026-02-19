extends Character
class_name WaterNpc

enum INIT_DIRECTION {LEFT, RIGHT}

@export_range(1, 100) var max_health: int = 100
@export var speed: float = 2.0
@export var acceleration: float = 16.0
@export var deceleration: float = 16.0
@export var _init_direction: INIT_DIRECTION = INIT_DIRECTION.LEFT
@export var _boundaries: CollisionShape2D
@onready var _water_npc_ai: WaterNpcAi = $WaterNpcAi


func _ready() -> void:
	_max_health = max_health
	_current_health = max_health
	_speed = speed
	_acceleration = acceleration
	_deceleraiton = deceleration
	_flipped_by_default = false
	super._ready()
	 
	var half_size: Vector2 = _boundaries.shape.get_rect().size / 2
	_min_level_boundary = _boundaries.global_position - half_size
	_max_level_boundary = _boundaries.global_position + half_size

	if _init_direction == INIT_DIRECTION.LEFT:
		face_left()
	else: 
		face_right()

func _physics_process(delta: float) -> void:
	_try_stop_scripted_movement()
	
	if not _is_facing_left and sign(_direction) == -1:
		face_left()
	elif _is_facing_left and sign(_direction) == 1:
		face_right()
	
	_apply_ground_physics(delta)
	move_and_slide()
	
func _is_outside_boundaries() -> bool:
	return position <= _min_level_boundary || position >= _max_level_boundary
