extends RigidBody3D

@export var rest_angle: float = 0.0          # degrees
@export var active_angle: float = 35.0       # degrees (how far it rotates)
@export var torque_strength: float = 80.0    # power of rotation torque
@export var return_strength: float = 50.0    # how strongly it comes back

var target_angle: float = 0.0

func _ready():
	target_angle = rest_angle


func _process(_delta):
	# Input: choose the target angle
	if Input.is_action_just_pressed("ui_left"):
		target_angle = active_angle
	elif Input.is_action_just_pressed("ui_right"):
		target_angle = -active_angle
	elif Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		target_angle = rest_angle


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Get current rotation around Y (in degrees)
	var current_angle = rotation_degrees.y

	# Compute rotation error
	var error = target_angle - current_angle

	# Apply torque proportional to the error
	var torque = Vector3(0, error * torque_strength, 0)

	# Apply smoother return force
	torque.y -= angular_velocity.y * return_strength

	state.apply_torque_impulse(torque * state.step)
