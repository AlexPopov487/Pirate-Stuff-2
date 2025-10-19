class_name Coin extends Collectable

@onready var _value: int = 1
@onready var _type: Globals.COIN_TYPE = Globals.COIN_TYPE.GOLD_COIN

func _ready() -> void:
	_value = _type

func _collect(): 
	$/root/game.collect_coin(_value)
	super._collect()
