extends Level
class_name Level5

func _init() -> void:
	_weather = Globals.WEATHER.RAIN
	_time = Globals.TIME.EVENING

func _ready() -> void:
	super._ready()
	_player_armed = true
	_controls_enabled_by_default = true

	if _title != null:
		_title_text = "Дождь не может лить вечно"
		_title.delayed_popup(_title_text, music_advance_start_sec)
