extends PanelContainer
class_name HintSign

@onready var _main_text: Label = $Paper/MainText

var new_line = "\n"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func display(text: String):
#	Manually replacing custom newline character '|' to '\n', 
#   since godot ignores it and prints '\n' as plain text for some reason
	var formatted_text = text.replace("|", new_line)
	_main_text.set_text(formatted_text)
	
	#size = Vector2(0,0)
	#pivot_offset = size / 2
	#set_anchors_preset(Control.PRESET_CENTER)
	visible = true
