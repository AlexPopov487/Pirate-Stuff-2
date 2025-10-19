extends Collectable


func _collect(): 
	_character.equip_sword()
	super._collect()
