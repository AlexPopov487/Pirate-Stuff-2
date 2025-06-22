extends Marker2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_popup_animation_shown := false
var current_dialogue_playing :Enums.DIALOGUE_TYPE = Enums.DIALOGUE_TYPE.NONE

func _ready() -> void:
	animated_sprite_2d.play("none")

func show_popup(dialogue_type: Enums.DIALOGUE_TYPE):
	if dialogue_type == Enums.DIALOGUE_TYPE.NONE:
		return
	
	if (!is_popup_animation_shown 
	or (current_dialogue_playing != dialogue_type and current_dialogue_playing != Enums.DIALOGUE_TYPE.NONE)):
		current_dialogue_playing = dialogue_type
		animated_sprite_2d.play(get_animation_popup_name(dialogue_type))
		is_popup_animation_shown = true
	
	var current_frame = animated_sprite_2d.frame
	var animation_frames_total = animated_sprite_2d.sprite_frames.get_frame_count(get_animation_popup_name(dialogue_type))
	var is_last_frame = current_frame == animation_frames_total - 1
	
	if is_last_frame:
		is_popup_animation_shown = false
	
		
func get_animation_popup_name(dialogue_type: Enums.DIALOGUE_TYPE) -> String: 
	match dialogue_type:
		Enums.DIALOGUE_TYPE.EXCLAMATION: 
			return "exclamation_popup"
		Enums.DIALOGUE_TYPE.INTERROGATION: 
			return "interrogation_popup"
		Enums.DIALOGUE_TYPE.DEAD:
			return "dead_popup"
		_:
			return ""
