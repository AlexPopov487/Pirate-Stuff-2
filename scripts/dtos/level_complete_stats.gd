extends Node
class_name LevelCompleteStats

var coins_collected: int
var coins_total: int
var death_count: int
var found_treasure: bool
var collected_map: bool
var is_last_level: bool

func _init(coins_collected: int, 
			coins_total: int, 
			death_count: int, 
			found_treasure: bool, 
			collected_map: bool,
			is_last_level: bool) -> void:
	self.coins_collected = coins_collected
	self.coins_total = coins_total
	self.death_count = death_count
	self.found_treasure = found_treasure
	self.collected_map = collected_map
	self.is_last_level = is_last_level
