extends Level
class_name Level2


func _ready() -> void:
	super._ready()
	_player_armed = false
	_controls_enabled_by_default = true
	_title_text = "Жажда наживы"
	_title.delayed_popup(_title_text)
