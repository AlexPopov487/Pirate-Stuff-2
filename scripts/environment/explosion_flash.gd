extends CanvasLayer

enum BEHAVIOR {INTRO, OUTRO}

@onready var _timer: Timer = $Timer
@export var _flash_behavior: BEHAVIOR

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
func flash():
	$/root/game.hide_ui()
	visible = true
	_timer.start()

func _on_timer_timeout() -> void:
	match _flash_behavior:
		BEHAVIOR.INTRO: $/root/game._on_intro_complete()
		BEHAVIOR.OUTRO: $/root/game._on_last_level_complete()
