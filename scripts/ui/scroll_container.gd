extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# The amount to scroll per mouse wheel tick (adjust as needed)
const SCROLL_AMOUNT = 50 

func _input(event):
	if !visible: 
		return
	# Check if the event is a key press and that the key is currently being pressed (not released)
	if (event is InputEventKey or event is InputEventJoypadButton) and event.pressed:
		
		var new_scroll_pos: int = scroll_vertical
		var scrolled: bool = false

		# 1. Handle Down Arrow Key Press
		if event.is_action_pressed("scroll_down"):
			new_scroll_pos += SCROLL_AMOUNT
			scrolled = true
			
		# 2. Handle Up Arrow Key Press
		elif event.is_action_pressed("scroll_up"):
			new_scroll_pos -= SCROLL_AMOUNT
			scrolled = true

		# 3. Apply the new scroll position if a relevant key was pressed
		if scrolled:
			# The 'set_v_scroll' method automatically clamps the value 
			# between 0 and the maximum scroll extent.
			set_v_scroll(new_scroll_pos)
			
			# Crucial: Consume the event to prevent it from propagating further 
			# (e.g., to the editor or other UI elements).
			get_viewport().set_input_as_handled()
