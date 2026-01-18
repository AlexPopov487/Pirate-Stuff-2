extends CanvasLayer
class_name LevelTitle

const TRANSPARENT: Color = Color(1,1,1,0)
const OPAQUE: Color = Color(1,1,1,1)

@onready var _timer: Timer = $Timer
@onready var _h_box_container: HBoxContainer = $HBoxContainer

var _tween: Tween
@onready var _label: Label = $HBoxContainer/PanelContainer/Label

func delayed_popup(text: String) -> void:
	_timer.start(1)
	await _timer.timeout
	popup(text)

func popup(text: String) -> void:
	_label.text = text
	visible = true
	_h_box_container.modulate = TRANSPARENT
	await _fade_to_opaque()
	_timer.start(2)
	await _timer.timeout
	_timer.start(2)
	await _fade_to_clear()
	visible = false

func _ready() -> void:
	visible = false

func _fade_to_clear() -> Signal:
	_stop_running_tween()
	_tween = create_tween()
	_tween.tween_property(_h_box_container, "modulate", TRANSPARENT, 1)
	return _tween.finished
	
func _fade_to_opaque() -> Signal:
	_stop_running_tween()
	_tween = create_tween()
	_tween.tween_property(_h_box_container, "modulate", OPAQUE, 1)
	return _tween.finished

func _stop_running_tween():
	if _tween && _tween.is_running():
		_tween.kill()
