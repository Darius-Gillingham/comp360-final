extends CharacterBody3D
var controls_enabled = true
var camera_enabled = true

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity:=.25

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 50.0
@export var jump_impulse := 12.0
@export var air_jump_count := 1
@export var jump_timer := .05
@export var rotation_speed := 4.0
var air_jumps = air_jump_count


@export_group("dashing")
@export var dash_speed := 50
@export var dash_duration := .1
@export var dash_count := 1
var dashes = dash_count

var is_dashing := false
var can_dash := true
var dash_timer = 0.0

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0
var current_anim := ""

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %robot

func _ready() -> void:
	add_to_group("player")
	
func _process(delta: float) -> void:
	if camera_enabled:
		$CameraPivot/SpringArm3D/Camera3D.current = true
		$robot.visible = true
	else:
		$CameraPivot/SpringArm3D/Camera3D.current = false
		$robot.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event.is_action_pressed("sprint"):
		move_speed = 20
	if event.is_action_released("sprint"):
		move_speed = 8

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func play_animation(name) -> void:
	if current_anim  != name:
		current_anim = name
		$robot/AnimationPlayer.play(name)
		
func _physics_process(delta: float) -> void:
	
	if  !controls_enabled:
		return

	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI/6.0, -PI/15)
	
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("move_left","move_right","move_up","move_down")
	var forward := _camera_pivot.global_basis.z
	var right := _camera_pivot.global_basis.x
	
	if !is_on_floor() and Input.is_action_just_pressed("sprint") and dashes > 0:
		is_dashing = true
		dashes -= 1
		dash_timer = dash_duration
		var dash_dir := (forward *raw_input.y + right *raw_input.x).normalized()
		dash_dir.y = 0.0
		
		if dash_dir == Vector3.ZERO:
			dash_dir = -forward
		
		velocity = dash_dir * dash_speed
		play_animation("RobotArmature|Robot_Punch")
		
	
	var move_direction := forward *raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration *delta)
	velocity.y = y_velocity + _gravity * delta
	
	if is_on_floor() or is_on_wall():
		air_jumps = air_jump_count
		dashes = dash_count
	
	var is_starting_jump := Input.is_action_just_pressed("jump")
	if is_starting_jump and is_on_floor():
		velocity.y += jump_impulse
		play_animation("RobotArmature|Robot_WalkJump")
	elif is_starting_jump and air_jumps > 0:
		velocity.y = velocity.y/5.0
		velocity.y += jump_impulse
		air_jumps -= 1
		play_animation("RobotArmature|Robot_WalkJump")
	if is_on_wall():
		if velocity.y < 0.0:
			velocity.y = 0.0
	if is_on_wall() and is_starting_jump:
		velocity.y += jump_impulse
	
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer >= 0:
			is_dashing = false
	else:
		velocity.y + _gravity * delta
	
	move_and_slide()
	
	if move_direction.length() > .1:
		var target_rotation := atan2(-move_direction.x, -move_direction.z)
		$robot.rotation.y = lerp_angle($robot.rotation.y,target_rotation, delta* 8)
	
	var ground_speed := velocity.length()
	if 8.0 >= ground_speed and ground_speed > 0.0 and is_on_floor():	
		play_animation("RobotArmature|Robot_Walking")
		
	if ground_speed > 8.0 and is_on_floor():	
		play_animation("RobotArmature|Robot_Running")
		
	if ground_speed == 0.0 and is_on_floor():
		play_animation("RobotArmature|Robot_Idle")
