extends AnimatableBody3D

enum STATES {
	WANDERING,
	AGGRO
}

const WANDER_PATH_MARGIN: float = 0.5
const AGGRO_PATH_MARGIN: float = 3.0
const AGGRO_DISTANCE: float = 8.0

@onready var default_3d_map_rid: RID = get_world_3d().get_navigation_map()
@onready var goblin_idle_timer: Timer = $GoblinIdleTimer
@onready var goblin_attack_timer: Timer = $GoblinAttackTimer

@onready var punches: AnimationPlayer = $Punches
@onready var recoil: AnimationPlayer = $Recoil

@export var map_context: Map

@export var attack_sequence: Array[String]
var attack_sequence_idx: int = 0

var movement_speed: float = 4.0
var movement_delta: float
var path_point_margin: float = WANDER_PATH_MARGIN

var current_path_index: int = 0
var current_path_point: Vector3
var current_path: PackedVector3Array

@export var starting_state: STATES = STATES.WANDERING

var state: STATES

var punching: bool = false
var attacking: bool = false

@export_range(0, 20) var health: float = 5.0:
	set(new_value):
		if new_value < health:
			recoil.play("EyePop")
			aggro()
		health = clampf(new_value, 0.0, 20.0)
		if health == 0.0:
			_death()

func _death():
	queue_free()

func set_movement_target(target_position: Vector3):
	var start_position: Vector3 = global_position

	current_path = NavigationServer3D.map_get_path(
		default_3d_map_rid,
		start_position,
		target_position,
		true
	)

	if not current_path.is_empty():
		current_path_index = 0
		current_path_point = current_path[0]

func _ready() -> void:
	state = starting_state
	if state == STATES.WANDERING:
		goblin_idle_timer.start()

func _physics_process(delta):

	if state == STATES.AGGRO:
		follow_aggro()

	if current_path.is_empty():
		return

	movement_delta = movement_speed * delta

	if global_position.distance_to(current_path_point) <= path_point_margin:
		current_path_index += 1
		if current_path_index >= current_path.size():
			current_path = []
			current_path_index = 0
			current_path_point = global_position
			if state == STATES.WANDERING:
				goblin_idle_timer.start()
			return

	current_path_point = current_path[current_path_index]

	var new_velocity: Vector3 = global_position.direction_to(current_path_point) * movement_delta

	global_position = global_position.move_toward(global_position + new_velocity, movement_delta)


func _on_goblin_idle_timer_timeout() -> void:
	var x_diff: float = clampf((randf() * 6.0), 3.0, 6.0)
	var z_diff: float = clampf((randf() * 6.0), 3.0, 6.0)

	if randi() % 2 == 1:
		x_diff = - x_diff
	if randi() % 2 == 1:
		z_diff = - z_diff

	var new_target: Vector3 = global_position
	new_target.x += x_diff
	new_target.z += z_diff

	rotation.y = atan2(x_diff, z_diff)
	set_movement_target(new_target)

func aggro() -> void:
	state = STATES.AGGRO
	path_point_margin = AGGRO_PATH_MARGIN
	goblin_idle_timer.stop()
	follow_aggro()

func face_player(target_position: Vector3) -> void:
	var horizontal_target: Vector3 = Vector3(target_position.x, global_position.y, target_position.z)
	var direction_to_player: Vector3 = horizontal_target - global_position

	if direction_to_player.length_squared() < 0.0001:
		return

	var yaw_angle: float = atan2(direction_to_player.x, direction_to_player.z)
	rotation.y = yaw_angle

func follow_aggro() -> void:
	if map_context == null or map_context.player == null:
		return

	var target_position: Vector3 = map_context.player.global_position
	face_player(target_position)

	if target_position.distance_squared_to(global_position) > 1.5:
		attacking = false
		set_movement_target(target_position)
	else:
		if not attacking:
			attacking = true
			goblin_attack_timer.start()

func _on_fist_touch(body: Node3D) -> void:
	print(body.name)
	if body.name == "Goblin":
		if punching == true:
			body.health -= 1

func _on_start_attack() -> void:
	var attack: String = attack_sequence[attack_sequence_idx]
	punches.play(attack)
	punching = true
	attack_sequence_idx = (attack_sequence_idx + 1) % attack_sequence.size()

func _on_punches_finished(anim_name: StringName) -> void:
	punching = false
	if attacking:
		goblin_attack_timer.start()
