extends Area2D


@export var _title_text: String = "Сокровищница найдена"
@onready var _title: LevelTitle = $"../Title"
var _is_title_shown: bool = false


func _on_body_entered(body: Node2D) -> void:
	if _is_title_shown:
		return
	
	_is_title_shown = true
	_title.popup(_title_text)
