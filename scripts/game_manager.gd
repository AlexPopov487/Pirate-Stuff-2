extends Node

@onready var health_label: Label = %HealthLabel
@onready var player_state_label: Label = %PlayerStateLabel



func _on_player_player_move_changed(current_move: String) -> void:
	player_state_label.text = "Player's state = " + current_move


func _on_player_player_health_changed(current_health: int) -> void:
	health_label.text = "Player's healt = " + str(current_health)
