extends Node3D
var fire_in_the_hole = false
var can_bump = false

@onready var _ball: RigidBody3D = $Ball
@onready var _bumper1: Area3D = $Bumper1/LeftBumpArea

func _ready():
	$MachineFace/FiringHole.body_entered.connect(_on_body_entered)
	$MachineFace/FiringHole.body_exited.connect(_on_body_exited)
	$Bumper1/LeftBumpArea.body_entered.connect(_on_bumper_entered)
	$Bumper1/LeftBumpArea.body_exited.connect(_on_bumper_exited)
	$Bumper2/RightBumpArea.body_entered.connect(_on_bumper_entered)
	$Bumper2/RightBumpArea.body_exited.connect(_on_bumper_exited)


func _on_body_entered(body):
	if body.name == "Ball":
		print("fire in the hole!!!!")
		fire_in_the_hole = true

func _on_body_exited(body):
	if body.name == "Ball":
		fire_in_the_hole = false

func _on_bumper_entered(body):
	if body.name == "Ball":
		print("LEFT")
		can_bump = true
		
func _on_bumper_exited(body):
	if body.name == "Ball":
		can_bump = false
		


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if fire_in_the_hole:
			print("FIRING")
		else:  
			pass
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and fire_in_the_hole:
		var direction := -transform.basis.z.normalized()
		var strength := 10
		_ball.apply_impulse(direction * strength)

	if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")) and can_bump:
		print("BUMPIN")
		var direction := -transform.basis.z.normalized()
		var strength := 5
		_ball.apply_impulse(direction * strength)
		pass
		
