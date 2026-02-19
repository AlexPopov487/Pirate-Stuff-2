class_name Gauge extends Control

@onready var _fill_full_pt = 1
@onready var fill: TextureRect = $fill

func set_value(percent_amount: float):
	var fill_x = percent_amount / 100 * _fill_full_pt
	fill.size.x = fill_x
