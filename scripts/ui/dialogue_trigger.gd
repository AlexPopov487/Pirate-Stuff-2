extends Hint

const Balloon = preload("res://resources/dialogues/balloon.tscn")

enum DIALOGUE_POPUP_TYPE {ONETIME, REUSABLE}

@export var _dialogue: DialogueResource
@export var _trigger_sprite_shown: bool = true
@export var _dialogue_type: DIALOGUE_POPUP_TYPE = DIALOGUE_POPUP_TYPE.REUSABLE
@onready var _sprite_2d: Sprite2D = $Sprite2D

var _dialogue_triggered: bool
# works only for ONETIME dialogues
var _is_exhausted: bool 

func _ready() -> void:
	_sprite_2d.visible = _trigger_sprite_shown

func trigger_dialogue(player: Player):
	if _dialogue_type == DIALOGUE_POPUP_TYPE.ONETIME:
		_is_exhausted = true
	
	var balloon: Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	
	player.get_controls().set_enabled(false) 
	balloon.start(_dialogue, "start")
	
	await DialogueManager.dialogue_ended
	player.get_controls().set_enabled(true)
	_dialogue_triggered = false

func _on_body_entered(body: Node2D) -> void:
	if _is_exhausted:
		return
	super._on_body_entered(body)

func _input(event: InputEvent) -> void:	
	if _is_exhausted || !_has_entered || _player == null || _dialogue_triggered:
		return
		
	if !event.is_action_pressed("interract"):
		return
	
	_enter_sprite.visible = false
	_dialogue_triggered = true
	trigger_dialogue(_player)
