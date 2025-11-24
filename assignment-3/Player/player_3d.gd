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
var _gravity := -30.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D

func _ready() -> void:
	add_to_group("player")
	
func _process(delta: float) -> void:
	if camera_enabled:
		$CameraPivot/SpringArm3D/Camera3D.current = true
		$MeshInstance3D.visible = true
	else:
		$CameraPivot/SpringArm3D/Camera3D.current = false
		$MeshInstance3D.visible = false

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
		
func _physics_process(delta: float) -> void:
	
	if  !controls_enabled:
		return

	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI/6.0, -PI/15)
	
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("move_left","move_right","move_up","move_down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	if !is_on_floor() and Input.is_action_just_pressed("sprint") and dashes > 0:
		is_dashing = true
		dashes -= 1
		dash_timer = dash_duration
		var dash_dir := (forward *raw_input.y + right *raw_input.x).normalized()
		dash_dir.y = 0.0
		
		if dash_dir == Vector3.ZERO:
			dash_dir = -forward
		
		velocity = dash_dir * dash_speed
		
	
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
	elif is_starting_jump and air_jumps > 0:
		velocity.y = velocity.y/5.0
		velocity.y += jump_impulse
		air_jumps -= 1
	
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
		
	
