extends Level
class_name Level6

func _init() -> void:
	_weather = Globals.WEATHER.CLEAR
	_time = Globals.TIME.NIGHT


func _ready() -> void:
	super._ready()
	_player_armed = true
	_controls_enabled_by_default = true

	if _title != null:
		_title_text = "В тени, да не в обиде"
		_title.delayed_popup(_title_text)	
