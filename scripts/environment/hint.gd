extends Area2D
class_name Hint


@export var _hint: String
@export var _hint_type: Globals.HINT_TYPE = Globals.HINT_TYPE.WOOD_SIGN 
@export var _complete_level_on_exit: bool = false

@onready var _sfx: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")
@onready var _enter_sprite: Sprite2D = $EnterSprite
@onready var _y_sprite: Sprite2D = $YSprite

var _has_entered: bool
var _is_popup_displayed: bool
var _player: Player

signal show_hint_popup(type: Globals.HINT_TYPE, player: Player, text: String)
signal hide_hint_popup(player: Player)

func toggle_hint_visibility():
	_enter_sprite.visible = false
	_y_sprite.visible = false
	if !_is_popup_displayed:
		_is_popup_displayed = true
		show_hint_popup.emit(_hint_type, _player, _format_hint(_hint))
		if _sfx != null:
			_sfx.play()
	else:
		_is_popup_displayed = false
		hide_hint_popup.emit(_player)
		
		if _complete_level_on_exit:
			_toggle_level_completion()

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	_has_entered = true
	_player = body
	
	if InputManager.current_mode == InputManager.InputMode.GAMEPAD:
		_y_sprite.visible = true
		# just in case
		_enter_sprite.visible = false
	else:
		_enter_sprite.visible = true
		# just in case
		_y_sprite.visible = false
	

func _on_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	
	_has_entered = false
	_enter_sprite.visible = false
	_y_sprite.visible = false


func _input(event: InputEvent) -> void:	
	if !_has_entered || _player == null:
		return
		
	if !event.is_action_pressed("interract"):
		return
		
	toggle_hint_visibility()
	
func _toggle_level_completion():
	get_parent().get_parent().get_parent().set_level_completed()
	
func _format_hint(raw_string: String) -> String:
	var bindings = {}
	
	if InputManager.current_mode == InputManager.InputMode.GAMEPAD:
		bindings = {
			"left": "(Стик влево)",
			"right": "(Стик вправо)",
			"jump": "(A)",
			"attack_light": "(X)",
			"attack_heavy": "(B)",
		}
	else:
		bindings = {
			"left": "[A]",
			"right": "[D]",
			"jump": "[Пробел]",
			"attack_light": "(ЛКМ)",
			"attack_heavy": "(ПКМ)"
		}
	
	return raw_string.format(bindings)
