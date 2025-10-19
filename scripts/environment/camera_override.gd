extends Area2D
class_name CameraOverride

@onready var _camera: GameCamera = $/root/game/Camera2D
@export var _zoom_override: float
@export var _tween_speed: float

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	_camera.override_zoom(_zoom_override, _tween_speed)

func _on_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	_camera.restore_zoom(_tween_speed)
