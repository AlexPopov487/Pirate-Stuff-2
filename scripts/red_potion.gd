extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = %Player


enum MOVE_SET { IDLE, COLLECTED}
const POTION_EFFECT := 5

var current_move = MOVE_SET.IDLE

func _ready() -> void:
	animated_sprite_2d.play("idle")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_move == MOVE_SET.IDLE:
		pass
	elif current_move == MOVE_SET.COLLECTED:
		animated_sprite_2d.play("collected")
		
		if AnimationUtils.is_last_frame(animated_sprite_2d, "collected"):
			queue_free()
			print(name + " is collected")

func _on_body_entered(player: CharacterBody2D) -> void:
	if not player.can_heal():
		print(name + " player's health is full. Potion's not taken")
		return
	
	player.add_health(POTION_EFFECT)
	current_move = MOVE_SET.COLLECTED
