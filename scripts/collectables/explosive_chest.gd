extends Area2D
class_name ExplosiveChest

enum STATE{OPENED, CLOSED}
@export var _state: STATE = STATE.CLOSED
@export var _explosion: Explosion
@onready var _collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _on_body_entered(body: Node2D) -> void:
	if body is not Character:
		return

	if _state != STATE.CLOSED:
		return
		
	_state = STATE.OPENED
	
func _explode():
	await get_tree().create_timer(0.5).timeout
	var height: float = _collision_shape_2d.shape.get_rect().size.y
	_explosion.position = Vector2(position.x, position.y - (height / 2))
	#_explosion.scale = (Vector2(4,4))
	_explosion.explode()
