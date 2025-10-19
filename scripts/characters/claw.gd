class_name Claw extends Enemy

@export_range(1, 100) var max_health: int = 4
@export var speed: float = 1.5
@export var acceleration: float = 12.0
@export var deceleration: float = 32.0
@export var jump_height: float = 4.0
@export var attack_damage: int = 4

var _is_recovering: bool
@onready var _animated_sprite: AnimatedSprite2D = $InteggorationAnimatedSprite2D

func _ready() -> void:
	_max_health = max_health
	_current_health = max_health
	_speed = speed
	_acceleration = acceleration
	_deceleraiton = deceleration
	_jump_height = jump_height
	_attack_damage = attack_damage
	_invincibility_duration = 0
	_flipped_by_default = true
	_jump_attack_height = sqrt(gravity * 3) * -1
	_jump_attack_length = 8
	super._ready()
	
func _recover():
	_is_recovering = true
	_attack_cooldown.start()
	_stop_patrolling()
	_animated_sprite.play("interrogation")
	run(0)

func _on_attack_cooldown_timeout() -> void:
	_is_recovering = false
	#_resume_patrolling()
	_animated_sprite.stop()
	_try_to_attack()

func _on_target_area_entered(_area: Area2D) -> void:
	_is_player_within_target_area = true
	if _is_recovering:
		return
	# This additional check is necessary, because starfish' target area is too long and 
	# can be triggered when player is hiding behind an obstacle
	if _check_if_player_seen():
		_stop_patrolling()
		attack() 

func _try_to_attack():
	if _is_recovering:
		return
	# This additional check is necessary, because starfish' target area is too long and 
	# can be triggeren when player is hiding behind an obstacle
	if _check_if_player_seen():
		super._try_to_attack()

func take_damage(amount: int, direction: Vector2):
	if _is_recovering:
		if _animated_sprite.is_playing(): # stop interrogation animation
			_animated_sprite.stop()
		super.take_damage(amount, direction)

func _process(_delta: float) -> void:
	if _is_recovering:
		return
	super._process(_delta)
	
func _on_target_area_exited(_area: Area2D) -> void:
	# Do not stop attack_cooldown as it is done with other enemies.
	# For starfish, attack_cooldown is used to imitate recovery state and
	# should not be interrupted
	_interrupt_running_attack()
	_is_player_within_target_area = false
