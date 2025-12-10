extends Node3D

@export var bounce_strength := 5.0

func _ready():
	$triangle_bumper/Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Ball":
		var direction : Vector3 = transform.basis.x.normalized()
		print("I should be bouncing...")
		body.apply_impulse(direction * bounce_strength)
