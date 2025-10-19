extends Node
class_name Vfx

const EVENING_OVERLAY_COLOR := Color(0,0,0,0.3)
const NIGHT_OVERLAY_COLOR := Color(0,0,0,50)

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func set_vfx(weather: Globals.WEATHER):
	match weather:
		Globals.WEATHER.CLEAR:
			gpu_particles_2d.visible = false
		Globals.WEATHER.RAIN:
			gpu_particles_2d.visible = true
