extends CanvasLayer
class_name HintUi

@onready var _wood_sign: HintSign = $Sign
@onready var _letter: HintSign = $ScrollContainer/Letter
@onready var _scroll_container: ScrollContainer = $ScrollContainer
@onready var _scroll_guide_label: Label = $ScrollGuideLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hide_letter_hint()
	_hide_wood_hint()
	hide()

func hide_ui():
	_hide_letter_hint()
	_hide_wood_hint()
	hide()

func show_wood_hint(text: String):
	if (_letter.visible):
		_letter.hide()
#	TODO ПЕРЕНЕСТИ ТЕКСТ ПОДСКАЗОК В JSON РЕСУРС
	_wood_sign.display(text)
	_wood_sign.visible = true
	visible = true
	
func show_letter(text: String):
	if (_wood_sign.visible):
		_wood_sign.hide()
	
	var letter_text = DataManager.get_letter_data(text)
	
	_letter.display(letter_text)
	_letter.visible = true
	_scroll_container.visible = true
	_scroll_guide_label.visible = true
	visible = true
	
func _hide_wood_hint():
	_wood_sign.hide()
	
func _hide_letter_hint():
	_letter.hide()
	_scroll_container.visible = false
	_scroll_guide_label.visible = false
		
