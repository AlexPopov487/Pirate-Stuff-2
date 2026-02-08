extends Area2D


@export var _title_text: String = "Сокровищница найдена"
@onready var _title: LevelTitle = get_node_or_null("../Title")
var _is_title_shown: bool = false
var _sfx_sound: Resource = load("res://audio/environment/treasure_found.wav")

func _on_body_entered(_body: Node2D) -> void:
	if not File.data.has_key:
		return
		
	if _is_title_shown:
		return
		
	if _title == null:
		push_warning("No title node found, unable to show treasure title")
		return
		
	_play_sfx()
	_is_title_shown = true
	_title.popup(_title_text)


func _play_sfx():
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = _sfx_sound
	get_tree().root.add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)
