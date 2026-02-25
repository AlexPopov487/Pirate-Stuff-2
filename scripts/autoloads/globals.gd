extends Node

# denotes pixels per tiles. Helps scaling relative values so they are ajusted to the current tileset size
const ppt: int = 32
const EVENING_OVERLAY_COLOR := Color(0.6,0.6,0.6,1)
const NIGHT_OVERLAY_COLOR := Color(0.08,0.08,0.08,1)
const DAWN_OVERLAY_COLOR := Color(0.89, 0.86, 0.8, 1.0)
const TWIGHLIGHT_OVERLAY_COLOR := Color(0.965, 0.933, 0.969, 1.0)
const MORNING_OVERLAY_COLOR := Color(1.0, 0.953, 0.937, 1.0)
const MIDDAY_OVERLAY_COLOR := Color(0.969, 0.988, 1.0, 1.0)
const PLAYER_HIGHLIGHT_EVENING_ENERGY: float = 0.3
const PLAYER_HIGHLIGHT_DAWN_ENERGY: float = 0.07
const PLAYER_HIGHLIGHT_NIGHT_ENERGY: float = 0.7
const GAME_SCENE_PATH: String = "res://scenes/levels/game.tscn"
const TITLE_SCENE_PATH: String = "res://scenes/levels/title.tscn"


enum COIN_TYPE {
	PEARL = 1,
	SILVER_COIN = 1,
	GOLD_COIN = 1,
	GREEN_DIAMOND = 5,
	BLUE_DIAMOND = 10,
	RED_DIAMOND = 15
}

enum MAP_TYPE {
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT
}

enum TIME {DAY, EVENING, NIGHT, DAWN, TWIGHLIGHT, MORNING, MIDDAY}
enum WEATHER {CLEAR, RAIN}
enum HINT_TYPE {WOOD_SIGN, LETTER}



## Peeks into a PackedScene to find the value of a specific property 
## without instantiating the scene.
static func get_value_from_packed_scene(ps: PackedScene, property_name: String) -> int:
	if ps == null: 
		return 0
	
	var state: SceneState = ps.get_state()
	
	# The root node of the PackedScene is always at index 0
	var node_index = 0
	
	# Loop through all properties of the root node
	for p_idx in state.get_node_property_count(node_index):
		if state.get_node_property_name(node_index, p_idx) == property_name:
			return state.get_node_property_value(node_index, p_idx)
			
	return 0

## Checks if the root node of a PackedScene belongs to a specific group
static func is_scene_in_group(ps: PackedScene, group_name: String) -> bool:
	if ps == null: return false
	var state = ps.get_state()
	for scene_group_name in state.get_node_groups(0):
		if scene_group_name == group_name:
			return true
	return false
