class_name CannonBall extends Projectile


@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_damage_impulse = 3
	super._ready()
	_animated_sprite.play("idle")

func _destroy():
	_is_destroyed = true
	collision_mask = 0
	
	_animated_sprite.play("explosion")
	_debries.shutter()
	await _animated_sprite.animation_finished
	_animated_sprite.visible = false
	
	_ttl_timer.start(0.3)
	await _ttl_timer.timeout
	queue_free()
