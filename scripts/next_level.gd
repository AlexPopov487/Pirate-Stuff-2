extends Area2D

const LEVEL_BASE_PATH = "res://scenes/levels/level_"
const SCENE_EXTENTION = ".tscn"

func _on_body_entered(body: CharacterBody2D) -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	var next_level_number = current_scene_path.to_int() + 1
	var next_level_path = LEVEL_BASE_PATH + str(next_level_number) + SCENE_EXTENTION
	print("Level " + current_scene_path+ " complete, moving to the " + next_level_path)
	
	# SWITCH LEVEL
	#get_tree().change_scene_to_file(next_level_path)
