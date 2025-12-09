extends RigidBody3D

var on_track := false
var follow_node : PathFollow3D
var track_speed := 4.0

func enter_track(follow):
	on_track = true
	follow_node = follow
	set_freeze_mode(RigidBody3D.FREEZE_MODE_KINEMATIC)
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = follow.global_transform
	follow.progress = 0.0
	
func _physics_process(delta: float) -> void:
	if on_track:
		follow_node.progress += track_speed * delta
		global_transform = follow_node.global_transform
		
		if follow_node.progress >= 2.25:
			exit_track()
			
func exit_track():
	on_track = false
	freeze = false
	set_freeze_mode(RigidBody3D.FREEZE_MODE_STATIC)
