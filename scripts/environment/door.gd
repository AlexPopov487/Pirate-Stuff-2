extends StaticBody2D

const OPENING_ANIMATION: String = "opening"
const CLOSING_ANIMATION: String = "closing"


@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _timer: Timer = $Timer

enum STATE {OPENED, CLOSED}
var _current_state: STATE = STATE.CLOSED

func _ready() -> void:
	_change_state()

func _change_state():
	if _current_state == STATE.OPENED:
		_play_animation(CLOSING_ANIMATION, STATE.CLOSED)
	else:
		_play_animation(OPENING_ANIMATION, STATE.OPENED)

func _play_animation(animation_name: String, new_state: STATE):
	_animated_sprite_2d.play(animation_name)
	await _animated_sprite_2d.animation_finished
	_current_state = new_state
	_timer.start()


func _on_timer_timeout() -> void:
	_change_state()
