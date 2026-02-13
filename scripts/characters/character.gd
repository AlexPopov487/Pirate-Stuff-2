class_name Character extends CharacterBody2D

@export_category("Sprite")
# some sprites (enemy ones) are flipped facing left by default, which affects 
# face_right() and face_left() methods behavior. Use this variabe to decide 
# whether sprite needs to be flipped depending on the specific character
var _flipped_by_default = false
var _is_facing_left: bool = false

# relative value in tiles per second
var _speed: float = 8.0
# set to _speed by default. Changed when stepping on mud
var _current_speed: float
var _acceleration: float = 16
var _deceleraiton: float = 32

@export_category("Jump")
@export var _jump_dust: PackedScene 
var _jump_height: float = 2.5
# defines how much of a ground control (velocity etc) is available when in the air
var _air_control: float = 0.5
var _max_health: int = 1: get = get_max_health


# Set to 0 if no invincibility is needed (for enemies). 
# In this case there is no need to add invincibility timer node to the tree
var _invincibility_duration: int
var _attack_damage: int = 1
var _heavy_attack_damage: int = 5
var _current_health := _max_health: get = get_current_health

var _invincibility_timer: Timer
var _is_hit: bool = false
var _is_dead: bool = false
var _is_ready_to_attack: bool = false

# Used when character is controlled via run_for() method
var _scripted_destination_x: float
var _is_movement_scripted: bool = false
signal scripted_movement_finished()

@export var _is_attacking: bool = false
@export var _is_heavy_attack_on: bool = false #needed to set proper damage during attack


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var animation_tree: AnimationTree = $Sprite2D/AnimationPlayer/AnimationTree
@onready var _hitbox: Area2D = $Hitbox


signal changed_direction(is_facing_left: bool) 
signal landed(floor_pos_y: float)
signal changed_health(health_percentage: float)
signal died()

var _jump_velocity
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction: float
var _was_on_floor: bool

var _min_level_boundary: Vector2
var _max_level_boundary: Vector2

#region public methods
func get_max_health() : return _max_health

func get_current_health() : return _current_health

func take_damage(amount: int, direction: Vector2):
	if _is_dead:
		return
		
	_interrupt_running_attack()
	_current_health = max(_current_health - amount, 0)
	changed_health.emit(float(_current_health) / float(_max_health) * 100)
	velocity = direction * Globals.ppt * 5
	
	print(name + ": damage taken, current health = ", str(_current_health))
	if _current_health <= 0:
		_die()
		return
	
	_is_hit = true
	
	# Available for Player only
	if _invincibility_duration > 0:
		_become_invincible()

func restore_health(amount: int):
	if _is_dead:
		return
		
	_current_health = min(amount + _current_health, _max_health)
	changed_health.emit(float(_current_health) / float(_max_health) * 100)

func set_hit_false():
	if _is_hit:
		_is_hit = false
		
func set_ready_to_attack_false():
	if _is_ready_to_attack:
		_is_ready_to_attack = false

func set_level_boundaries(min_boundary: Vector2, max_boundary: Vector2):
	_min_level_boundary = min_boundary
	_max_level_boundary = max_boundary

func face_left():
	if _is_dead || _is_attacking:
		return
	_is_facing_left = true
	_sprite.flip_h = !_flipped_by_default
	changed_direction.emit(_is_facing_left)
	_hitbox.scale.x = 1 if _flipped_by_default else -1

func face_right():
	if _is_dead || _is_attacking:
		return
		
	_is_facing_left = false
	_sprite.flip_h = _flipped_by_default
	changed_direction.emit(_is_facing_left)
	_hitbox.scale.x = -1 if _flipped_by_default else 1

func face_other_way():
	if _is_dead || _is_attacking:
		return
		
	_is_facing_left = !_is_facing_left
	_sprite.flip_h = !_sprite.flip_h
	changed_direction.emit(_is_facing_left)
	_hitbox.scale.x = 1 if _flipped_by_default && _is_facing_left else -1
	
func run(direction: float):
	if _is_dead || _is_attacking:
		return
		
	_direction = direction
	
func start_scripted_run(direction: float, tiles: float):
	var current_x = position.x
	var destination_x = current_x + (Globals.ppt * tiles * direction)
	
	_scripted_destination_x = destination_x
	_is_movement_scripted = true
	
	run(direction)
	
	await scripted_movement_finished
	
func jump():
	if _is_dead || _is_attacking:
		return
		
	if is_on_floor():
		velocity.y = _jump_velocity
		_spawn_dust(_jump_dust)
		
func stop_jump():
	if _is_dead || _is_attacking:
		return
		
	if velocity.y < 0:
		velocity.y = 0

## Method is called by both 'dead_hit' and 'dead_ground' animations but the signal should be 
## triggered only once by either 'dead_hit' or 'dead_ground'.
## Animation is detected incorrectly at runtime, thus taking curr animation name
## as method argument
# TODO should not this be player specific behavior???
func emit_death_signal(curr_animation: String):
	var will_play_dead_ground: bool = curr_animation == 'dead_hit' and is_on_floor()
	if will_play_dead_ground:
		return
	died.emit()
	
	
	
func attack():
	if _is_dead:
		return
	
	_is_ready_to_attack = true

func attack_heavily():
	pass #implemented in player
	
	
func step_on_mud():
	_current_speed *= 0.1
	
func step_on_ground():
	_current_speed = _speed
#endregion


func _ready() -> void:
	if _invincibility_duration > 0:
		_invincibility_timer = $Hurtbox/InvincibilityTimer
		
	_speed *= Globals.ppt
	_current_speed = _speed
	_acceleration *= Globals.ppt
	_deceleraiton *= Globals.ppt
	_jump_height *= Globals.ppt
	
	_set_jump_velocity()
	
	_is_facing_left = _flipped_by_default
	if _is_facing_left: 
		face_left() 
	else: 
		face_right()
	_hitbox.monitoring = false
	_is_attacking = false
	
func _physics_process(delta: float) -> void:
	_try_stop_scripted_movement()
	
	if not _is_facing_left and sign(_direction) == -1:
		face_left()
	elif _is_facing_left and sign(_direction) == 1:
		face_right()
	
	if is_on_floor():
		_apply_ground_physics(delta)
	else:
		_apply_air_physics(delta)
	
	_was_on_floor = is_on_floor()
	move_and_slide()
	_check_level_boundaries()
	
	if not _was_on_floor and is_on_floor():
		_landed()

	
func _apply_air_physics(delta: float):
	velocity += get_gravity() * delta
	
	# i.e. if character moves in the air
	if _direction:
		velocity.x = move_toward(velocity.x, _direction * _current_speed, delta * _acceleration * _air_control)

func _apply_ground_physics(delta: float):
	# No input pressed or input released. Should decelerate to a stop
	if _direction == 0:
		velocity.x = move_toward(velocity.x, 0, delta * _deceleraiton)
	# Character is stationary or already moving in the direction of the button pressed. Should keep accelerating
	elif velocity.x == 0 || sign(_direction) == sign(velocity.x):
		velocity.x = move_toward(velocity.x, _direction * _current_speed, _acceleration * delta)
	# Character is moving but the player changed direction. Shoud decelerate in the new direction
	else:
		velocity.x = move_toward(velocity.x, _direction * _current_speed, delta * _deceleraiton)
		
	
func _spawn_dust(dust: PackedScene):
	var _dust = dust.instantiate()
	_dust.position = position
	_dust.flip_h = _sprite.flip_h
	# since dust will be a child of the parent (i.e. sibling of the player) 
	# it will live independently of the player 
	get_parent().add_child(_dust)


#TODO should not this be player specific behavior?
func _landed():
	landed.emit(position.y)


func _check_level_boundaries():
	# level boundaries values are set for the player only. 
	# Other characters are free to leave
	if _min_level_boundary and _max_level_boundary:
		position.x = clamp(position.x, _min_level_boundary.x, _max_level_boundary.x)
		position.y = clamp(position.y, _min_level_boundary.y, _max_level_boundary.y)

#TODO should not this be player specific behavior?
func _become_invincible():
	_hurtbox.set_deferred("monitorable", false)
	_invincibility_timer.start(_invincibility_duration)
	await _invincibility_timer.timeout
	_hurtbox.monitorable = true

#TODO should not this be player specific behavior?
func _die():
	_is_dead = true
	_hurtbox.set_deferred("monitorable", false)
	# prdevent dead character from colldecting treasure, trigger checkpoints
	# or colliding with other objects
	collision_layer = 0
	collision_mask = 1
	_direction = 0
	

func _on_hitbox_area_entered(hurtbox: Area2D) -> void:
	var impulse: Vector2
	var damage:int
	
	if _is_heavy_attack_on:
		impulse = (hurtbox.global_position - global_position).normalized() + (Vector2.UP * 2)
		damage = _heavy_attack_damage
	else:
		impulse = (hurtbox.global_position - global_position).normalized()
		damage = _attack_damage
	
	hurtbox.get_parent().take_damage(damage, impulse)
	
func _interrupt_running_attack():
	if _is_ready_to_attack:
		set_ready_to_attack_false()

	if _is_attacking || _is_heavy_attack_on:
		_is_attacking = false
		_is_heavy_attack_on = false
		_hitbox.monitoring = false
			
func _set_jump_velocity():
	# multiply by -1 since in 2d platformers the y-axis is inverted. 
	# Thus, to move up, negative values should be used	
	_jump_velocity = sqrt(gravity * _jump_height) * -1
	
func _try_stop_scripted_movement():
	if _is_movement_scripted:
		if absf(position.x) >= absf(_scripted_destination_x):
			_is_movement_scripted = false
			_direction = 0
			scripted_movement_finished.emit()
