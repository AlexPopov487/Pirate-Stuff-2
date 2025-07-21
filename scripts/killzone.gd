extends Area2D
@onready var timer: Timer = $Timer
@export var player: CharacterBody2D


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func _on_player_player_move_changed(current_move: String) -> void:
	if current_move == "DEAD": #dead
		print("Killzone signal triggered. You're dead")
		Engine.time_scale = 0.5
		timer.start()


func _on_body_entered(player: CharacterBody2D) -> void:
	print("Player's out of playing ground! You're dead")
	player.change_move_type("DEAD")


func _on_area_entered(enemy_attack_area: Area2D) -> void:
	print("Enemy's out of playing ground and now is dead")
	enemy_attack_area.get_parent().set_dead()
