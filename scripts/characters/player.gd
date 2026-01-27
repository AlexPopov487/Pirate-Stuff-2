class_name Player extends Character

@export_category("Stats")
@export_range(1, 100) var max_health: int = 10
@export var _stamina_restore_speed: int = 7

@export_category("Movement")
@export var speed: float = 4
@export var acceleration: float = 32.0
@export var deceleration: float = 64.0
@export var jump_height: float = 4.0

@export_category("Combat")
@export var attack_damage: int = 1
@export var heavy_attack_damage: int = 2
@export var _max_stamina: int = 10  
@export var _heavy_attack_stamina_cost: int = 5
@export_range(1,5) var invincivbility_duration: int = 1
@export var _has_sword: bool
@export var _is_ready_to_attack_heavily: bool


@onready var _attack_input_buffer: Timer = $Hitbox/InputBuffer
# Started at the end of each attack animation.
# Prevents to start a new animaion sequence (attack_light_1 / air_attack_1) 
# if cooldown timer is ticking. Thus player still can do attack combos but will 
# be forced to wait a bit before starting a fresh attack  
# Heavy attack is exception and not affected by cooldown
# Variable is accessed within the animation tree
@warning_ignore("unused_private_class_variable")
@onready var _attack_cooldown: Timer = $Hitbox/AttackCooldown
@onready var _controls: PlayerBehavior = $Controls
@onready var _terrain_detector: TerrainDetector = $terrain_detector
@onready var _voice: AudioStreamPlayer2D = $Voice

# store collision data to restore them when player is revided
var _collision_layer = collision_layer
var _collision_mask = collision_mask 

# needed for the getting upd animation at level 1
var _is_lying: bool = false
var _should_get_up: bool = false

# use float type to let _stamina_tween increase gauge gradually 
var _current_stamina: float = _max_stamina:
	set(value):
		_current_stamina = value
		_changed_stamina.emit(float(_current_stamina) / float(_max_stamina) * 100)
		
var _stamina_tween: Tween

# I have only one slow area that is basically a pit. Thus, only falling behviour is to be handled
var _has_entered_slow_area: bool = false
var _default_gravity
var _slowed_down_gravity

signal _changed_stamina(stamina_repcentage: float)
signal _is_on_platform(is_on_platform: bool)

func _ready() -> void:
	_max_health = max_health
	_current_health = max_health
	_speed = speed
	_acceleration = acceleration
	_deceleraiton = deceleration
	_jump_height = jump_height
	_attack_damage = attack_damage
	_invincibility_duration = invincivbility_duration
	_heavy_attack_damage = heavy_attack_damage
	super._ready()
	
	_default_gravity = gravity
	_slowed_down_gravity = _default_gravity * 0.25

func get_controls() -> PlayerBehavior:
	return _controls

## Called by the sword object, when first equipped, and by game manager when 
## levels require player to have sword by default 
func equip_sword():
	_has_sword = true

func attack():
	_is_ready_to_attack = true
	# this is needed for cases when animation player is busy and cannot play 
	# attack animation at requested time (e.g. when player spawns attack button)
	# if no attack animation was triggeren within the timer timeout, ignore button press
	_attack_input_buffer.start()
	await _attack_input_buffer.timeout
	_is_ready_to_attack = false

func attack_heavily() -> void:
	if not _can_attack_heavily(): 
		return
		
	_is_ready_to_attack_heavily = true
	# this is needed for cases when animation player is busy and cannot play 
	# attack animation at requed dsted time (e.g. when player spawns attack button)
	# if no attack animation was triggeren within the timer timeout, ignore button press
	_attack_input_buffer.start()
	await _attack_input_buffer.timeout
	_is_ready_to_attack_heavily = false

func is_health_full() -> bool:
	return _current_health == _max_health

func reduce_stamina():
	_current_stamina -= _heavy_attack_stamina_cost
	_restore_stamina()

func restore_stamina_by_potion(amount: int):
	if _stamina_tween && _stamina_tween.is_running():
		_stamina_tween.kill()
	_current_stamina = min(amount + _current_stamina, _max_stamina)
	_restore_stamina()

func emit_on_platform_signal(on_platform: bool):
	_is_on_platform.emit(on_platform)
	
func enter_slow_area():
	_has_entered_slow_area = true

func exit_slow_area():
	_has_entered_slow_area = false

func lie_down():
	_is_lying = true
	
func get_up():
	_should_get_up = true
	
func reset_get_up():
	_is_lying = false
	_should_get_up = false

func revive():
	_is_dead = false
	_is_hit = false
	_current_health = _max_health
	_hurtbox.monitorable = true
	collision_layer = _collision_layer
	collision_mask = _collision_mask
	landed.emit(global_position.y)
	changed_health.emit(float(_current_health) / float(_max_health) * 100)
	_terrain_detector.reset_terrain()

func _apply_air_physics(delta: float):
	if _is_attacking && velocity.y > 0:
		velocity.y = 0
		velocity.x = 0
	elif _has_entered_slow_area:
		velocity = (velocity + get_gravity() * delta) * 0.25
	else:
		super._apply_air_physics(delta)

func _restore_stamina():
	if _stamina_tween && _stamina_tween.is_running():
		_stamina_tween.kill()
	_stamina_tween = create_tween()
	_stamina_tween.tween_property(self, "_current_stamina", _max_stamina, _stamina_restore_speed)

func _can_attack_heavily() -> bool:
	return _current_stamina >= _heavy_attack_stamina_cost
