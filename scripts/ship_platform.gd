extends Node2D

enum SHIP_DESTINATION {TO_ISLAND, OFF_ISLAND}
enum MOVE_SET {IDLE, GAINING_PACE, SAILING, STOPPING}
const SPEED = 50

@export var ship_destination: SHIP_DESTINATION
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatableBody2D/AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $AnimatableBody2D/CollisionShape2D

var current_move: MOVE_SET

func _ready() -> void:
	match ship_destination:
		SHIP_DESTINATION.TO_ISLAND:
			current_move = MOVE_SET.SAILING
		SHIP_DESTINATION.OFF_ISLAND:
			current_move = MOVE_SET.IDLE


func _process(delta: float) -> void:
	match current_move:
		MOVE_SET.IDLE:
			animated_sprite_2d.play("idle")
		MOVE_SET.SAILING:
			animated_sprite_2d.play("wind")
			position.x += SPEED * delta
		MOVE_SET.GAINING_PACE:
			if AnimationUtils.is_last_frame(animated_sprite_2d, "to_wind"):
				current_move = MOVE_SET.SAILING
	
			animated_sprite_2d.play("to_wind")
		MOVE_SET.STOPPING:
			animated_sprite_2d.play("to_idle")

func set_moving():
	if current_move == MOVE_SET.IDLE:
		current_move = MOVE_SET.GAINING_PACE

func _on_area_2d_body_entered(player: CharacterBody2D) -> void:
	if ship_destination == SHIP_DESTINATION.OFF_ISLAND:
		set_moving()
