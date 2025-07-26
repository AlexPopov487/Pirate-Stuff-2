extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum MOVE_SET { IDLE, COLLECTED}

var current_move = MOVE_SET.IDLE

func _ready() -> void:
	# This is needed so the pickup is drawn behind other objects
	z_index = -1
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

func _on_body_entered(body: Node2D) -> void:
	current_move = MOVE_SET.COLLECTED
