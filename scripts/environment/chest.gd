extends Area2D


enum STATE{OPENED, CLOSED, LOCKED}
@export var _state: STATE
@export_range(0, 99) var _amount: int
@export var _silver_coin: PackedScene
@export var _gold_coin: PackedScene
@export var _padlock: PackedScene
@onready var _random_gen : RandomNumberGenerator = RandomNumberGenerator.new()

var _total_coin_count: int  
var _booty: Array[Collectable]


func count_coins() -> int:
	return _total_coin_count

func plunder():
	for coin in _booty:
		coin.position = global_position + Vector2.UP * Globals.ppt
		coin.freeze = false
		
		var random_up := Vector2.UP * Globals.ppt * _random_gen.randf_range(5,10)
		var random_side := Vector2.RIGHT * (Globals.ppt * 4) * _random_gen.randf_range(-1, 1)
		coin.apply_impulse(random_up + random_side)
		get_parent().add_child(coin)
 
	_booty.clear()
	
func throw_lock():
	var padlock_body: RigidBody2D = _padlock.instantiate()
	# dedicated imperically
	var padlock_relative_offset = Vector2(0, -7)
	padlock_body.position = global_position + padlock_relative_offset
	padlock_body.freeze = false
		
	var random_up := Vector2.UP * Globals.ppt * _random_gen.randf_range(5,10)
	var random_side := Vector2.RIGHT * (Globals.ppt * 4) * _random_gen.randf_range(-1, 1)
	padlock_body.apply_impulse(random_up + random_side)
	get_parent().add_child(padlock_body)	
	
func _ready() -> void:
	# Defines classes that contain coin-like objects. 
	# These classes implement count_coins() method, that provide level with total coin count 
	add_to_group("coin_source")
	_init_chest()

func _is_even(value: int):
	return value % 2 == 0

func _init_chest():
#	 TODO this probably need fixing, since gold and silver coins are now equal.
	var gold_coin_count: int = 0
	var silver_coin_count: int = 0
	
	if _is_even(_amount):
		@warning_ignore("integer_division")
		gold_coin_count = _amount / 2
	else:
		silver_coin_count = 1
		@warning_ignore("integer_division")
		gold_coin_count = (_amount - 1) / 2
	
	# evening coin distribution
	if gold_coin_count > 2:
		gold_coin_count -= 1
		silver_coin_count += 2
		
	for i in gold_coin_count:
		var coin = _gold_coin.instantiate()
		_booty.append(coin)
		
	for i in silver_coin_count:
		var coin = _silver_coin.instantiate()
		_booty.append(coin)
	
	_compute_total_coin_count()

func _compute_total_coin_count() -> void:
	var total: int = 0
	for body in _booty:
		if body.is_in_group("coin_source") and body.has_method("count_coins"):
			total += body.count_coins()
	_total_coin_count = total

func _on_body_entered(body: Node2D) -> void:
	if body is not Character:
		return
		
	if _state == STATE.LOCKED and File.data.has_key:
		_state = STATE.OPENED
		$/root/game.use_key()
		$/root/game.score_treasure_found()

	if _state == STATE.CLOSED:
		_state = STATE.OPENED
