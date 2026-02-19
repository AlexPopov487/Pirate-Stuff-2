extends PointLight2D

enum TYPE {STATIC, FOLLOWING}
# Manual offset to make thi highlight be drawn from players horizontal center
const PLAYER_Y_OFFSET = 12 
@export var _subject: Character
@export var _type: TYPE

func _process(_delta: float) -> void:
	if _type == TYPE.STATIC:
		return
	global_position.x = _subject.global_position.x
	global_position.y = _subject.global_position.y - PLAYER_Y_OFFSET
	
