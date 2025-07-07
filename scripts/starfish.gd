extends Node2D

@export var default_move: MOVE_SET = MOVE_SET.IDLE
@export var player: CharacterBody2D
@export var SPEED = 35
@export var SPINNING_SPEED = 150
@export var SPINNING_DISTANCE = 150
@export var tile_map: TileMap

@onready var attack_ray_left: RayCast2D = $enemy/AttackArea/AttackRayLeft
@onready var attack_ray_right: RayCast2D = $enemy/AttackArea/AttackRayRight
@onready var attack_area: Area2D = $enemy/AttackArea
@onready var collision_shape_2d: CollisionShape2D = $enemy/AttackArea/CollisionShape2D
@onready var attack_cooldown_timer: Timer = $enemy/AttackArea/AttackCooldownTimer
@onready var damage_cooldown_timer: Timer = $enemy/AttackArea/DamageCooldownTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy: Node2D = $enemy
@onready var player_detect_timer: Timer = $PlayerDetectTimer
@onready var exclamation: Marker2D = $Exclamation



enum MODE {PEACE, COMBAT}
enum MOVE_SET { IDLE, RUNNING, ATTACKING, DEAD = 6, HIT, ALERTED, RECOVERING, TURNING }


const MAX_HEALTH = 2
# 1 = moving right. -1 = moving left
var direction = 1
var can_take_damage := true
var has_attack_animation_started = false
var current_attack_target_x = null

var current_mode := MODE.PEACE:
	set(updated_mode):
		if current_mode == updated_mode:
			return
		current_mode = updated_mode
		print(name + " in " + MODE.find_key(current_mode))

var current_move := default_move:
	set(updated_move):
		if current_move == updated_move:
			return
		current_move = updated_move
		print(name + " move changed to " + MOVE_SET.find_key(current_move))

var health = MAX_HEALTH


func _ready() -> void:
	direction = 1
	animated_sprite_2d.flip_h = true


func _process(delta: float) -> void:
	flip_sprite()
	change_mode()
	set_current_move_by_mode(delta)

func flip_sprite():
	if enemy.has_obstacle_to_right() and direction == 1:
		direction = -1
		animated_sprite_2d.flip_h = false
		
		if current_mode == MODE.PEACE:
			current_move = MOVE_SET.TURNING
	elif enemy.has_obstacle_to_left() and direction == -1:
		direction = 1
		animated_sprite_2d.flip_h = true
		
		if current_mode == MODE.PEACE:
			current_move = MOVE_SET.TURNING
	
func change_mode():
	var is_player_seen = enemy.is_player_seen(tile_map, position, player)
	if (is_player_seen):
		current_mode = MODE.COMBAT
		player_detect_timer.stop()
	elif (!is_player_seen and current_mode == MODE.COMBAT):
		# When enemy's in COMBAT mode but has lost the player, wait till 
		# player_detect_timer runs out and switched the mode to PEACE
		if player_detect_timer.is_stopped():
			player_detect_timer.start()
	

func set_current_move_by_mode(delta: float):
	match current_mode:
		MODE.PEACE:
			match current_move:
				MOVE_SET.TURNING:
					animated_sprite_2d.play("turning")
					if is_last_frame("turning"):
						current_move = default_move
				MOVE_SET.RUNNING:
					animated_sprite_2d.play("running")
					position.x += SPEED * delta * direction
				MOVE_SET.IDLE:
					animated_sprite_2d.play("idle")
			
		MODE.COMBAT:
			if not is_during_attack():
				start_attack(delta)
			
			if current_move == MOVE_SET.ALERTED:
				handle_alert_animation(delta)
			elif current_move == MOVE_SET.ATTACKING:
				handle_attack_animation(delta)
			elif current_move == MOVE_SET.RECOVERING:
				animated_sprite_2d.play("idle")
				exclamation.show_popup(Enums.DIALOGUE_TYPE.INTERROGATION)
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

func start_attack(delta: float):
#	TODO track collision with player using CollisionShape2d?
	var is_player_near = attack_ray_right.is_colliding() or attack_ray_left.is_colliding()
	
	if is_player_near:
		current_move = MOVE_SET.ALERTED
	else:
		current_move = MOVE_SET.ATTACKING
	
func is_during_attack() -> bool:
	return (current_move == MOVE_SET.ATTACKING
		or current_move == MOVE_SET.RECOVERING
		or current_move == MOVE_SET.ALERTED
		or current_move == MOVE_SET.HIT
		or current_move == MOVE_SET.DEAD)


func handle_alert_animation(delta: float):
	if !animated_sprite_2d.animation == "attack_end":
		spin_to_position(delta,  position.x + (SPINNING_DISTANCE / 3))
		
	if (is_last_frame("attack_end")):
		current_move = MOVE_SET.ATTACKING


func handle_attack_animation(delta: float):
	if !has_attack_animation_started:
		animated_sprite_2d.play("attack_start")
		has_attack_animation_started = true
		direction = enemy.get_direction_to_player(position, player.position)
		exclamation.show_popup(Enums.DIALOGUE_TYPE.EXCLAMATION)
		
		if direction == 1:
			animated_sprite_2d.flip_h = true
		elif direction == -1:
			animated_sprite_2d.flip_h = false
		return
	
	if (is_last_frame("attack_start") 
	or animated_sprite_2d.animation == "attack_spin"):
		spin_to_position(delta)
	
	if (is_last_frame("attack_end")):
		current_move = MOVE_SET.RECOVERING
		has_attack_animation_started = false
		
func spin_to_position(delta: float, position_override = null) -> void:

	# Attack has just begun
	if current_attack_target_x == null:
		# move enemy towards the player
		# direction is set according to player's postition at attack start
		if position_override != null:
			current_attack_target_x = position_override
		else:	
			current_attack_target_x = position.x + SPINNING_DISTANCE * direction
		animated_sprite_2d.play("attack_spin")
		
	
	var reached_target_or_obctacle_left = (
		direction == -1
		and
		(enemy.has_obstacle_to_left() or position.x <= current_attack_target_x))
	var reached_target_or_obstacle_right = (
		direction == 1
		and
		(enemy.has_obstacle_to_right() or position.x >= current_attack_target_x))
	var has_reached_tartget_pos = (reached_target_or_obctacle_left
		or reached_target_or_obstacle_right)
	
	# If at target position or ahead of an obstacle, cease spinning
	if has_reached_tartget_pos:
		if is_last_frame("attack_spin"):
			animated_sprite_2d.play("attack_end")
			current_attack_target_x = null
		return
	
	position.x += SPINNING_SPEED * delta * direction
	
	
func take_damage():
	if !can_take_damage or current_move != MOVE_SET.RECOVERING:
		return
		
	can_take_damage = false
	damage_cooldown_timer.start()
	health -= 1
	if health <= 0:
		current_move = MOVE_SET.DEAD
		exclamation.show_popup(Enums.DIALOGUE_TYPE.DEAD)
	else:
		current_move = MOVE_SET.HIT
	print(name + "; Damage taken from player. Current healt: " + str(health))

func take_damage_heavy(direction_to_push: float, push_force:float):
	if !can_take_damage or current_move != MOVE_SET.RECOVERING:
		return
		
	can_take_damage = false
	damage_cooldown_timer.start()
	
	health -= 2
	if health <= 0:
		current_move = MOVE_SET.DEAD
		exclamation.show_popup(Enums.DIALOGUE_TYPE.DEAD)
	else:
		current_move = MOVE_SET.HIT
		
#	push enemy by a heavy strike
	position.x += direction_to_push * push_force 
	print(name + "; Heavy damage taken from player")

func _on_player_detect_timer_timeout() -> void:
	if has_attack_animation_started:
		has_attack_animation_started = false
		current_attack_target_x = null
	current_mode = MODE.PEACE
	current_move = default_move

func _on_attack_cooldown_timer_timeout() -> void:
	# Damage can be taken only in RECOVERING state, thus, this timer will still be
	# active during the DEAD state. To avoid weird occassions of resurrection, 
	# this check is required 
	if current_move == MOVE_SET.DEAD:
		return
		
	if current_mode == MODE.PEACE:
		current_move = default_move
	else:
		# From idling state it is possible to start attack over
		current_move = MOVE_SET.IDLE 

func _on_damage_cooldown_timer_timeout() -> void:
	can_take_damage = true

func _on_attack_area_body_entered(player: CharacterBody2D) -> void:
	if (!current_mode == MODE.COMBAT or !current_move == MOVE_SET.ATTACKING):
		return
	
	if !is_spinning():
		return
	
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
	

func is_spinning() -> bool:
	return animated_sprite_2d.animation == "attack_spin"
