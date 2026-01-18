extends Node
class_name LevelCompleteStats

var coins_collected: int
var coins_total: int
var death_count: int
var found_treasure: bool
var collected_map: bool
var is_last_level: bool

func _init(_coins_collected: int, 
			_coins_total: int, 
			_death_count: int, 
			_found_treasure: bool, 
			_collected_map: bool,
			_is_last_level: bool) -> void:
	self.coins_collected = _coins_collected
	self.coins_total = _coins_total
	self.death_count = _death_count
	self.found_treasure = _found_treasure
	self.collected_map = _collected_map
	self.is_last_level = _is_last_level
