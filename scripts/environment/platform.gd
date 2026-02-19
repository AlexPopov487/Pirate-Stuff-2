extends AnimatableBody2D

var _player: Player
# TODO fix this! Move animation player to the paltform scene
@export var animation_player: AnimationPlayer


func _on_player_step_detector_body_entered(body: Node2D) -> void:
	if body is not Player || _player != null:
		return
	_player = body
	_player.emit_on_platform_signal(true)
	


func _on_player_step_detector_body_exited(body: Node2D) -> void:
	if body != _player:
		return
	_player.emit_on_platform_signal(false)
	_player = null


func _on_lever_lever_opened() -> void:
	animation_player.play("move")
