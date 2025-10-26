extends Node

var data: Dictionary = {}

const DATA_FILE_PATH = "res://resources/text_resources.json"

func _ready():
	load_game_data()

func load_game_data():
	var file = FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	
	if FileAccess.get_open_error() != OK:
		print("ERROR: Could not open JSON file: " + DATA_FILE_PATH)
		return

	var content = file.get_as_text()
	
	var json_result = JSON.parse_string(content)
	
	if json_result == null:
		print("ERROR: Could not parse JSON file. Check for syntax errors.")
		return

	data = json_result
	
	print("Successfully loaded game data.")


func get_letter_data(letter_id: String) -> String:
	if data.has("letters") and data["letters"].has(letter_id):
		return data["letters"][letter_id]
	
	print("WARNING: Letter ID '%s' not found." % letter_id)
	return "Text not found."
