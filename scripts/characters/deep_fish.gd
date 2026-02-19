extends WaterNpc
class_name DeepFish

const _light_x_facing_right: float = 7
const _light_x_facing_left: float = -7

@onready var _point_light_2d: PointLight2D = $PointLight2D


func face_other_way():
	super.face_other_way()
	if _point_light_2d:
		if _is_facing_left:
			_point_light_2d.position.x = _light_x_facing_left
		else:
			_point_light_2d.position.x = _light_x_facing_right
