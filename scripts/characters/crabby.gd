class_name Crabby extends Enemy

@export_range(1, 100) var max_health: int = 1
@export var speed: float = 3.0
@export var acceleration: float = 16.0
@export var deceleration: float = 32.0
@export var jump_height: float = 2.0
@export var attack_damage: int = 1

func _ready() -> void:
	_max_health = max_health
	_current_health = max_health
	_speed = speed
	_acceleration = acceleration
	_deceleraiton = deceleration
	_jump_height = jump_height
	_attack_damage = attack_damage
	_invincibility_duration = 0
	_flipped_by_default = true
	super._ready()
