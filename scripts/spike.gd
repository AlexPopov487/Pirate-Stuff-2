extends Area2D
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = %Player

func _on_body_entered(player: CharacterBody2D) -> void:
	print("Player's hit spikes! You're dead")
	player.change_move_type("DEAD")

func _on_area_entered(enemy_attack_area: Area2D) -> void:
	print("Enemy's hit spikes and now is dead")
	enemy_attack_area.get_parent().set_dead()
