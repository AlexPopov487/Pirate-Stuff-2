extends Area2D

enum STATE{OPENED, CLOSED, LOCKED}
@export var _state: STATE
@export var _padlock: PackedScene
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

signal lever_opened()



func _throw_lock():
	var padlock_body: RigidBody2D = _padlock.instantiate()
	# dedicated imperically
	var padlock_relative_offset = Vector2(-6, -4)
	padlock_body.position = global_position + padlock_relative_offset
	padlock_body.freeze = false
	# dedicated imperically
	padlock_body.scale = Vector2(0.5, 0.5)
		
	var random_up := Vector2.UP * Globals.ppt * randf_range(5,10)
	var random_side := Vector2.RIGHT * (Globals.ppt * 4) * randf_range(-1, 1)
	padlock_body.apply_impulse(random_up + random_side)
	# get parent twice (i.e. get to a level scale), since levers are childed to 
	# to elements they are controlling
	get_parent().get_parent().add_child(padlock_body)
	

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
		
	if _state == STATE.LOCKED and File.data.has_key:
		_state = STATE.OPENED
		
		$/root/game.use_key()
		if _sfx:
			_sfx.play()
		_throw_lock()
		
		animated_sprite_2d.play("pull")
		await animated_sprite_2d.animation_finished
		lever_opened.emit()
		
