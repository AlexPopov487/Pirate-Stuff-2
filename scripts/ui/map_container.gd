extends GridContainer
class_name MapContainer

@onready var _top_left: TextureRect = $TopLeft
@onready var _top_right: TextureRect = $TopRight
@onready var _bottom_left: TextureRect = $BottomLeft
@onready var _bottom_right: TextureRect = $BottomRight


func display_map(map_type: Globals.MAP_TYPE):
	match map_type:
		Globals.MAP_TYPE.TOP_LEFT:
			_top_left.visible = true
		Globals.MAP_TYPE.BOTTOM_RIGHT:
			_bottom_right.visible = true
		Globals.MAP_TYPE.TOP_RIGHT:
			_top_right.visible = true
		Globals.MAP_TYPE.BOTTOM_LEFT:
			_bottom_left.visible = true
			
func reset_visibility():
	_top_left.visible = false
	_top_right.visible = false
	_bottom_left.visible = false
	_bottom_right.visible = false
