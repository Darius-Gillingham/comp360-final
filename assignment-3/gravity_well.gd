extends Area3D

@export var G: float = 20.0               
@export var min_radius: float = 0.6       
@export var max_force: float = 120.0      
@export var vertical_lock: bool = true   

var bodies: Array[RigidBody3D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is RigidBody3D:
		bodies.append(body)


func _on_body_exited(body: Node) -> void:
	if body is RigidBody3D:
		bodies.erase(body)


func _physics_process(delta: float) -> void:
	if bodies.is_empty():
		return

	for body in bodies:
		if not is_instance_valid(body):
			continue

		var to_center: Vector3 = global_position - body.global_position

		if vertical_lock:
			to_center.y = 0.0  

		var distance: float = max(to_center.length(), min_radius)
		var direction: Vector3 = to_center.normalized()

		var force_strength: float = G / (distance * distance)

		force_strength = min(force_strength, max_force)

		var force: Vector3 = direction * force_strength
		body.apply_central_force(force)


		#if force.length() > 0.01:
			#print("Gravity well applying force:", force, "to:", body.name)
