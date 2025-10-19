extends Node

const AUTOSAVE_PATH: String = "user://autosave.tres"
var data: Data


func _ready() -> void:
	start_new_game()
	
func is_save_file_exists() -> bool:
	return ResourceLoader.exists(AUTOSAVE_PATH)

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
