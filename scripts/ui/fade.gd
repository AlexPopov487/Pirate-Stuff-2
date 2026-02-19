extends ColorRect
class_name Fade

@onready var fade: ColorRect = $"."

const BLACK :Color = Color(0, 0, 0, 1)
const TRANSPARENT : Color =  Color(0, 0, 0, 0)
var _tween: Tween

func fade_to_clear() -> Signal:
	return _fade_to(TRANSPARENT)

func fade_to_black() -> Signal:
	return _fade_to(BLACK)

func _stop_running_tween():
	if _tween && _tween.is_running():
		_tween.kill()
		
func _fade_to(color_to_fade: Color) -> Signal:
	_tween = create_tween()
	_tween.tween_property(self, "color", color_to_fade, 1)
	return _tween.finished
