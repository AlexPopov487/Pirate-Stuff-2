extends Level
class_name Level8

func _init() -> void:
	_weather = Globals.WEATHER.CLEAR
	_time = Globals.TIME.DAY


func _ready() -> void:
	super._ready()
	_player_armed = true
	_controls_enabled_by_default = true

	if _title != null:
		_title_text = "Остров поросят"
		_title.delayed_popup(_title_text)
