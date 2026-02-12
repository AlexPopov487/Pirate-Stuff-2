extends Node

const AUTOSAVE_PATH: String = "user://autosave.tres"
var data: Data


func _ready() -> void:
	start_new_game()
	
func remove_user_progress() -> void:
	if ResourceLoader.exists(AUTOSAVE_PATH):
		var error = DirAccess.remove_absolute(AUTOSAVE_PATH)
		if error == OK:
			print("User progress wiped successfully!")
		else:
			print("Error deleting user progress file: ", error)
	
func is_save_file_exists() -> bool:
	# ResourceLoader.exists() caches results failing to provide actual data 
	var game_data = ResourceLoader.load(AUTOSAVE_PATH, "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE)
	return game_data != null
	
func start_new_game() -> void:
	data = Data.new()
	
func load_game():
	data = ResourceLoader.load(AUTOSAVE_PATH)

func save_game():
	ResourceSaver.save(data, AUTOSAVE_PATH)
	print("Level saved with data: " + str(data))

func change_level(new_level_idx):
	data.coins = 0
	data.current_level_idx = 0
	data.last_checkbox_id = 0
	data.has_key = false
	data.current_level_idx = new_level_idx
	data.death_count = 0
	data.found_map = false
	data.found_secret_treasure = false
	
func increase_death_count():
	data.death_count += 1
	
func set_found_secret_treasure():
	data.found_secret_treasure = true
	
func set_found_map():
	data.found_map = true
	
func reset_current_level_map_progress() -> void:
	data.found_map = false
	if data.found_map_type:
		data.collected_maps[data.found_map_type] = false
		data.found_map_type = null

func reset_collected_maps() -> void :
	for map in data.collected_maps:
		data.collected_maps[map] = false
