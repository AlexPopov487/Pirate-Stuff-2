extends Level
class_name Level3


func _ready() -> void:
	super._ready()
	_player_armed = true

	if _title != null:
		_title_text = "Хз, название"
		_title.delayed_popup(_title_text)
