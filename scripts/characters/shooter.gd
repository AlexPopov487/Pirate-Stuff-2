class_name Shooter extends Enemy

enum FACE_DIRECTION {LEFT, RIGHT}

@export_range(1, 100) var max_health: int = 4
@export var _line_of_sight_tiles: int = 5
@export var _face_direction: FACE_DIRECTION = FACE_DIRECTION.LEFT

@export_category("Projectile")
@export var _projectile: PackedScene
@export var _projectile_speed: float = 5
@export var _projectile_damage: float = 2
@export var _projectile_ttl_seconds: int = 5
@export var _fire_cooldown_ttl: float = 2

@export_category("Internal vars")
@export var _is_ready_to_fire: bool

@onready var _projectile_origin: Node2D = $ProjectileOrigin
@onready var _fire_cooldown: Timer = $FireCooldown
@onready var _debries: Node2D = $Debries

func shoot():
	var projectile_dir: Vector2 = Vector2.LEFT if _face_direction == FACE_DIRECTION.LEFT else Vector2.RIGHT
	var projectile: Area2D = (_projectile
	.instantiate()
	.with_data(projectile_dir, _projectile_speed, _projectile_ttl_seconds, _projectile_damage))
	projectile.global_position = _projectile_origin.global_position
	get_parent().add_child(projectile)

func get_ready_to_fire():
	if !_fire_cooldown.is_stopped():
		return
	_is_ready_to_fire = true

func _ready() -> void:
	var shooter_direction = 1 if _flipped_by_default && _is_facing_left else -1
	var sight_x = _line_of_sight_tiles * Globals.ppt * shooter_direction
	_line_of_sight.target_position.x = sight_x

	_max_health = max_health
	_current_health = max_health
	_invincibility_duration = 0
	_flipped_by_default = true
	super._ready()
	
	match _face_direction:
		FACE_DIRECTION.LEFT:
			_is_facing_left = true
			face_left()
		FACE_DIRECTION.RIGHT:
			_is_facing_left = false
			face_right()
			_debries.scale *= -1
			_projectile_origin.position.x *= -1

	_projectile_speed *= Globals.ppt
	_fire_cooldown.wait_time = _fire_cooldown_ttl

func _process(_delta: float) -> void:
	if _check_if_player_seen():
		get_ready_to_fire()

func _check_if_player_seen() -> bool:
	return _line_of_sight.is_colliding() && _line_of_sight.get_collider() is Player
	
