extends Level
class_name Level11

func _init() -> void:
	_weather = Globals.WEATHER.CLEAR
	_time = Globals.TIME.DAY


func _ready() -> void:
	super._ready()
	_player_armed = false
	_controls_enabled_by_default = true
	is_last_level = true
