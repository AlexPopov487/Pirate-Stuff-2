extends Area2D

func _on_body_entered(_body: CharacterBody2D) -> void:
	get_parent().set_level_completed()
