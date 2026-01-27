extends Collectable
class_name BluePotion

@export var _cant_collect_sfx: AudioStream

const POTION_EFFECT:int = 4

func _collect(): 
	#if _character.is_health_full():
		#_sfx.stream = _cant_collect_sfx
		#_sfx.play()
	#else:
		_character.restore_stamina_by_potion(POTION_EFFECT)
		_sfx.stream = _sfx_resource
		super._collect()
