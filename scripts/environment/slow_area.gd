extends Area2D


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body
	player.enter_slow_area()


func _on_body_exited(body: Node2D) -> void:
	var player: Player = body
	player.exit_slow_area()
