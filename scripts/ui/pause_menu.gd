extends CanvasLayer
class_name PauseMenu

@onready var _pause_menu_overlay: ColorRect = $PauseMenuOverlay
@onready var _resume_button: Button = $Control/VBoxContainer/Wood/VBoxContainer/ResumeButtonContainer/Resume

signal resume_button_pressed()
signal restart_button_pressed()
signal exit_button_pressed()

func set_menu_visibility(is_menu_visible: bool) -> void:
	visible = is_menu_visible
	_pause_menu_overlay.visible = is_menu_visible
	if is_menu_visible:
		# automatically grap focus to enable button navigaion using gamepad
		_resume_button.call_deferred("grab_focus")
	else:
		_resume_button.call_deferred("release_focus")

func _ready() -> void:
	_pause_menu_overlay.visible = false

func _on_resume_pressed() -> void:
	resume_button_pressed.emit()


func _on_restart_pressed() -> void:
	restart_button_pressed.emit()


func _on_exit_pressed() -> void:
	exit_button_pressed.emit()
