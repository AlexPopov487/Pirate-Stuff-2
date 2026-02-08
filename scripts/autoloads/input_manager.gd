extends Node

enum InputMode { KEYBOARD, GAMEPAD }
var current_mode = InputMode.KEYBOARD

func _input(event: InputEvent):
	if event is InputEventKey or event is InputEventMouseButton:
		_change_mode(InputMode.KEYBOARD)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Check motion threshold to ignore minor stick drift
		if event is InputEventJoypadMotion and abs(event.axis_value) < 0.2:
			return
		_change_mode(InputMode.GAMEPAD)

func _change_mode(new_mode):
	if current_mode != new_mode:
		current_mode = new_mode
