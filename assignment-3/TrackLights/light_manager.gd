extends Node3D
class_name LightManager

var lights_data: LightsData = preload("res://TrackLights/lights_data.gd").new()
@onready var timer: Timer = $Timer
var last_light_i: int = 0
var active_lights: Array[TrackLight] = []

var light_state: LightsData.LightState = LightsData.LightState.FAIL:
	set(value):
		light_state = value
		last_light_i = 0

func _ready() -> void:
	timer.timeout.connect(_tick_lights)
	
func _tick_lights() -> void:
	var next_light_action = lights_data.light_actions[light_state][last_light_i]
	
	for active_light in active_lights.duplicate():
		#if (next_light_action.has(int(active_light.name))):
			#continue
		active_light.turn_off()
		active_lights.erase(active_light)
	
	if light_state == LightsData.LightState.OFF or not next_light_action:
		last_light_i = 0
		return
	
	#if next_light_action is int:
		#var track_light: TrackLight = get_node_or_null(str(next_light_action))
		#if active_lights.has(track_light): return
		#track_light.turn_on()
		#active_lights.append(track_light)  
		#return
	
	for light in next_light_action:
		#print(get_children())
		var track_light: TrackLight = get_node_or_null(str(light))
		#if active_lights.has(track_light): continue
		track_light.turn_on()
		active_lights.append(track_light)
		
	last_light_i = (last_light_i + 1) % lights_data.light_actions[light_state].size()
