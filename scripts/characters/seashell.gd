class_name Seashell extends Shooter

enum TYPE {SHOOTER, BITER}


@export var _pearl_collectable: PackedScene
@export var _type: TYPE

@export_category("Biter")
@export var _bite_damage: int = 1

@onready var _seashell_ai: Node2D = $SeashellAi

func _ready() -> void:
	_projectile_speed = 7
	_projectile_damage = 1
	_fire_cooldown_ttl = 1
	super._ready()
	_attack_damage = _bite_damage

func _process(_delta: float) -> void:
	_set_patrolling_behavior()
	
	if !_seashell_ai.can_do_routine() && _check_if_player_seen():
		get_ready_to_fire()

func _set_patrolling_behavior():
	# override enemy's _set_patrolling_behavior to prevent chasing player 
	var _could_see_player = _can_see_player
	_can_see_player = _check_if_player_seen()

	if !_could_see_player && _can_see_player:
		_stop_patrolling()
	elif _could_see_player && !_can_see_player:
		_resume_patrolling()

func _plunder_pearl():
	var pearl = _pearl_collectable.instantiate()
	pearl.position = global_position + Vector2.UP * Globals.ppt
	pearl.freeze = false
		
	var random_up := Vector2.UP * Globals.ppt * randf_range(10,15)
	pearl.apply_impulse(random_up)
	get_parent().add_child(pearl)

func _on_target_area_entered(_area: Area2D) -> void:
	if _type == TYPE.BITER:
		super._on_target_area_entered(_area)
	

func _on_target_area_exited(_area: Area2D) -> void:
	if _type == TYPE.BITER:
		super._on_target_area_exited(_area)
	
func get_ready_to_fire():
	if _type == TYPE.SHOOTER:
		super.get_ready_to_fire()
	
	
func _stop_patrolling():
		_seashell_ai.stop_routines()

func _resume_patrolling():
		_seashell_ai.start_routines()
