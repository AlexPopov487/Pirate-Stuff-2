extends Node

@onready var health_label: Label = %HealthLabel
@onready var player_state_label: Label = %PlayerStateLabel
@onready var coin_stats: Label = %CoinStats
@onready var stamina_label: Label = $"../CanvasLayer/StaminaLabel"


var collectedCoinsCount = 0

func _on_player_player_move_changed(current_move: String) -> void:
	player_state_label.text = "Player's state = " + current_move


func _on_player_player_health_changed(current_health: int) -> void:
	health_label.text = "Player's health = " + str(current_health)


func _on_player_player_stamina_changed(current_stamina: int) -> void:
	stamina_label.text = "Player's stamina = " + str(current_stamina)


func add_coin_point():
	collectedCoinsCount += 1
	coin_stats.text = "Coins collected: " + str(collectedCoinsCount)
