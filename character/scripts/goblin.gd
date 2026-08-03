extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_range(0.001, 0.02) var rotation_speed = 0.01

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var forward_dir := Input.get_axis("ui_up", "ui_down")
	var rotate_dir := Input.get_axis("ui_right", "ui_left")
	var direction := (transform.basis * Vector3(0, 0, forward_dir)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	rotation.y = rotation.y + rotate_dir * rotation_speed
	

	move_and_slide()
