extends PanelContainer
class_name LevelCompleteWindow

@onready var _coin_label: Label = $MainContainer/Panel/VBoxContainer/CoinContainer/LabelContainer/CoinLabel
@onready var _death_label: Label = $MainContainer/Panel/VBoxContainer/DeathContainer/LabelContainer/DeathLabel
@onready var _treasure_container: HBoxContainer = $MainContainer/Panel/VBoxContainer/TreasureContainer
@onready var _map_container: HBoxContainer = $MainContainer/Panel/VBoxContainer/MapContainer
@onready var _title_label: Label = $MainContainer/TitleLabel
@onready var _next_level_button: Button = $MainContainer/HBoxContainer/NextLevelButton
@onready var _title_button: Button = $MainContainer/HBoxContainer/TitleButton
@onready var _secret_ending_container: HBoxContainer = $MainContainer/Panel/VBoxContainer/SecretEndingContainer
@onready var _coin_container: HBoxContainer = $MainContainer/Panel/VBoxContainer/CoinContainer
@onready var _death_container: HBoxContainer = $MainContainer/Panel/VBoxContainer/DeathContainer

var titles: Array[String] = ["Разрази меня гром! Отличный заход!",
							"Якорь мне в глотку, это победа!",
							"Клянусь бородой – достойный улов!",
							"Неплохо...\nдля сухопутной крысы!",
							"Пушки дымятся, кошель толстеет!",
							"Золотишко блестит — можно жить!",
							"Крысы бегут с корабля,\nа мы — к следующему острову!",
							"С горем пополам,\nно остров покорён!",
							"Трюмы полны, капитан!\nКуда дальше?",
							"На бутылку рома заработал!",
							"А ты не так уж и безнадежен, салага!",
							"Разрази меня гром,\nа ты не промах!",
							"Даже моя деревянная нога\nдвигалась быстрей!",
							"Деньги есть - можно поесть!",
							"Карамба!\nВсе пиастры наши!", 
							"Якорь мне в глотку, вот это добыча!"]

signal next_level_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_treasure_container.visible = false
	_map_container.visible = false
	_secret_ending_container.visible = false
	self.visible = false

func display_window(stats: LevelCompleteStats):
	_title_label.text = titles[randi_range(0, titles.size() - 1)]
	
	if stats.secret_ending:
		_coin_container.visible = false
		_death_container.visible = false
		_secret_ending_container.visible = true
	else: 
		_coin_container.visible = true
		_death_container.visible = true
		_coin_label.text = str(stats.coins_collected) + " / " + str(stats.coins_total)
		_death_label.text = str(stats.death_count)

		_treasure_container.visible = stats.found_treasure
		_map_container.visible = stats.collected_map

	# Despite _treasure_container and _map_container are set to invisible by 
	# default, the node reserves space for them resulting in the whole window
	# being too long. To fix this the window's size, pivot and anchor should 
	# be reset depending on the actual stats being displayed.
	size = Vector2(0,0)
	pivot_offset = size / 2
	set_anchors_preset(Control.PRESET_CENTER)

	if stats.is_last_level:
		_next_level_button.disabled = true
		# automatically grap focus to enable button navigaion using gamepad
		_title_button.call_deferred("grab_focus")
	else: 
		# automatically grap focus to enable button navigaion using gamepad
		_next_level_button.call_deferred("grab_focus")
	self.visible = true


func _on_title_button_pressed() -> void:
	_title_button.call_deferred("release_focus")
	get_tree().change_scene_to_file(Globals.TITLE_SCENE_PATH)
	

func _on_next_level_button_pressed() -> void:
	_next_level_button.call_deferred("release_focus")
	next_level_button_pressed.emit()
