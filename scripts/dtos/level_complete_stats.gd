extends Node
class_name LevelCompleteStats

var coins_collected: int
var coins_total: int
var death_count: int
var found_treasure: bool
var collected_map: bool
var is_last_level: bool
var secret_ending: bool

func _init(
	_coins_collected: int = 0, 
	_coins_total: int = 0, 
	_death_count: int = 0, 
	_found_treasure: bool = false, 
	_collected_map: bool = false,
	_is_last_level: bool = false,
	_secret_ending: bool = false
) -> void:
	self.coins_collected = _coins_collected
	self.coins_total = _coins_total
	self.death_count = _death_count
	self.found_treasure = _found_treasure
	self.collected_map = _collected_map
	self.is_last_level = _is_last_level
	self.secret_ending = _secret_ending

static func create_secret_ending() -> LevelCompleteStats:
	var stats = LevelCompleteStats.new()
	stats.secret_ending = true
	stats.is_last_level = true
	return stats
