extends Hint

const Balloon = preload("res://resources/dialogues/balloon.tscn")

@export var _dialogue: DialogueResource
@export var _trigger_sprite_shown: bool = true

@onready var _sprite_2d: Sprite2D = $Sprite2D

var _dialogue_triggered: bool

func _ready() -> void:
	_sprite_2d.visible = _trigger_sprite_shown

func trigger_dialogue(player: Player):
	var balloon: Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	
	player.get_controls().set_enabled(false) 
	balloon.start(_dialogue, "start")
	
	await DialogueManager.dialogue_ended
	player.get_controls().set_enabled(true)
	_dialogue_triggered = false

func _input(event: InputEvent) -> void:	
	if !_has_entered || _player == null || _dialogue_triggered:
		return
		
	if !event.is_action_pressed("interract"):
		return
		
	_dialogue_triggered = true
	trigger_dialogue(_player)

#func _on_body_entered(body: Node2D) -> void:
	#if body is not Player:
		#return
		#
	#trigger_dialogue(body)
#
#
#func _on_body_exited(body: Node2D) -> void:
	#if body is not Player:
		#return
	#
	#var player : Player = body
	#if not player.get_controls()._is_enabled:
		#player.get_controls().set_enabled(true)
