extends AnimatableBody3D

@onready var default_3d_map_rid: RID = get_world_3d().get_navigation_map()
@onready var goblin_idle_timer: Timer = $GoblinIdleTimer

var movement_speed: float = 4.0
var movement_delta: float
var path_point_margin: float = 0.5

var current_path_index: int = 0
var current_path_point: Vector3
var current_path: PackedVector3Array

@export_range(0, 20) var health: float = 5.0:
	set(new_value):
		health = clampf(new_value, 0.0, 20.0)
		if health == 0.0:
			_death()

func _death():
	queue_free()

func set_movement_target(target_position: Vector3):
	var start_position: Vector3 = global_transform.origin

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
	goblin_idle_timer.start()

func _physics_process(delta):

	if current_path.is_empty():
		return

	movement_delta = movement_speed * delta

	if global_transform.origin.distance_to(current_path_point) <= path_point_margin:
		current_path_index += 1
		if current_path_index >= current_path.size():
			current_path = []
			current_path_index = 0
			current_path_point = global_transform.origin
			goblin_idle_timer.start()
			return

	current_path_point = current_path[current_path_index]

	var new_velocity: Vector3 = global_transform.origin.direction_to(current_path_point) * movement_delta

	global_transform.origin = global_transform.origin.move_toward(global_transform.origin + new_velocity, movement_delta)


func _on_goblin_idle_timer_timeout() -> void:
	var x_diff: float = clampf((randf() * 6.0), 3.0, 6.0)
	var z_diff: float = clampf((randf() * 6.0), 3.0, 6.0)
	
	if randi() % 2 == 1:
		x_diff = -x_diff
	if randi() % 2 == 1:
		z_diff = -z_diff
	
	var new_target: Vector3 = global_transform.origin
	new_target.x += x_diff
	new_target.z += z_diff
	
	rotation.y = atan2(x_diff, z_diff)
	set_movement_target(new_target)
