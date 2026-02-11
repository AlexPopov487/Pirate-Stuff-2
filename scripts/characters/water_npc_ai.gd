extends Node
class_name WaterNpcAi

@onready var _character: WaterNpc = get_parent()
var _current_direction: float = 1

func _ready() -> void:
	_current_direction = -1 if _character._init_direction == _character.INIT_DIRECTION.LEFT else 1
	
func _process(delta: float) -> void:
	if _character.is_on_wall():
		# Get the direction of the wall we hit (-1 for left wall, 1 for right wall)
		var wall_normal = _character.get_wall_normal()
		
		# wall_normal.x is 1 if the wall is to our left, -1 if the wall is to our right.
		# We only flip if our current direction is heading INTO that wall.
		if sign(wall_normal.x) == 1 and _current_direction == -1:
			_turn(1)
		elif sign(wall_normal.x) == -1 and _current_direction == 1:
			_turn(-1)
	elif _character.global_position.x <= _character._min_level_boundary.x:
		if _current_direction != 1: 
			_turn(1)
	elif _character.global_position.x >= _character._max_level_boundary.x:
		if _current_direction != -1:
			_turn(-1)

	_character.run(_current_direction)
	
func _turn(direction: float) -> void:
	_current_direction = direction 
	_character.face_other_way()
