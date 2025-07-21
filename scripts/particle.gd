extends Marker2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_particle_animation_shown := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("none")


func show_particle():
	if !is_particle_animation_shown :
		animated_sprite_2d.play("run_dust")
		is_particle_animation_shown = true
	
	var current_frame = animated_sprite_2d.frame
	var animation_frames_total = animated_sprite_2d.sprite_frames.get_frame_count("run_dust")
	var is_last_frame = current_frame == animation_frames_total - 1
	
	if is_last_frame:
		is_particle_animation_shown = false
	
