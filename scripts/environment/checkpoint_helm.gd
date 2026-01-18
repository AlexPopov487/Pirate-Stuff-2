class_name Checkpoint extends Area2D

# is set by level manager 
var id
var _checkpoint_reached = false


func _on_body_entered(_body: Node2D) -> void:
	# This is needed for checkpoint to be triggered only once
	#collision_mask = 0
	_checkpoint_reached = true
	File.data.last_checkbox_id = id
	

# handled by spin animation
func set_checkpoint_reached_false():
	if _checkpoint_reached:
		_checkpoint_reached = false
