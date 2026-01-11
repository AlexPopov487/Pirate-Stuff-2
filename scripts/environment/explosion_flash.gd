extends CanvasLayer

@onready var _timer: Timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
func flash():
	visible = true
	_timer.start()


func _on_timer_timeout() -> void:
	$/root/game._on_last_level_complete()
