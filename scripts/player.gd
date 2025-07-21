
extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -250.0

signal player_move_changed(current_move: String)
enum MOVE_SET { IDLE, JUMPING, FALLING, RUNNING, ATTACKING_LIGHT, ATTACKING_HEAVY, DEAD = 6, HIT }
var current_move: MOVE_SET = MOVE_SET.IDLE:
	set(updated_move):
		#if (current_move != updated_move):
			#print("Player's current move was changed from " + MOVE_SET.find_key(current_move) + " to " + MOVE_SET.find_key(updated_move))
		current_move = updated_move
		player_move_changed.emit(MOVE_SET.find_key(current_move))

# The time in the air during the jump takes longer that the jump animation.
# This variable ensures that the jump animation is played only one during the jump.
var has_jump_animation_played: bool = false
var has_attack_animation_played:bool = false
var has_hit_animation_played:bool = false

signal player_health_changed(current_health: int)
var health = 5:
	set(updated_health):
		health = clamp(updated_health, 0, 5)
		player_health_changed.emit(updated_health)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var heavy_attack_ray: RayCast2D = $AnimatedSprite2D/heavy_attack_ray
@onready var light_attack_ray: RayCast2D = $AnimatedSprite2D/light_attack_ray
@onready var bottom_collision_ray: RayCast2D = $AnimatedSprite2D/bottom_collision_ray


func _ready() -> void:
	player_health_changed.emit(health)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	flip_player_sprite(direction)
	define_current_move_type(direction)
	set_animation_by_current_move()
	has_jump_animation_played = current_move == MOVE_SET.JUMPING


	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func change_move_type(move_type: String):
	# This is done to avoid interrupting attack animation when being hit
	if current_move == MOVE_SET.ATTACKING_LIGHT or current_move == MOVE_SET.ATTACKING_HEAVY:
		return
	current_move = MOVE_SET.get(move_type)

func flip_player_sprite(direction: float):
	if direction < 0:
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false
	
	# Flipping attack rays not from direction but from flip_h to handle standing states
	if animated_sprite.flip_h:
		light_attack_ray.target_position.x = abs(light_attack_ray.target_position.x) * -1
		heavy_attack_ray.target_position.x = abs(heavy_attack_ray.target_position.x) * -1
	else: 
		light_attack_ray.target_position.x = abs(light_attack_ray.target_position.x)
		heavy_attack_ray.target_position.x = abs(heavy_attack_ray.target_position.x)

func define_current_move_type(direction: float):
	if current_move == MOVE_SET.DEAD:
		return
	elif current_move == MOVE_SET.HIT:
		return
	# MOVE_SET will be reset to IDLE after the last attack animation frame is played
	elif Input.is_action_just_pressed("attack_light") or current_move == MOVE_SET.ATTACKING_LIGHT:
		current_move = MOVE_SET.ATTACKING_LIGHT
	elif Input.is_action_just_pressed("attack_heavy") or current_move == MOVE_SET.ATTACKING_HEAVY:
		current_move = MOVE_SET.ATTACKING_HEAVY
	elif (Input.is_action_just_pressed("jump") and is_on_floor()) or (!is_on_floor() and current_move == MOVE_SET.JUMPING):
		current_move = MOVE_SET.JUMPING
	elif !is_on_floor() and current_move != MOVE_SET.JUMPING:
		current_move = MOVE_SET.FALLING
	elif direction == 0:
		current_move = MOVE_SET.IDLE
	else:
		current_move = MOVE_SET.RUNNING
		
func set_animation_by_current_move():
	match current_move:
		MOVE_SET.IDLE:
			animated_sprite.play("idle")
		MOVE_SET.JUMPING:
			if (!has_jump_animation_played):
				animated_sprite.play("jump")
		MOVE_SET.FALLING:
			animated_sprite.play("fall")
		MOVE_SET.RUNNING:
			animated_sprite.play("run")
		MOVE_SET.ATTACKING_LIGHT:
			if !has_attack_animation_played:
				animated_sprite.play("light_attack")
				has_attack_animation_played = true
				return
			
			var light_attack_frame_count = animated_sprite.sprite_frames.get_frame_count("light_attack")
			var light_attack_current_frame = animated_sprite.frame
			var has_last_attack_frame_played = light_attack_current_frame == light_attack_frame_count - 1
			
			# the attacking collision ray is enabled at the specific attack animation frame
			if light_attack_current_frame == 1:
				light_attack_ray.enabled = true
				attack()
			else:
				light_attack_ray.enabled = false
			
			if has_last_attack_frame_played:
				current_move = MOVE_SET.IDLE
				light_attack_ray.enabled = false
				has_attack_animation_played = false
		MOVE_SET.ATTACKING_HEAVY:
			if !has_attack_animation_played:
				animated_sprite.play("heavy_attack")
				has_attack_animation_played = true
				return
				
			var heavy_attack_frame_count = animated_sprite.sprite_frames.get_frame_count("heavy_attack")
			var heavy_attack_current_frame = animated_sprite.frame
			var has_last_attack_frame_played = heavy_attack_current_frame == heavy_attack_frame_count - 1
			
			# the attacking collision ray is enabled at the specific attack animation frame
			if heavy_attack_current_frame == 3 or heavy_attack_current_frame == 4:
				heavy_attack_ray.enabled = true
				attack()
			else:
				heavy_attack_ray.enabled = false
			
			if has_last_attack_frame_played:
				current_move = MOVE_SET.IDLE
				heavy_attack_ray.enabled = false
				has_attack_animation_played = false
		MOVE_SET.DEAD:
			animated_sprite.play("dead")
		MOVE_SET.HIT:
			if !has_hit_animation_played:
				animated_sprite.play("hit")
				has_hit_animation_played = true
				return
				
			var hit_frame_count = animated_sprite.sprite_frames.get_frame_count("hit")
			var hit_current_frame = animated_sprite.frame
			var has_last_hit_frame_played = hit_current_frame == hit_frame_count - 1
			
			if has_last_hit_frame_played:
				#health -= 1
				print("Damage taken! Current health = " + str(health))
				if health <= 0:
					print("Damage taken! Health below zero. Player's dead")
					current_move = MOVE_SET.DEAD
				else:
					current_move = MOVE_SET.IDLE
				has_hit_animation_played = false
			

func attack():
	if heavy_attack_ray.is_colliding():
		var collider = heavy_attack_ray.get_collider()
		if collider.is_in_group("enemies"):
			var direction_to_push = -1 if animated_sprite.flip_h else 1
			collider.get_parent().get_parent().take_damage_heavy(direction_to_push, 10)
	elif light_attack_ray.is_colliding():
		var collider = light_attack_ray.get_collider()
		if collider.is_in_group("enemies"):
			collider.get_parent().get_parent().take_damage()

func get_direction() -> int:
	return -1 if animated_sprite.flip_h else 1 
