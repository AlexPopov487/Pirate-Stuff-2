class_name AnimationUtils

static func is_last_frame(animated_sprite_2d: AnimatedSprite2D, animation_name: String) -> bool:
	if not animated_sprite_2d.sprite_frames:
		return false
	if not animated_sprite_2d.sprite_frames.has_animation(animation_name):
		return false
	
	if animated_sprite_2d.animation != animation_name:
		return false
	
	var current_attack_start_frame := animated_sprite_2d.frame
	var attack_start_frame_count = animated_sprite_2d.sprite_frames.get_frame_count(animation_name)
	return current_attack_start_frame == attack_start_frame_count - 1
