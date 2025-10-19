extends Node
class_name PlayerBehavior

@onready var _character = get_parent()
var _is_enabled: bool

func set_enabled(value: bool):
	_is_enabled = value

func _input(event: InputEvent) -> void:
	if not _is_enabled:
		return
	
	if event.is_action_pressed("jump"):
		_character.jump()
	
	if event.is_action_released("jump"):
		_character.stop_jump()
		
	if event.is_action_pressed("attack_light"):
		_character.attack()

	if event.is_action_pressed("attack_heavy"):
		_character.attack_heavily()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not _is_enabled:
		return
		
	_character.run(Input.get_axis("move_left", "move_right"))
