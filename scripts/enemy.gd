extends Node2D


#enemy default behavior
# - health_amount
# - damage_amount
# - state {IDLE, MOVING, ATTACKING, DEAD}
# - is_moving
@export var PLAYER_ALERT_DISTANCE = 100 
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right_bottom: RayCast2D = $RayCastRightBottom
@onready var ray_cast_left_bottom: RayCast2D = $RayCastLeftBottom
@onready var eye_sight_ray: RayCast2D = $EyeSightRay
@onready var collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D



func is_player_seen(tile_map: TileMap, enemy_position: Vector2, player: CharacterBody2D) -> bool:
	var distance_to_player = enemy_position.distance_to(player.position)

	if distance_to_player > PLAYER_ALERT_DISTANCE:
		toggle_eyesight_ray(false)
		return false
		
	toggle_eyesight_ray(true)

	var enemy_bottom := ray_cast_left_bottom.get_collision_point()
	var player_bottom = player.bottom_collision_ray.get_collision_point()
		
	# Comparing player's and enemie's y with a small tolerance:
	var is_on_same_ground_with_player = abs(enemy_bottom.y - player_bottom.y) < 5
	
	return (is_on_same_ground_with_player
	and is_player_within_eyesight(collision_shape_2d, player, enemy_bottom) 
	and not has_gap_between(tile_map, enemy_bottom, player_bottom))

func is_player_within_eyesight(enemy_collision: CollisionShape2D, 
								player: CharacterBody2D,
								enemy_bottom: Vector2) -> bool:
	var enemy_widht = collision_shape_2d.shape.get_rect().size.x
	var enemy_height = collision_shape_2d.shape.get_rect().size.y
	var ray_dir = get_direction_to_player(enemy_bottom, player.position)
	
	# By default the eye_sight_ray is started from the left side of the enemy. 
	# To track enemy's collisions with player, I start decetion ray from the inside of the enemy.
	# Thus, yf the player is to the right of the enemy, the ray should be casted from the enemy's left and vice versa.
	var eye_sight_start := to_local(enemy_bottom)
	if (ray_dir == -1):
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

func has_gap_between(tile_map: TileMap, enemy_bottom: Vector2, player_bottom: Vector2) -> bool:
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
	
func get_direction_to_player(enemy_position: Vector2, player_position: Vector2):
	return sign(player_position.x - enemy_position.x)

func has_obstacle_to_right() -> bool:
	return ray_cast_right.is_colliding() or !ray_cast_right_bottom.is_colliding()

func has_obstacle_to_left() -> bool:
	return ray_cast_left.is_colliding() or !ray_cast_left_bottom.is_colliding()
