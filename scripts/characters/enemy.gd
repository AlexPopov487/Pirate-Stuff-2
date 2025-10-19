class_name Enemy extends Character

@onready var _line_of_sight: RayCast2D = $Vision/LineOfSight
@onready var _vision: Area2D = $Vision
@onready var _enemy_behavior: Node = get_node_or_null("EnemyBehavoir")
# Started at the end of attack animation.
# Adds pauses to enemy attack sequences if player continues to stay within enemy's target ares 
@onready var _attack_cooldown: Timer = $Hitbox/AttackCooldown

@onready var _can_see_player: bool
@onready var _player: Player
@onready var _is_player_within_target_area: bool
@onready var _jump_attack_height: float = sqrt(gravity * 2) * -1
var _jump_attack_length: float = 6

func face_other_way():
	super.face_other_way()
	_vision.scale.x = 1 if _flipped_by_default && _is_facing_left else -1

func face_right():
	super.face_right()
	_vision.scale.x = -1 if _flipped_by_default else 1

func face_left():
	super.face_left()
	_vision.scale.x = 1 if _flipped_by_default else -1


func _process(_delta: float) -> void:
	_set_patrolling_behavior()
	

func _set_patrolling_behavior():
	var _could_see_player = _can_see_player
	_can_see_player = _check_if_player_seen()

	if !_could_see_player && _can_see_player:
		_stop_patrolling()
	elif _could_see_player && !_can_see_player:
		_resume_patrolling()
	elif _could_see_player && _can_see_player:
		_chase_player()

func _check_if_player_seen() -> bool:
	if _player == null:
		return false
		
	var line_of_sight_dir: float = 1 if _flipped_by_default && _is_facing_left else -1
	var sight_taget: Vector2 = _player.global_position - global_position
	sight_taget.x *= line_of_sight_dir
	_line_of_sight.target_position = sight_taget
	_line_of_sight.force_raycast_update()
	
	return _line_of_sight.is_colliding() && _line_of_sight.get_collider() == _player

func _stop_patrolling():
	if _enemy_behavior:
		_enemy_behavior.stop_patroling()

func _resume_patrolling():
	if _enemy_behavior:
		_enemy_behavior.resume_patroling()

func _face_player():
	if _player.global_position.x < global_position.x:
		face_left()
	elif _player.global_position.x > global_position.x:
		face_right()

func _chase_player():
	run(sign(_player.global_position.x - global_position.x))

func _try_to_attack():
	if _is_player_within_target_area && !_is_attacking && !_is_ready_to_attack:
		attack()

func _on_vision_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	_player = body

func _on_vision_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		

func _on_target_area_entered(_area: Area2D) -> void:
	# stop attack sequence if player has left the danger area
	if !_attack_cooldown.is_stopped():
		_attack_cooldown.stop()
	_is_player_within_target_area = true
	attack()
	

func _on_target_area_exited(_area: Area2D) -> void:
	# stop attack sequence if player has left the danger area
	if !_attack_cooldown.is_stopped():
		_attack_cooldown.stop()
	_interrupt_running_attack()
	_is_player_within_target_area = false

func _on_attack_cooldown_timeout() -> void:
	_try_to_attack()
	
func _jump_attack():
	velocity.y = _jump_attack_height
	velocity.x = _jump_attack_length * Globals.ppt * (-1 if _is_facing_left else 1)
