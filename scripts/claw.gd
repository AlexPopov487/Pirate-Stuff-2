extends Node2D

@export var default_move: MOVE_SET
@export var player: CharacterBody2D
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
enum MOVE_SET { IDLE, RUNNING, ATTACKING, DEAD = 6, HIT, ALERTED, RECOVERING}

const MAX_HEALTH = 4
const SPEED: int =  25
const CHASE_SPEED: int = 55
const BITE_SPEED = 3 * CHASE_SPEED

var has_attack_animation_started = false
var current_attack_direction = null
var can_take_damage = true
var direction = 1
var current_speed: int
var health = MAX_HEALTH
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_mode = MODE.PEACE
	current_move = default_move
	current_speed = SPEED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#fall_down(delta)
	flip_enemy_sprite()
	change_mode()
	set_current_move_by_mode(delta)


func flip_enemy_sprite():
	# current_attack_direction, if set, should not be overriden
	if current_attack_direction != null:
		direction = current_attack_direction
		return
	
	if enemy.has_obstacle_to_right():
		direction = -1
		animated_sprite_2d.flip_h = false
	elif enemy.has_obstacle_to_left():
		direction = 1
		animated_sprite_2d.flip_h = true
		
	elif animated_sprite_2d.flip_h == true and direction == -1:
		animated_sprite_2d.flip_h = false
	elif animated_sprite_2d.flip_h == false and direction == 1:
		animated_sprite_2d.flip_h = true
		
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
				MOVE_SET.RUNNING:
					animated_sprite_2d.play("running")
					position.x += current_speed * delta * direction
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

func _on_player_detect_timer_timeout() -> void:
	current_mode = MODE.PEACE
	current_move = default_move
	current_speed = SPEED
	if has_attack_animation_started:
		has_attack_animation_started = false
		current_attack_direction = null
	

func is_during_attack() -> bool:
	return (current_move == MOVE_SET.ATTACKING
		or current_move == MOVE_SET.RECOVERING
		or current_move == MOVE_SET.ALERTED
		or current_move == MOVE_SET.HIT
		or current_move == MOVE_SET.DEAD)

func start_attack(delta: float):
#	TODO track collision with player using CollisionShape2d?
	var is_player_near = enemy.is_player_close()
	
	if is_player_near:
		current_move = MOVE_SET.ATTACKING
	else:
		current_move = MOVE_SET.ALERTED
		
func handle_alert_animation(delta: float):
	var player_direction = enemy.get_direction_to_player(position, player.position)
	exclamation.show_popup(Enums.DIALOGUE_TYPE.EXCLAMATION)
	animated_sprite_2d.play("running")
	
	
	if current_speed == SPEED:
		current_speed = CHASE_SPEED
	
	position.x += current_speed * delta * player_direction
	direction = player_direction
	
	
	if enemy.is_player_close():
		current_move = MOVE_SET.ATTACKING
	
	
func handle_attack_animation(delta: float):
	if not has_attack_animation_started:
		animated_sprite_2d.play("attack_prepare")
		# lock enemy's direction during the attack animation
		current_attack_direction = direction
		has_attack_animation_started = true
	
	if is_last_frame("attack_prepare"):
		animated_sprite_2d.play("attack_bite")
		
	if animated_sprite_2d.animation == "attack_bite":
		position.x += BITE_SPEED * delta * current_attack_direction
	
	if is_last_frame("attack_bite"):
		current_move = MOVE_SET.RECOVERING
		has_attack_animation_started = false
		
func is_last_frame(animation_name: String) ->bool:
	if animated_sprite_2d.animation != animation_name:
		return false
	
	var current_attack_start_frame := animated_sprite_2d.frame
	var attack_start_frame_count = animated_sprite_2d.sprite_frames.get_frame_count(animation_name)
	return current_attack_start_frame == attack_start_frame_count - 1

func take_damage():
	if !can_take_damage or current_move != MOVE_SET.RECOVERING:
		return
	
	if !is_player_behind():
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
	
	if !is_player_behind():
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
	
	
func _on_attack_cooldown_timer_timeout() -> void:
	current_attack_direction = null
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


func _on_attack_area_body_entered(player: CharacterBody2D) -> void:
	if (!current_mode == MODE.COMBAT or !current_move == MOVE_SET.ATTACKING):
		return
	
	if !is_bitting():
		return
	
	print(name + " hits!")
	# TODO refactor that. I do not know how external fields are accessed 
	if player.current_move != 6: #DEAD 
		player.change_move_type("HIT")
		
		
func is_bitting() -> bool:
	return animated_sprite_2d.animation == "attack_bite"


func _on_damage_cooldown_timer_timeout() -> void:
	can_take_damage = true

func is_player_behind() -> bool:
	var dir_to_player = enemy.get_direction_to_player(position, player.position)
	
	var is_player_to_the_left = (direction == 1 
								and dir_to_player == -1
								and player.get_direction() == 1) 
	var is_player_to_the_right = (direction == -1 
								and dir_to_player == 1
								and player.get_direction() == -1)
								
	return is_player_to_the_left or is_player_to_the_right


func fall_down(delta: float):
	if enemy.is_on_floor():
		return
	
	position.y += 250 * delta
	print(position.y)
