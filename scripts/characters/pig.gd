extends Character
class_name Pig

enum INIT_DIRECTION {LEFT, RIGHT}

@export_range(1, 100) var max_health: int = 100
@export var speed: float = 2.0
@export var acceleration: float = 16.0
@export var deceleration: float = 16.0
@export var _intro_dialogue_resource: DialogueResource
@export var _init_direction: INIT_DIRECTION = INIT_DIRECTION.LEFT
@export var _ai_disabled: bool = false

var _is_on_board: bool
@onready var _enemy_behavoir: Node = $EnemyBehavoir
@onready var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

func jump():
	_sfx.play()
	super.jump()

func set_is_on_board(on_board: bool):
	_is_on_board = on_board

func _ready() -> void:
	_max_health = max_health
	_current_health = max_health
	_speed = speed
	_acceleration = acceleration
	_deceleraiton = deceleration
	_flipped_by_default = false
	super._ready()
	
	if _init_direction == INIT_DIRECTION.LEFT:
		face_left()
	else: 
		face_right()
	
	if _ai_disabled: 
		_enemy_behavoir._is_enabled = false
	DialogueManager.dialogue_ended.connect(_on_intro_dialogue_finished)
	
	
func _on_intro_dialogue_finished(resource: DialogueResource):
	if _intro_dialogue_resource == null: 
		return
	if resource != _intro_dialogue_resource:
		return
	if _is_on_board:
		return
	
	run(1)

func _spawn_dust(dust: PackedScene):
	if _is_on_board:
#		To prevent unnecessary dust when cat is standing on a moving ship
		return
	super._spawn_dust(dust)
