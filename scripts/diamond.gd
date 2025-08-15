extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var current_type: DIAMOND_TYPE

enum DIAMOND_TYPE {BLUE = 15, RED = 10, GREEN = 5}
enum MOVE_SET { IDLE, COLLECTED}

var current_move = MOVE_SET.IDLE

func _ready() -> void:
	# This is needed so the pickup is drawn behind other objects
	z_index = -1
	
	match current_type:
		DIAMOND_TYPE.BLUE:
			animated_sprite_2d.play("blue_idle")
		DIAMOND_TYPE.RED:
			animated_sprite_2d.play("red_idle")
		DIAMOND_TYPE.GREEN:
			animated_sprite_2d.play("green_idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_move == MOVE_SET.IDLE:
		pass
	elif current_move == MOVE_SET.COLLECTED:
		animated_sprite_2d.play("collected")
		
		if AnimationUtils.is_last_frame(animated_sprite_2d, "collected"):
			queue_free()
			print(DIAMOND_TYPE.find_key(current_type) + " " + name + " is collected")

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_coin_point(current_type)
	current_move = MOVE_SET.COLLECTED
