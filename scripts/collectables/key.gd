extends Collectable


func _collect(): 
	$/root/game.collect_key()
	
	# Needed to disable physics processed when a physics-affected coin is being collected,
	# to prevent the "collect" animation follow the player
	# Physics-affected coins will come in handy when they are thrown out of a chest
	call_deferred("set_freeze_enabled", true)
	call_deferred("set_freeze_mode", RigidBody2D.FreezeMode.FREEZE_MODE_STATIC)
	
	super._collect()
