extends Node2D

@onready var _continue_button: Button = $CanvasLayer/Buttons/ContinueButtonContainer/ContinueButton
@onready var _fade: Fade = $CanvasLayer/fade
@onready var _confirmation_window: PanelContainer = $CanvasLayer/Confirmation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_fade.visible = true
	_continue_button.disabled = !File.is_save_file_exists()
	_fade.fade_to_clear()


func _on_new_game_button_pressed() -> void:
	if !File.is_save_file_exists():
		_start_new_game()
	else:
		_confirmation_window.visible = true
		

func _start_new_game():
	await _fade.fade_to_black()
	File.start_new_game()
	File.save_game()
	get_tree().change_scene_to_file(Globals.GAME_SCENE_PATH)


func _on_continue_button_pressed() -> void:
	await _fade.fade_to_black()
	File.load_game()
	get_tree().change_scene_to_file(Globals.GAME_SCENE_PATH)


func _on_confirmation_no_button_pressed() -> void:
	_confirmation_window.visible = false


func _on_confirmation_yes_button_pressed() -> void:
	_start_new_game()


func _on_exit_button_pressed() -> void:
	await _fade.fade_to_black()
	get_tree().quit()
