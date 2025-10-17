extends Collectable
class_name SmallMap

@export var _type: Globals.MAP_TYPE
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	match _type:
		Globals.MAP_TYPE.TOP_LEFT:
			animated_sprite_2d.play("idle_top_left")
		Globals.MAP_TYPE.BOTTOM_RIGHT:
			animated_sprite_2d.play("idle_bottom_right")
		Globals.MAP_TYPE.TOP_RIGHT:
			animated_sprite_2d.play("idle_top_right")
		Globals.MAP_TYPE.BOTTOM_LEFT:
			animated_sprite_2d.play("idle_bottom_left")

func _collect():
	$/root/game.collect_map(_type)

	# Needed to disable physics processed when a physics-affected coin is being collected,
	# to prevent the "collect" animation follow the player
	# Physics-affected coins will come in handy when they are thrown out of a chest
	call_deferred("set_freeze_enabled", true)
	call_deferred("set_freeze_mode", RigidBody2D.FreezeMode.FREEZE_MODE_STATIC)

	super._collect()
