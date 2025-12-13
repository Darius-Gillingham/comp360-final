extends CSGBox3D
var player_in_range := false
var is_viewing := false
	
func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if !is_viewing:
			try_interact()
			is_viewing = true
		elif is_viewing:
			_exit_menu()
			is_viewing = false
	

		
func _exit_menu():
	$BallCam.current = false
	var player = get_tree().get_first_node_in_group("player")
	player.controls_enabled = true
	player.camera_enabled = true
	

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		print("Player is in range")

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		print("Player is not in range")
		
func try_interact():
	if player_in_range:
		activate_pinball()
	elif not player_in_range:
		pass
		
func activate_pinball():
	var world_cam = get_viewport().get_camera_3d()
	world_cam.current = false
	$BallCam.current = true
	
	var player = get_tree().get_first_node_in_group("player")
	player.controls_enabled = false
	player.camera_enabled = false
