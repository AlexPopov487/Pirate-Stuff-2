extends Level
class_name Level1


func _ready() -> void:
	super._ready()
	_player_armed = false
	_controls_enabled_by_default = true
	_title_text = "Начало"
	_title.delayed_popup(_title_text)
