extends Level
class_name Level4


func _ready() -> void:
	super._ready()
	_player_armed = true
	_controls_enabled_by_default = true
	_title_text = "Потерянный остров"
	_title.delayed_popup(_title_text)
