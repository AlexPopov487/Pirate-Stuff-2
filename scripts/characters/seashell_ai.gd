extends Node

enum ACTIVITIES {IDLE, OPEN}

var _activity_queue: Array[Dictionary] = (
	[
	{ACTIVITIES.IDLE: [{"from": 1, "to": 4}]},
	{ACTIVITIES.OPEN: [{"from": 1, "to": 4}]},
	]
)

var _current_activity: ACTIVITIES
var _current_activity_index: int
var _is_doing_routine: bool

@onready var _activity_timer: Timer = $ActivityTimer

func get_current_activity() -> ACTIVITIES:
	return _current_activity
	
func can_do_routine() -> bool:
	return _is_doing_routine

func stop_routines():
	#print(get_parent().name + " stopped all routines")

	_is_doing_routine = false
	_current_activity_index = -1 
	_activity_timer.stop()

func start_routines():
	#print(get_parent().name + " resumed routines")
	_is_doing_routine = true
	_current_activity_index = 0
	_set_activity_by_current_index()

func _ready() -> void:
	_is_doing_routine = true
	_current_activity_index = 0
	_set_activity_by_current_index()


func _set_next_activity():
	_current_activity_index = (_current_activity_index + 1 
								if _current_activity_index + 1 < _activity_queue.size() 
								else 0)

	_set_activity_by_current_index()
	
func _set_activity_by_current_index():
	var activity_data: Dictionary = _activity_queue[_current_activity_index]
	var duration_range: Dictionary = activity_data.values()[0][0]

	var activity_duration: float = randf_range(duration_range["from"], duration_range["to"])

	_current_activity = activity_data.keys()[0]
	_activity_timer.start(activity_duration)
	#print(get_parent().name + " routine is set to " + ACTIVITIES.find_key(_current_activity))


func _on_activity_timer_timeout() -> void:
	_set_next_activity()
