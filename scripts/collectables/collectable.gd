class_name Collectable extends CollisionObject2D

@onready var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _character: Player


func _collect(): 
	# to prevent duplication collisions at the same time
	collision_mask = 0
	
	_sfx.play()
	_sprite.play("collected")

	# Needed to disable physics processed when a physics-affected coin is being collected,
	# to prevent the "collect" animation follow the player
	# Physics-affected coins will come in handy when they are thrown out of a chest
	call_deferred("set_freeze_enabled", true)
	call_deferred("set_freeze_mode", RigidBody2D.FreezeMode.FREEZE_MODE_STATIC)

	await _sprite.animation_finished
	queue_free()
	print(name + " is collected")
	
func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	
	_character = body
	_collect()
