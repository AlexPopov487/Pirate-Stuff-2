extends Node

# denotes pixels per tiles. Helps scaling relative values so they are ajusted to the current tileset size
const ppt: int = 32
const EVENING_OVERLAY_COLOR := Color(0.4,0.4,0.4,1)
const NIGHT_OVERLAY_COLOR := Color(0.08,0.08,0.08,1)
const PLAYER_HIGHLIGHT_EVENING_ENERGY: float = 0.3
const PLAYER_HIGHLIGHT_NIGHT_ENERGY: float = 0.7
const GAME_SCENE_PATH: String = "res://scenes/levels/game.tscn"
const TITLE_SCENE_PATH: String = "res://scenes/levels/title.tscn"


enum COIN_TYPE {
	PEARL = 1,
	SILVER_COIN = 1,
	GOLD_COIN = 2,
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

enum TIME {DAY, EVENING, NIGHT}
enum WEATHER {CLEAR, RAIN}
