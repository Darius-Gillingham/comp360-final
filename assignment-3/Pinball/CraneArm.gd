extends Node3D

# ---- CONFIG ----
@export var idle_oscillation_speed: float = 1.2
@export var idle_oscillation_amplitude: float = 0.4
@export var hold_time_min: float = 2.0
@export var hold_time_max: float = 4.0
@export var pickup_offset: Vector3 = Vector3(0, -0.5, 0)  # Offset from pickup point
@export var pickup_speed: float = 5.0  # How fast ball moves to pickup position
@export var drop_random_radius: float = 0.1
@export var drop_impulse_strength: float = 2.0
@export var ball_collision_mask: int = 1

# Node references
@onready var arm_pivot: Node3D = $"."
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hand: Node3D = $Hand
@onready var detect_ray: RayCast3D = $Hand/RayCast3D

# State
var _state: String = "idle" # States: "idle", "pickup", "holding", "releasing"
var _held_ball: RigidBody3D = null
var _time: float = 0.0

#Cooldown Variables
var _is_on_cooldown: bool = false
var release_cooldown_time: float = 3.0

# Lerp tracking variables
var _lerp_start_pos: Vector3 = Vector3.ZERO
var _lerp_target_pos: Vector3 = Vector3.ZERO
var _lerp_progress: float = 0.0

func _ready():
	anim.play("idle")
	detect_ray.enabled = true
	detect_ray.collision_mask = ball_collision_mask

func _physics_process(delta: float) -> void:
	_time += delta
	
	# Only oscillate in idle state to avoid fighting animations
	if _state == "idle" or "holding":
		_idle_oscillate(_time)
		if _state == "idle":
			_check_for_ball_below_crane()
		
	#Lerp Logic
	if _held_ball:
		#Moving to hands initila positiion
		if _state == "pickup":
			#Increment progress
			_lerp_progress = min(_lerp_progress + delta * pickup_speed, 1.0)
			
			#Target = Hand node
			_held_ball.global_position = _lerp_start_pos.lerp(_lerp_target_pos, _lerp_progress)
			
		elif _state == "holding":
			#Now the ball reaches hand final position 
			_held_ball.global_position = hand.global_position + hand.global_transform.basis * pickup_offset
	pass #Otherwise pass
	
func _idle_oscillate(t: float) -> void: 
	var angle = sin(t * idle_oscillation_speed) * idle_oscillation_amplitude
	arm_pivot.rotation = Vector3(0.0, angle, 0.0)

func _check_for_ball_below_crane():
	# Don't check if already processing a ball
	if _held_ball != null or _state != "idle" or _is_on_cooldown:
		return
	if not detect_ray.is_colliding():
		return
		
	var ball = detect_ray.get_collider()
	if ball is RigidBody3D:
		ball.freeze = true
		_start_pickup(ball)
		
# -- PICKUP SEQUENCE --
func _start_pickup(ball: RigidBody3D) -> void:
	if _state != "idle":
		return
		
	_state = "pickup"
	_held_ball = ball
	
	# Disable physics while held
	ball.freeze = true
	ball.collision_layer = 0
	ball.collision_mask = 0
	
	# Save velocities to restore later
	ball.set_meta("saved_linear_vel", ball.linear_velocity)
	ball.set_meta("saved_angular_vel", ball.angular_velocity)
	
	# Play grab animation (Reach down)
	anim.play("grab")
	await anim.animation_finished
	
	# Initilize lerp parameters
	_lerp_start_pos = ball.global_position
	_lerp_target_pos = hand.global_position + hand.global_transform.basis * pickup_offset
	_lerp_progress = 0.0
	_held_ball.visible = false
	
	#Play pickup animation
	#Ball will follow the hands path
	anim.play("pickup")
	
	#Calculate how lomg we need to wait for pickup anuimation 
	var pickup_duration = anim.get_animation("pickup").length
	await get_tree().create_timer(pickup_duration).timeout
	
	#Movement is finished start holding phase
	_held_ball.global_position = hand.global_position + hand.global_transform.basis * pickup_offset
	
	_hold_and_swing()
	
func _hold_and_swing() -> void:
	if _held_ball == null:
		_state = "idle"
		return
		
	_state = "holding"
	_held_ball.visible = true
	
	# Random hold time
	var hold_duration = randf_range(hold_time_min, hold_time_max)
	anim.play("idle")
	await get_tree().create_timer(hold_duration).timeout
	
	# Release the ball
	_release_ball()

func _release_ball() -> void:
	if _held_ball == null:
		_state = "idle"
		return
	
	_state = "releasing"
	var ball = _held_ball
	ball.visible = false
	
	#Start let go animation
	anim.play("letgo")
	await anim.animation_finished
	
	#To keep tje ball visually attached must continously update position
	#during the letgo animation until moment of release
	var anim_time = anim.get_animation("letgo").length
		
	#Wait for the animation to finish while updating position
	for i in range(int(anim_time / get_physics_process_delta_time())):
		ball.global_position = hand.global_position + hand.global_basis * pickup_offset
	# Calculate drop position with random offset
	var drop_pos = hand.global_position + Vector3(
		randf_range(-drop_random_radius, drop_random_radius),
		0.0,
		randf_range(-drop_random_radius, drop_random_radius)
	)
	
	ball.global_position = drop_pos
	
	#Restore Physics:
	ball.collision_layer = 1
	ball.collision_mask = ball_collision_mask
	
	#Resetm all motiin
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	
	#Unfreeze physics
	ball.visible = true
	ball.freeze = false
	
	# Clear held ball reference
	_held_ball = null
	
	# Return to idle
	_state = "idle"
	
	#Cooldown
	_is_on_cooldown = true
	print("Crane Cooldown Started")
	
	await get_tree().create_timer(release_cooldown_time).timeout
	
	_is_on_cooldown = false
	print("Crane Cooldown Finished")
