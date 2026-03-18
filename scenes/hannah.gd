extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 12

var xform : Transform3D


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#play robot anumations
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$AnimationPlayer.play("jump")
	elif Input.is_action_just_pressed("wave"):
		$AnimationPlayer.play("wave")
	elif is_on_floor() and input_dir!=Vector2(0,0):
		$AnimationPlayer.play("run")
	elif is_on_floor() and input_dir==Vector2(0,0) and $AnimationPlayer.current_animation != "wave":
		$AnimationPlayer.play("idle")
	
	
	
	
	
	
	
	
	
	#rotate camera left and right
	if Input.is_action_just_pressed("cam_left"):
		$camera_controller.rotate_y(deg_to_rad(-30))
	if Input.is_action_just_pressed("cam_right"):
		$camera_controller.rotate_y(deg_to_rad(30))
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$SoundJump.play()
		velocity.y = JUMP_VELOCITY
		


	#its a new vector3 direction taking into account the user arrow input and the camera rotation
	var direction :Vector3=($camera_controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#rotate the character mesh so oriented towards the direction moving in relation to the camera
	if input_dir != Vector2(0,0):
		$Armature.rotation_degrees.y=$camera_controller.rotation_degrees.y - rad_to_deg(input_dir.angle()) -90
	#rotate the character to align with floor
	if is_on_floor() :
		align_with_floor($RayCast3D.get_collision_normal())
		global_transform=global_transform.interpolate_with(xform,0.3)
	elif not is_on_floor():
		align_with_floor(Vector3.UP)
		global_transform=global_transform.interpolate_with(xform,0.3)
	
	
	
	#update the velocity and move the character
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	#MAKE CAMERA CONTROLLER MATCH THE POSITION OF MYSELF
	$camera_controller.position = lerp($camera_controller.position, position , 0.15)


func align_with_floor(floor_normal):
	xform=global_transform
	xform.basis.y=floor_normal
	xform.basis.x= -xform.basis.z.cross(floor_normal)
	xform.basis=xform.basis.orthonormalized()


func _on_fall_zone_body_entered(body: Node3D) -> void:
	SoundManager.play_sound_fall()
	
	get_tree().change_scene_to_file("res://scenes/menu_game_over.tscn")


func bounce():
	velocity.y = JUMP_VELOCITY * 0.7
	
