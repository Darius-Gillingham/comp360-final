# File: scripts/speed_booster.gd
# Commit: Add Area3D-based speed booster that only affects the Ball, mirroring gravity well structure.

extends Area3D

@export var boost_force: float = 1.0        # Strength of the boost
@export var max_speed: float = 40.0          # Hard speed cap
@export var use_area_forward: bool = true    # Boost along Area3D -Z
@export var vertical_lock: bool = true        # Prevent vertical impulse

var bodies: Array[RigidBody3D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is RigidBody3D and body.name == "Ball":
		bodies.append(body)


func _on_body_exited(body: Node) -> void:
	if body is RigidBody3D and body.name == "Ball":
		bodies.erase(body)


func _physics_process(delta: float) -> void:
	if bodies.is_empty():
		return

	for body in bodies:
		if not is_instance_valid(body):
			continue

		var direction: Vector3

		if use_area_forward:
			# Area3D forward direction (-Z in Godot)
			direction = -global_transform.basis.z
		else:
			# Boost in direction the ball is already moving
			if body.linear_velocity.length() < 0.01:
				continue
			direction = body.linear_velocity.normalized()

		if vertical_lock:
			direction.y = 0.0
			direction = direction.normalized()

		# Speed cap
		if body.linear_velocity.length() >= max_speed:
			continue

		var force: Vector3 = direction * boost_force
		body.apply_central_force(force)
