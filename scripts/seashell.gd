extends Node2D

@export var player: CharacterBody2D
@export var tile_map: TileMap
@export var direction: CANNON_DIRECTION
signal should_hit_player


@onready var attack_ray_left: RayCast2D = $enemy/AttackArea/AttackRayLeft
@onready var attack_ray_right: RayCast2D = $enemy/AttackArea/AttackRayRight
@onready var attack_area: Area2D = $enemy/AttackArea
@onready var collision_shape_2d: CollisionShape2D = $enemy/AttackArea/CollisionShape2D
@onready var attack_cooldown_timer: Timer = $enemy/AttackArea/AttackCooldownTimer
@onready var damage_cooldown_timer: Timer = $enemy/AttackArea/DamageCooldownTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy: Node2D = $enemy
@onready var player_detect_timer: Timer = $PlayerDetectTimer


enum MODE {PEACE, COMBAT}
enum MOVE_SET { IDLE, ATTACKING, DEAD = 6, HIT, RECOVERING}
enum CANNON_DIRECTION {LEFT = -1, RIGHT = 1}

const MAX_HEALTH = 4
const PLAYER_ALERT_DISTANCE = 300

var has_attack_animation_started = false
var has_fooling_animation_started = false
var is_projectile_fired = false
var can_take_damage = true

var health = MAX_HEALTH
var current_mode := MODE.PEACE:
	set(updated_mode):
		if current_mode == updated_mode:
			return
		current_mode = updated_mode
		print(name + " in " + MODE.find_key(current_mode))

var current_move := MOVE_SET.IDLE:
	set(updated_move):
		if current_move == updated_move:
			return
		current_move = updated_move
		print(name + " move changed to " + MOVE_SET.find_key(current_move))


func _ready() -> void:
	current_mode = MODE.PEACE
	
	if direction == CANNON_DIRECTION.RIGHT:
		animated_sprite_2d.flip_h = true
		
	enemy.player_alert_distance = PLAYER_ALERT_DISTANCE
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_mode()
	set_current_move_by_mode()
	
func change_mode():
	var is_player_seen = enemy.is_player_seen(tile_map, position, player)
	var is_aiming_at_player = direction == enemy.get_direction_to_player(position, player.position)

	if (is_player_seen and is_aiming_at_player):
		current_mode = MODE.COMBAT
		player_detect_timer.stop()
	elif (!is_player_seen and current_mode == MODE.COMBAT):
		# When enemy's in COMBAT mode but has lost the player, wait till 
		# player_detect_timer runs out and switched the mode to PEACE
		if player_detect_timer.is_stopped():
			player_detect_timer.start()


func set_current_move_by_mode():
	match current_mode:
		MODE.PEACE:
			# reset to IDLE just in case, since there cannot be any other moves in PEACE mode
			if current_move != MOVE_SET.IDLE:
				current_move = MOVE_SET.IDLE
			
			animated_sprite_2d.play("idle")
		MODE.COMBAT:
			if not is_during_attack():
				start_attack()
			elif current_move == MOVE_SET.ATTACKING:
				handle_attack_animation()
			elif current_move == MOVE_SET.RECOVERING:
				animated_sprite_2d.play("idle_static")
				if attack_cooldown_timer.is_stopped():
					attack_cooldown_timer.start()
			elif current_move == MOVE_SET.HIT:
				animated_sprite_2d.play("hit")
				if is_last_frame("hit"):
					if !attack_cooldown_timer.is_stopped():
						current_move = MOVE_SET.RECOVERING
					else:
						current_move = MOVE_SET.IDLE
			elif current_move == MOVE_SET.DEAD:
				animated_sprite_2d.play("dead")
				if (is_last_frame("dead")):
					queue_free()

func is_during_attack() -> bool:
	return (current_move == MOVE_SET.ATTACKING
		or current_move == MOVE_SET.RECOVERING
		or current_move == MOVE_SET.HIT
		or current_move == MOVE_SET.DEAD)

func start_attack():
	var is_aiming_at_player = direction == enemy.get_direction_to_player(position, player.position)
	if (!is_aiming_at_player): 
		return
	current_move = MOVE_SET.ATTACKING
	
	# Explicitly stopping all timers to mark a fresh attack start and avoid 
	# sideeffects on timers timeout 
	attack_cooldown_timer.stop()
	damage_cooldown_timer.stop()
	
func handle_attack_animation():
	if not has_attack_animation_started:
		animated_sprite_2d.play("attack_prepare")
		has_attack_animation_started = true
	
	if is_last_frame("attack_prepare"):
		animated_sprite_2d.play("attack_fire")
		# doublecheck, since _process may be executed multiple times during the same animation
		if not is_projectile_fired:
			fire()
			is_projectile_fired = true
	
	if is_last_frame("attack_fire"):
		current_move = MOVE_SET.RECOVERING
		has_attack_animation_started = false
		is_projectile_fired = false
		
		
func fire():
	var pearl = preload("res://scenes/pearl.tscn").instantiate()
	pearl.connect("should_hit_player", _on_pearl_should_hit_player)
	var muzzle_x = position.x + (20 * direction)
	var muzzle_y = position.y + (10)
	pearl.position = Vector2(muzzle_x, muzzle_y)
	pearl.direction = direction
	get_parent().add_child(pearl)

func hit_player():
	print(name + " hits!")
	# TODO refactor that. I do not know how external fields are accessed 
	if player.current_move != 6: #DEAD 
		player.change_move_type("HIT")
		
		
func is_last_frame(animation_name: String) ->bool:
	if animated_sprite_2d.animation != animation_name:
		return false
	
	var current_attack_start_frame := animated_sprite_2d.frame
	var attack_start_frame_count = animated_sprite_2d.sprite_frames.get_frame_count(animation_name)
	return current_attack_start_frame == attack_start_frame_count - 1


func take_damage():
	if !can_take_damage:
		return
	
	enter_combat_mode()
	
	can_take_damage = false
	damage_cooldown_timer.start()
	health -= 1
	if health <= 0:
		current_move = MOVE_SET.DEAD
	else:
		current_move = MOVE_SET.HIT
	print(name + "; Damage taken from player. Current healt: " + str(health))

func take_damage_heavy(direction_to_push: float, push_force:float):
	if !can_take_damage:
		return
	
	enter_combat_mode()
	
	can_take_damage = false
	damage_cooldown_timer.start()
	
	health -= 2
	if health <= 0:
		current_move = MOVE_SET.DEAD
	else:
		current_move = MOVE_SET.HIT
		
	print(name + "; Heavy damage taken from player")


func _on_player_detect_timer_timeout() -> void:
	if current_move == MOVE_SET.DEAD:
		return
	
	current_mode = MODE.PEACE
	current_move = MOVE_SET.IDLE

	if has_attack_animation_started:
		has_attack_animation_started = false
		
func _on_attack_cooldown_timer_timeout() -> void:
	# Sonce damage can be taken in RECOVERING state, this timer will still be
	# active during the DEAD state. To avoid weird occassions of resurrection, 
	# this check is required 
	if current_move == MOVE_SET.DEAD:
		return
		
	current_move = MOVE_SET.IDLE 

func _on_damage_cooldown_timer_timeout() -> void:
	can_take_damage = true
	
# unlikely to happen
func _on_enemy_killzone_entered() -> void:
	current_move = MOVE_SET.DEAD

func enter_combat_mode():
	current_mode = MODE.COMBAT

func _on_pearl_should_hit_player() -> void:
	hit_player()
