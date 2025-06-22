extends Node2D

enum MOVE_SET { IDLE, RUNNING, ATTACKING, DEAD = 6, HIT, ALERTED, RECOVERING }
@export var initial_move: MOVE_SET = MOVE_SET.IDLE
@export var should_lock_initial_move = false

const SPEED = 45
const MAX_HEALTH = 5
const PLAYER_ALERT_DISTANCE = 150
# 1 = moving right. -1 = moving left
var direction = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right_bottom: RayCast2D = $RayCastRightBottom
@onready var ray_cast_left_bottom: RayCast2D = $RayCastLeftBottom
@export var player: CharacterBody2D
@onready var damage_cooldown_timer: Timer = $DamageCooldownTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var eye_sight_ray: RayCast2D = $EyeSightRay
@onready var tile_map: TileMap = %TileMap
@onready var attack_ray_left: RayCast2D = $AttackRayLeft
@onready var attack_ray_right: RayCast2D = $AttackRayRight
@onready var exclamation: Marker2D = $Exclamation


var has_attack_animation_played = false
var can_attack = true
var can_take_damage = true
var current_move = MOVE_SET.RUNNING:
	set(updated_state):
		print(name + " is " + MOVE_SET.find_key(updated_state))
		current_move = updated_state
var health = MAX_HEALTH:
	set(updated_health):
		health = clamp(updated_health, 0, MAX_HEALTH)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_default_move()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_seen = is_player_seen()
	if (player_seen 
	and current_move != MOVE_SET.ATTACKING
	and current_move != MOVE_SET.HIT
	and current_move != MOVE_SET.DEAD
	and current_move != MOVE_SET.RECOVERING
	and current_move != MOVE_SET.ALERTED):
		current_move = MOVE_SET.ALERTED
	
	if not player_seen and current_move == MOVE_SET.ALERTED:
		restore_move_type_on_animation_end()
	
	if (!player_seen and (current_move == MOVE_SET.ALERTED
	or current_move == MOVE_SET.ATTACKING
	or current_move == MOVE_SET.RECOVERING)):
		exclamation.show_popup(Enums.DIALOGUE_TYPE.INTERROGATION)
		restore_move_type_on_animation_end()

	set_animation_by_current_move(delta)

func flip_enemy_sprite(player_direction_optional = null):
	if has_obstacle_to_right():
		direction = -1
		animated_sprite.flip_h = false
	elif has_obstacle_to_left():
		direction = 1
		animated_sprite.flip_h = true

func set_animation_by_current_move(delta:float):
	match current_move:
		MOVE_SET.IDLE:
			animated_sprite.play("idle")
		MOVE_SET.RECOVERING:
			animated_sprite.play("idle")
			if can_attack:
				current_move = MOVE_SET.IDLE
			
		MOVE_SET.RUNNING:
			animated_sprite.play("running")
			position.x += SPEED * delta * direction
			flip_enemy_sprite()
		MOVE_SET.HIT:
			animated_sprite.play("hit")
			restore_move_type_on_animation_end()
		MOVE_SET.DEAD:
			animated_sprite.play("dead")
			restore_move_type_on_animation_end()
		MOVE_SET.ATTACKING:
			if !has_attack_animation_played:
				has_attack_animation_played = true
				animated_sprite.play("attack")
				return
			
			var attack_frame_count = animated_sprite.sprite_frames.get_frame_count("attack")
			var current_frame = animated_sprite.frame
			var has_last_frame_played = current_frame == attack_frame_count -1
			
			# the attack is taking effect at the specific attack animation frame
			if current_frame == 0:
				attack()
			if has_last_frame_played:
				has_attack_animation_played = false
				current_move = MOVE_SET.RECOVERING
			
		MOVE_SET.ALERTED:
			var is_player_near = attack_ray_right.is_colliding() or attack_ray_left.is_colliding()
			if (is_player_near):
				if can_attack:
					current_move = MOVE_SET.ATTACKING
				else: 
					current_move = MOVE_SET.RECOVERING
				return
			
			var player_direction = get_direction_to_player(player.position)

			if ((has_obstacle_to_left() and player_direction == -1) 
			or (has_obstacle_to_right() and player_direction == 1)):
				exclamation.show_popup(Enums.DIALOGUE_TYPE.INTERROGATION)
				return
				
			exclamation.show_popup(Enums.DIALOGUE_TYPE.EXCLAMATION)
			animated_sprite.play("running")
			position.x += SPEED * delta * player_direction
			direction = player_direction
			animated_sprite.flip_h = direction == 1
			

func _on_attack_area_body_entered(player: CharacterBody2D) -> void:
	if current_move == MOVE_SET.HIT or current_move == MOVE_SET.DEAD:
		return
		
	print("Crabby attacks")
	# TODO refactor that. I do not know how external fields are accessed 
	if player.current_move != 6: #DEAD 
		player.change_move_type("HIT")
	pass

func take_damage():
	if !can_take_damage:
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
	if !can_take_damage:
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

func _on_damage_timer_timeout() -> void:
	can_take_damage = true

func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true

func set_default_move():
	if should_lock_initial_move:
		current_move = initial_move
	else:
		current_move = MOVE_SET.RUNNING

func restore_move_type_on_animation_end():
	var current_animation = animated_sprite.animation	
	var animaton_frame_count = animated_sprite.sprite_frames.get_frame_count(current_animation)
	var curr_animation_frame = animated_sprite.frame
	var has_last_frame_played = curr_animation_frame == animaton_frame_count - 1
			
	if has_last_frame_played:
		if current_animation == "dead":
			queue_free()
		else:
			set_default_move()

func attack() :
	if current_move == MOVE_SET.HIT or current_move == MOVE_SET.DEAD:
		return
		
	if !can_attack:
		return
		
	print("Crabby attacks")
	can_attack = false
	attack_cooldown_timer.start()
	# TODO refactor that. I do not know how external fields are accessed 
	if player.current_move != 6: #DEAD 
		player.change_move_type("HIT")

func is_player_seen() -> bool:
	var distance_to_player = position.distance_to(player.position)

	if distance_to_player > PLAYER_ALERT_DISTANCE:
		toggle_eyesight_ray(false)
		return false
		
	toggle_eyesight_ray(true)

	var enemy_bottom := ray_cast_left_bottom.get_collision_point()
	var player_bottom = player.bottom_collision_ray.get_collision_point()
		
	# Comparing player's and enemie's y with a small tolerance:
	var is_on_same_ground_with_player = abs(enemy_bottom.y - player_bottom.y) < 5
	
	return (is_on_same_ground_with_player
	and is_player_within_eyesight(collision_shape_2d, player.position, enemy_bottom) 
	and not has_gap_between(enemy_bottom, player_bottom))

func is_player_within_eyesight(enemy_collision: CollisionShape2D, 
								player_position: Vector2,
								enemy_bottom: Vector2) -> bool:



	var enemy_widht = collision_shape_2d.shape.get_rect().size.x
	var enemy_height = collision_shape_2d.shape.get_rect().size.y
	var ray_dir = get_direction_to_player(player_position)
	
	# By default the eye_sight_ray is started from the left side of the enemy. 
	# If the player is to the right of the enemy, the ray should be casted from the enemy's right.
	var eye_sight_start := to_local(enemy_bottom)
	if (ray_dir == 1):
		eye_sight_start.x += enemy_widht
	
	# Start eye_sight_ray from enemy's horizontal center
	eye_sight_start.y = eye_sight_start.y - (enemy_height / 2)
	
	# Set hardcoded -4 for y axis because otherwise the ray is slanted to the bottom
	var eye_sight_target = Vector2(
		eye_sight_start.x + (ray_dir * PLAYER_ALERT_DISTANCE),
		eye_sight_ray.position.y - 4)
	
	eye_sight_ray.position = eye_sight_start
	eye_sight_ray.target_position = eye_sight_target
	eye_sight_ray.force_raycast_update()
	
	return (eye_sight_ray.is_colliding() and eye_sight_ray.get_collider() == player)

func has_gap_between(enemy_bottom: Vector2, player_bottom: Vector2) -> bool:
	var start = tile_map.local_to_map(enemy_bottom)
	var end = tile_map.local_to_map(player_bottom)

	for x in range(min(start.x, end.x), max(start.x, end.x) + 1):
		var cell_pos = Vector2i(x, start.y)
		if tile_map.get_cell_tile_data(0, cell_pos) == null:
			return true
	return false

func toggle_eyesight_ray(state: bool) -> void:
	eye_sight_ray.visible = state
	eye_sight_ray.enabled = state
	
func get_direction_to_player(player_position: Vector2):
	return sign(player_position.x - position.x)

func has_obstacle_to_right() -> bool:
	return ray_cast_right.is_colliding() or !ray_cast_right_bottom.is_colliding()

func has_obstacle_to_left() -> bool:
	return ray_cast_left.is_colliding() or !ray_cast_left_bottom.is_colliding()
