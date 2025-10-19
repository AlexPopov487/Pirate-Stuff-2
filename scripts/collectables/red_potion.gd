extends Collectable
class_name RedPotion

@export var _collect_sfx: AudioStream
@export var _cant_collect_sfx: AudioStream

const POTION_EFFECT:int = 2

func _collect(): 
	#if _character.is_health_full():
		#_sfx.stream = _cant_collect_sfx
		#_sfx.play()
	#else:
		_character.restore_health(POTION_EFFECT)
		_sfx.stream = _collect_sfx
		super._collect()
