extends Level
class_name Level7

func _init() -> void:
	_weather = Globals.WEATHER.CLEAR
	_time = Globals.TIME.NIGHT


func _ready() -> void:
	super._ready()
	_player_armed = true
	_controls_enabled_by_default = true
	
	if _title != null:
		_title_text = "\"Испаньола\""
		_title.delayed_popup(_title_text)
