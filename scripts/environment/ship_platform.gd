extends Node2D
class_name ShipPlaftorm

enum SHIP_DESTINATION {TO_ISLAND, OFF_ISLAND}
enum MOVE_SET {IDLE, GAINING_PACE, SAILING, STOPPING}
const SPEED: int = 70

@export var _ship_destination: SHIP_DESTINATION
@export var _is_disabled: bool = false
@onready var _audio_stream_player_2d: AudioStreamPlayer2D = $AnimatableBody2D/AudioStreamPlayer2D

var _current_move: MOVE_SET = MOVE_SET.IDLE
var _has_landed: bool
var _player: Player
var _initial_position: Vector2

func _ready() -> void:
	_initial_position = position

func _process(delta: float) -> void:	
	if _current_move == 	MOVE_SET.SAILING:
			position.x += SPEED * delta

# Honestly, not sure, where it is called
func set_moving():
	if _current_move == MOVE_SET.IDLE:
		_current_move = MOVE_SET.GAINING_PACE

# Used by animation player
func set_sailing():
	_current_move = MOVE_SET.SAILING
	
func set_idle():
	_current_move = MOVE_SET.IDLE

func reset():
	_is_disabled = false
	_current_move = MOVE_SET.IDLE
	_has_landed = false
	position = _initial_position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if _is_disabled: 
		return

	if body is Player:
		_player = body
		_handle_player_on_board()
	elif body is TileMap:
		_set_ashore()
	elif body is Cat:
		_hande_cat_on_board(body)
	
func _handle_player_on_board() -> void:
	if _has_landed: 
		return
	
	if !_player:
		return
		
	_player.velocity = Vector2.ZERO
	_player._direction = 0
	_player.get_controls().set_enabled(false)
	
	match _ship_destination:
		SHIP_DESTINATION.TO_ISLAND:
			_current_move = MOVE_SET.SAILING
		SHIP_DESTINATION.OFF_ISLAND:
			_current_move = MOVE_SET.GAINING_PACE

func _hande_cat_on_board(cat: Cat):
	cat.set_is_on_board(true)
	cat.run(0)

func _set_ashore():
	_has_landed = true
	_current_move = MOVE_SET.STOPPING
	if _audio_stream_player_2d.playing:
		_audio_stream_player_2d.stream = null
	if _player:
		_player.get_controls().set_enabled(true)
