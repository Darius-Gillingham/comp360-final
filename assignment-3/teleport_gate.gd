extends Node3D
class_name TeleportGate

@export var exit_gate: TeleportGate

@onready var _teleport_area: Area3D = $Area3D

var _just_teleported_debounce: bool = false

func _ready() -> void:
	_teleport_area.body_entered.connect(_teleport_to_other)
	
func _teleport_to_other(body: Node3D) -> void:
	if _just_teleported_debounce or body is not Ball: return
	exit_gate.teleport_to_self(body)
	
func teleport_to_self(body: Ball) -> void:
	_just_teleported_debounce = true
	#body.teleport_target = Vector3(0.47,0.79,0.90) #transform.origin #+ transform.basis.z * 0.5
	#body.teleport_velocity_direction = - _teleport_marker.global_transform.basis.z
	
	body.freeze = true
	body.transform.origin = transform.origin + transform.basis.z * 0.05
	body.linear_velocity = Vector3.ZERO #state.linear_velocity.length() * teleport_velocity_direction
	
	body.freeze = false
	
	await get_tree().create_timer(1).timeout
	
	_just_teleported_debounce = false
