extends Area2D

@onready var texture_rect: TextureRect = $TextureRect

var _tween: Tween

var TRANSPARENT_SETUP = PackedColorArray([Color(0.2, 0.196, 0.239, 0.0), Color(0.2, 0.196, 0.239, 0.0)])
var SHADOW_SETUP = PackedColorArray([Color(0.2, 0.196, 0.239), Color(0.2, 0.196, 0.239, 0.0)])

func _ready() -> void:
	var texture: GradientTexture2D = texture_rect.texture
	texture.gradient.colors = SHADOW_SETUP
	visible = true

func _fade_to_clear() -> Signal:
	_stop_running_tween()
	
	_tween = create_tween()
	var texture: GradientTexture2D = texture_rect.texture
	var gradient = texture.gradient
	_tween.tween_property(gradient, "colors", TRANSPARENT_SETUP, 1)
	return _tween.finished


func _stop_running_tween():
	if _tween && _tween.is_running():
		_tween.kill()


func _on_body_entered(_body: Node2D) -> void:
	_fade_to_clear()
