extends StaticBody2D

@export_range(0,100) var _damage = 10

func _on_hitbox_area_entered(area: Area2D) -> void:
	var direction: Vector2 = (area.global_position - global_position).normalized()
	area.get_parent().take_damage(_damage, direction)
