class_name Data
extends Resource

@export var coins: int
@export var has_key: bool
@export var last_checkbox_id: int
@export var current_level_idx: int
# В gdscript нет сетов, поэтому для обеспечения уникальности элементов использую мапу
@export var collected_maps: Dictionary
@export var death_count: int
@export var found_secret_treasure: bool
@export var found_map: bool

func _init():
	coins = 0
	last_checkbox_id = 0
	has_key = false
	current_level_idx = 1
	collected_maps = {
		Globals.MAP_TYPE.TOP_LEFT: false,
		Globals.MAP_TYPE.TOP_RIGHT: false,
		Globals.MAP_TYPE.BOTTOM_LEFT: false,
		Globals.MAP_TYPE.BOTTOM_RIGHT: false
	}
	death_count = 0
	found_map = false
	found_map = false
