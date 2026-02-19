extends Sprite2D
class_name Explosion

@onready var animation_player: AnimationPlayer = $AnimationPlayer
signal _flash_white()

func _ready() -> void:
	visible = false

func explode():
	if animation_player.is_playing():
		return
	
	visible = true
	animation_player.play("explode")

func emit_flash_signal():
	_flash_white.emit()
