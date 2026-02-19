extends Collectable
class_name BluePotion


const POTION_EFFECT:int = 4

func _collect(): 
	_character.restore_stamina_by_potion(POTION_EFFECT)
	_sfx.stream = _sfx_resource
	super._collect()
