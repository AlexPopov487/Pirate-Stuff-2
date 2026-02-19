extends Area2D

enum END_LEVEL_TYPE {REGULAR, SECRET}
@export var _end_level_type: END_LEVEL_TYPE = END_LEVEL_TYPE.REGULAR

func _on_body_entered(_body: CharacterBody2D) -> void:
	if _end_level_type == END_LEVEL_TYPE.REGULAR:
		get_parent().set_level_completed(false)
	else: 
		get_parent().set_level_completed(true)
