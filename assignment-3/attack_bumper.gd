extends Node3D

@export var bounce_strength := 5.0

func _ready():
	$Attack_Bumper/Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Ball":
		var ball_pos = body.global_transform.origin
		var bump_pos = global_transform.origin
		
		var push_dir = (ball_pos - bump_pos).normalized()
		body.linear_velocity = Vector3.ZERO
		
		body.apply_impulse(push_dir * bounce_strength)
