class_name Coin extends Collectable

@onready var _value: int
@export var _type: Globals.COIN_TYPE:
	set(val):
		_type = val
		_value = val

func count_coins() -> int:
#	Retruning _type and not _value, since _value will be accessible
#	only when node is added as a child to the tree
	return _type

func _ready() -> void:
	# Defines classes that contain coin-like objects. 
	# These classes implement count_coins() method, that provide level with total coin count 
	add_to_group("coin_source") 
	_value = _type

func _collect():
	var audio_resource: Resource
	match _type :
		Globals.COIN_TYPE.GOLD_COIN | Globals.COIN_TYPE.SILVER_COIN:
			pass
		_ :
			pass
	$/root/game.collect_coin(_value)
	super._collect()
