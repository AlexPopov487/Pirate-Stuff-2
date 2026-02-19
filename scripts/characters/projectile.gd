class_name Projectile extends Area2D

var _direction: Vector2
var _speed: float
var _ttl: int
var _damage
var _is_destroyed: bool = false
var _damage_impulse: int = 2

@onready var _ttl_timer: Timer = $TtlTimer
@onready var _debries: Node2D = $Debries
@onready var _sprite: Sprite2D = $Sprite2D

func with_data(direction: Vector2, speed: float, ttl: int, damage: int) -> Projectile:
	_direction = direction
	_speed = speed
	_ttl = ttl
	_damage = damage
	return self

func _ready() -> void:
	_ttl_timer.start(_ttl)

func _process(delta: float) -> void:
	if _is_destroyed:
		return
		
	position.x += _direction.x * _speed * delta
	
func _destroy():
	_is_destroyed = true
	_sprite.visible = false
	_debries.shutter()
	collision_mask = 0
	
	_ttl_timer.start(0.3)
	await _ttl_timer.timeout
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is not Player:
		return
	area.get_parent().take_damage(_damage, _direction * _damage_impulse)
	_destroy()

func _on_body_entered(_body: Node2D) -> void:
	_destroy()
