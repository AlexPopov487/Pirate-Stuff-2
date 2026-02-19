extends Level
class_name Level1

const Balloon = preload("res://resources/dialogues/balloon.tscn")


func _ready() -> void:
	super._ready()
	_player_armed = false
	_controls_enabled_by_default = false

	if _title != null:
		_title_text = "Гибель пирата"
		_title.delayed_popup(_title_text, music_advance_start_sec)

func start_init_script() -> void:
	_player.lie_down()
	await get_tree().create_timer(3).timeout
	_player.get_up()
	
	await get_tree().create_timer(1).timeout
	_show_dialogue(preload("res://resources/dialogues/lvl_1_d_0.dialogue"))
	await DialogueManager.dialogue_ended
	await get_tree().create_timer(0.2).timeout

	await _player.start_scripted_run(1, 2)
	await get_tree().create_timer(0.5).timeout
	_show_dialogue(preload("res://resources/dialogues/lvl_1_d_1.dialogue"))
	await DialogueManager.dialogue_ended
	
	await get_tree().create_timer(0.2).timeout
	await _player.start_scripted_run(1, 2)
	
	_player._controls.set_enabled(true)


func _show_dialogue(dialogue_resource: DialogueResource):
	var balloon: Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, "start")
