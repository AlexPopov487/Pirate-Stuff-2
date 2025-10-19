extends ParallaxBackground

@export var autoscroll_speed: int = 50

# background autoscroll
func _process(delta: float) -> void:
	scroll_base_offset.x -= autoscroll_speed * delta
