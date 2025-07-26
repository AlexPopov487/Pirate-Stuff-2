extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
signal should_hit_player


enum MOVE_SET { LAUNCHED, EXPLODING}

var speed = 200
var direction: int = 1
var current_move = MOVE_SET.LAUNCHED
var is_colliding = false

func _ready():
	# This is needed so the projectile is drawn above the shooting trap (cannon, etc)
	z_index = 1

func _process(delta: float) -> void:
	if current_move == MOVE_SET.LAUNCHED:
		pass
	elif current_move == MOVE_SET.EXPLODING:
		handle_explode_animation()
	

func _physics_process(delta: float) -> void:
	if current_move == MOVE_SET.LAUNCHED:
		position.x += direction * speed * delta
	

func handle_explode_animation():
	animated_sprite_2d.play("exploding")
		
	if is_last_frame("exploding"):
		print(name + " has exloded")
		queue_free()
		
		
func _on_body_entered(body: Node2D) -> void:
	current_move = MOVE_SET.EXPLODING
	
	if body is CharacterBody2D:
		should_hit_player.emit()

func is_last_frame(animation_name: String) ->bool:
	if animated_sprite_2d.animation != animation_name:
		return false
	
	var current_animation_start_frame := animated_sprite_2d.frame
	var animation_frame_count = animated_sprite_2d.sprite_frames.get_frame_count(animation_name)
	return current_animation_start_frame == animation_frame_count - 1


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print(name + " is out of visibility range, eliminating")
	queue_free()
