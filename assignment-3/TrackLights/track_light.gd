extends Node3D

class_name TrackLight
@export var on_texture: Material
@export var off_texture: Material

@onready var emission = $Circle_001

func _ready() -> void:
	emission.set_surface_override_material(0, off_texture)

func turn_on() -> void:
	emission.set_surface_override_material(0, on_texture)
	
func turn_off() -> void:
	emission.set_surface_override_material(0, off_texture)
