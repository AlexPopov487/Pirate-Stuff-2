extends Area2D
class_name Hint

@export var hint: String
var _has_entered: bool
@onready var _enter_sprite: Sprite2D = $EnterSprite

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	_has_entered = true
	_enter_sprite.visible = true
	

func _on_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	
	_has_entered = false
	_enter_sprite.visible = false


func _input(event: InputEvent) -> void:	
	if !_has_entered:
		return
		
	if event.is_action_pressed("interract"):
		print(hint)
		_enter_sprite.visible = false
