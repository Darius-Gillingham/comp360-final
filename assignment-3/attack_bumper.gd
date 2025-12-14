extends Node3D

@export var bounce_strength := 5.0

@onready var star_particle = $StarParticle
@onready var trail_particle = $TrailParticle
@onready var round_bumper = $Attack_Bumper/roundBumper

var _bumper_debounce: bool = false

func _ready():
	$Attack_Bumper/Area3D.body_entered.connect(_on_body_entered)
	

func _on_body_entered(body):
	if body.name == "Ball":
		var ball_pos = body.global_transform.origin
		var bump_pos = global_transform.origin
		
		var push_dir: Vector3 = (ball_pos - bump_pos).normalized()
		body.linear_velocity = Vector3.ZERO
		
		body.apply_impulse(push_dir * bounce_strength)
		
		if _bumper_debounce: return
		_bumper_debounce = true
		
		var particle_seed: int = randi() % 100
		star_particle.seed = particle_seed
		trail_particle.seed = particle_seed
		
		
		var transform_a: Transform3D = star_particle.transform
		var angle: float = transform_a.basis.z.angle_to(-push_dir)
		
		#star_particle.rotate_y(angle)
		#trail_particle.rotate_y(angle)
		
		star_particle.look_at(star_particle.global_transform.origin - push_dir)
		trail_particle.look_at(trail_particle.global_transform.origin - push_dir)

		var tween = round_bumper.create_tween()
		var start_scale = round_bumper.scale
		var target_scale = start_scale + Vector3(0.02,0,  0.02)
		
		star_particle.emitting = true
		trail_particle.emitting = true
		
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUAD) 
		
		tween.tween_property(round_bumper, "scale", target_scale, 0.1) 

		await tween.finished
		
		var undo_tween = round_bumper.create_tween()
		
		undo_tween.tween_property(round_bumper, "scale", start_scale, 0.1)
		
		await undo_tween.finished
		_bumper_debounce = false
		
