extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export_range(0.001, 0.2) var rotation_speed = 0.01
@export_range(0.0001, 0.01) var mouse_sensitivity: float = 0.0025

@export var max_health: float = 5.0

var health: float:
	set(new_value):
		health = clampf(new_value, 0.0, 20.0)
		if health == 0.0:
			_death()

@onready var punches: AnimationPlayer = $Punches

var punching: bool = false

func _death() -> void:
	get_tree().change_scene_to_file("res://menu/title_screen.tscn")

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var forward_dir := Input.get_axis("move_forward", "move_backward")
	var rotate_dir := Input.get_axis("turn_right", "turn_left")
	var strafe_dir := 0.0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		strafe_dir += 1.0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		strafe_dir -= 1.0

	var direction := (transform.basis * Vector3(0, 0, forward_dir)).normalized()
	var strafe_vector := (transform.basis * Vector3(strafe_dir, 0, 0)).normalized()
	var move_vector := direction + strafe_vector

	if move_vector.length_squared() > 0.0:
		velocity.x = move_vector.x * SPEED
		velocity.z = move_vector.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	rotation.y = rotation.y + rotate_dir * rotation_speed

	if not punching:
		if Input.is_action_just_pressed("left_jab"):
			punches.play("LeftJab")
			punching = true
		elif Input.is_action_just_pressed("right_jab"):
			punches.play("RightJab")
			punching = true

	move_and_slide()

func _on_punches_finished(anim_name: StringName) -> void:
	punching = false # Replace with function body.

func _on_fist_touch(body: Node3D) -> void:
	if body.name == "EnemyGoblin":
		if punching == true:
			body.health -= 1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
	if event is InputEventKey and event.pressed and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clampf(rotation.x, -0.5, 0.6)
