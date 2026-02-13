extends Collectable
class_name RedPotion


const POTION_EFFECT:int = 2

func _collect(): 
	_character.restore_health(POTION_EFFECT)
	_sfx.stream = _sfx_resource
	super._collect()
