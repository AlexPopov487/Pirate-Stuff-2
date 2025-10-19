extends Node2D

enum SHIP_DESTINATION {TO_ISLAND, OFF_ISLAND}
enum MOVE_SET {IDLE, GAINING_PACE, SAILING, STOPPING}
const SPEED: int = 70

@export var _ship_destination: SHIP_DESTINATION
@export var _is_disabled: bool = false
@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatableBody2D/AnimatedSprite2D

var _current_move: MOVE_SET = MOVE_SET.IDLE
var _has_landed: bool
var _player: Player

func _process(delta: float) -> void:	
	match _current_move:
		MOVE_SET.IDLE:
			_animated_sprite_2d.play("idle")
		MOVE_SET.SAILING:
			_animated_sprite_2d.play("wind")
			position.x += SPEED * delta
		MOVE_SET.GAINING_PACE:
			if AnimationUtils.is_last_frame(_animated_sprite_2d, "to_wind"):
				_current_move = MOVE_SET.SAILING
			_animated_sprite_2d.play("to_wind")
		MOVE_SET.STOPPING:
			_animated_sprite_2d.play("to_idle")
			await _animated_sprite_2d.animation_finished
			_current_move = MOVE_SET.IDLE

func set_moving():
	if _current_move == MOVE_SET.IDLE:
		_current_move = MOVE_SET.GAINING_PACE

func _on_area_2d_body_entered(body: Node2D) -> void:
	if _is_disabled: 
		return
		
	if body is Player:
		_player = body
		_handle_player_on_board()
	elif body is TileMap:
		_set_ashore()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
	
func _handle_player_on_board() -> void:
	if _has_landed: 
		return
	
	if !_player:
		return
		
	_player.get_controls().set_enabled(false)
	
	match _ship_destination:
		SHIP_DESTINATION.TO_ISLAND:
			_current_move = MOVE_SET.SAILING
		SHIP_DESTINATION.OFF_ISLAND:
			_current_move = MOVE_SET.GAINING_PACE

func _set_ashore():
	_has_landed = true
	_current_move = MOVE_SET.STOPPING
	if _player:
		_player.get_controls().set_enabled(true)
