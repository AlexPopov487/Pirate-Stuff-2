extends RigidBody2D

@export var _treasure_scene: PackedScene

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _debries: Node2D = $Debries

var has_taken_damage_once: bool

func take_damage(_amount: int, direction: Vector2):
	if has_taken_damage_once:
		return
	
	has_taken_damage_once = true
	apply_impulse(direction  * 4 * Globals.ppt)
	_animated_sprite_2d.play("destroyed")
	_plunder_potion()
	await  _animated_sprite_2d.animation_finished
	_debries.shutter()
	collision_layer = 0 # to prevent player colliding with phantom crate
	_animated_sprite_2d.visible = false
	

func count_coins() -> int:
	var value = 0
	if Globals.is_scene_in_group(_treasure_scene, "coin_source"):
		value = Globals.get_value_from_packed_scene(_treasure_scene, "_type")
	
	return value

func _ready() -> void:
	# Defines classes that contain coin-like objects. 
	# These classes implement count_coins() method, that provide level with total coin count 
	add_to_group("coin_source") 
	
	
func _plunder_potion():
	if !_treasure_scene: 
		return
	
	var treasure: RigidBody2D = _treasure_scene.instantiate()
	treasure.position = global_position + Vector2.UP * Globals.ppt
	treasure.freeze = false
		
	var random_up := Vector2.UP * Globals.ppt * randf_range(10,15)
	treasure.apply_impulse(random_up)

	get_parent().call_deferred("add_child", treasure)
	
