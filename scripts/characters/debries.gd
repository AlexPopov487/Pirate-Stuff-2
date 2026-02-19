extends Node2D

@onready var _parts: Array[Node] = get_children()
@onready var _ttl_timer: Timer = $TtlTimer
@onready var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

func shutter():
	if _sfx:
		_sfx.play()
		
	for part in _parts:
		if part is not RigidBody2D: # to skip ttl timer
			continue
		part.visible = true
		part.set_deferred("freeze", false)
		part.set_deferred("sleeping", false)

		var random_up := Vector2.UP * Globals.ppt * randf_range(2, 4)
		var random_side := Vector2.RIGHT * (Globals.ppt * 4) * randf_range(-1, 1)

		# freeze changes are processed at frame boundaries. 
		# If you call apply_impulse() in the same tick, the body may still be frozen. 
		# Deferring or waiting one physics frame fixes it.
		part.call_deferred("apply_impulse",random_up + random_side)
	
	if _sfx:
		await _sfx.finished
	_ttl_timer.start()


func _on_ttl_timer_timeout() -> void:
	for part in _parts:
		if part is not RigidBody2D: # to skip ttl timer
			continue
		part.set_deferred("freeze", true)
		part.visible = false
	get_parent().queue_free()
