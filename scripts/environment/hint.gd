extends Area2D
class_name Hint


@export var _hint: String
@export var _hint_type: Globals.HINT_TYPE = Globals.HINT_TYPE.WOOD_SIGN 
var _has_entered: bool
var _is_popup_displayed: bool
@onready var _enter_sprite: Sprite2D = $EnterSprite
var _player: Player

signal show_hint_popup(type: Globals.HINT_TYPE, player: Player, text: String)
signal hide_hint_popup(player: Player)

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	_has_entered = true
	_player = body
	_enter_sprite.visible = true
	

func _on_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	
	_has_entered = false
	_enter_sprite.visible = false


func _input(event: InputEvent) -> void:	
	if !_has_entered || _player == null:
		return
		
	if !event.is_action_pressed("interract"):
		return
		
	_enter_sprite.visible = false
	if !_is_popup_displayed:
		_is_popup_displayed = true
		show_hint_popup.emit(_hint_type, _player, _hint)
	else:
		_is_popup_displayed = false
		hide_hint_popup.emit(_player)
