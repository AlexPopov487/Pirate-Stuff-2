# Я бы переместил эту логику в менеджмент конкретного уровня, 
# а не всей игры
extends Control

@export var _digits: Array[Texture2D]
@onready var num_hundreds: TextureRect = $num_hundreds
@onready var num_tens: TextureRect = $num_tens
@onready var num_ones: TextureRect = $num_ones

func _ready() -> void:
	num_hundreds.visible = false

func set_value(value: int):
	num_ones.texture = _digits[value % 10]
	@warning_ignore("integer_division")
	var tens = value / 10
	if tens < 10:
		num_hundreds.visible = false
		num_tens.texture = _digits[tens]
	else:
		num_hundreds.visible = true
		num_tens.texture = _digits[tens % 10]
		@warning_ignore("integer_division")
		num_hundreds.texture = _digits[tens / 10]
