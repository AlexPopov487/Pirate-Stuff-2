extends CanvasLayer
class_name PauseMenu

@onready var _pause_menu_overlay: ColorRect = $PauseMenuOverlay

signal resume_button_pressed()
signal restart_button_pressed()
signal exit_button_pressed()

func set_menu_visibility(is_visible: bool) -> void:
	visible = is_visible
	_pause_menu_overlay.visible = is_visible

func _ready() -> void:
	_pause_menu_overlay.visible = false


func _on_resume_pressed() -> void:
	resume_button_pressed.emit()


func _on_restart_pressed() -> void:
	restart_button_pressed.emit()


func _on_exit_pressed() -> void:
	exit_button_pressed.emit()
