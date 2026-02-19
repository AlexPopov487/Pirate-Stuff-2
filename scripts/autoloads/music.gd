extends AudioStreamPlayer

signal volume_fade_finished()

# Default desired volume in linear scaling 
var desired_volume: float = 1
var _current_volume_linear: float = 0
var _fade_in_progress: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	volume_db = linear_to_db(_current_volume_linear)


func _fade(target_volume_linear: float, duration: float = 1) -> void:
	_fade_in_progress = true
	if duration <= 0:
		_current_volume_linear = target_volume_linear
		volume_db = linear_to_db(_current_volume_linear)
		volume_fade_finished.emit()
		_fade_in_progress = false
		return
		
	while target_volume_linear != _current_volume_linear:
		_current_volume_linear = move_toward(_current_volume_linear, 
											target_volume_linear, 
											get_process_delta_time() / duration)
		volume_db = linear_to_db(_current_volume_linear)
		await get_tree().process_frame
	volume_fade_finished.emit()
	_fade_in_progress = false
	
func wait_running_fade_completion() -> void:
	if _fade_in_progress:
		await volume_fade_finished
	
func start_track(track: AudioStream, fade_time: float = 1): 
	if playing:
		if track == null || stream == track:
			return 
		else:
			await wait_running_fade_completion()
			_fade(0, fade_time)
			await volume_fade_finished
	stream = track
	play()
	_fade(desired_volume, fade_time)
	
func stop_track(fade_time: float = 1):
	if !playing:
		return
			
	await wait_running_fade_completion()
		
	_fade(0, fade_time)
	await volume_fade_finished
	stop()
	
