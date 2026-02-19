extends Level
class_name Level0

const Balloon = preload("res://resources/dialogues/balloon.tscn")

func _ready() -> void:
	super._ready()
	_player_armed = true
	_controls_enabled_by_default = false
	$/root/game.hide_ui()
	$/root/game.show_letterbox()
	
func set_player(player: Player):
	_player = player

func start_init_script():
	_player.get_controls().set_enabled(false)
	
	await get_tree().create_timer(0.5).timeout
	await _player.start_scripted_run(1, 12)
	await get_tree().create_timer(1.5).timeout
	_show_dialogue(preload("res://resources/dialogues/lvl_0_d_0.dialogue"))
	await DialogueManager.dialogue_ended
	await get_tree().create_timer(0.2).timeout


	await _player.start_scripted_run(1, 2.9)
	await get_tree().create_timer(0.5).timeout
	_show_dialogue(preload("res://resources/dialogues/lvl_0_d_1.dialogue"))
	await DialogueManager.dialogue_ended
	await get_tree().create_timer(0.2).timeout
	
	await _player.start_scripted_run(1, 3)

func _show_dialogue(dialogue_resource: DialogueResource):
	var balloon: Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, "start")
	
