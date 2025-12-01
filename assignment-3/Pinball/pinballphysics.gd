extends Node3D
var fire_in_the_hole = false

@onready var _ball: RigidBody3D = $Ball


func _ready():
	$MachineFace/FiringHole.body_entered.connect(_on_body_entered)
	$MachineFace/FiringHole.body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.name == "Ball":
		print("fire in the hole!!!!")
		fire_in_the_hole = true

func _on_body_exited(body):
	if body.name == "Ball":
		fire_in_the_hole = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if fire_in_the_hole:
			print("FIRING")
		else:  
			print("NOPE")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and fire_in_the_hole == true:
		var direction := -transform.basis.z.normalized()
		var strength := 10
		_ball.apply_impulse(direction * strength)
		pass
