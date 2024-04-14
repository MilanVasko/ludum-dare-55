extends AnimatableBody3D

@export var opened: bool
@export var closed_angle: float
@export var opened_angle: float
@export var time_to_change: float
var current_time_to_change: float

var previous_rotation_degrees: Vector3
var target_rotation_degrees: Vector3

func _ready() -> void:
	rotation_degrees = Vector3.UP * (opened_angle if opened else closed_angle)
	target_rotation_degrees = rotation_degrees
	previous_rotation_degrees = rotation_degrees
	current_time_to_change = time_to_change

func _can_interact() -> bool:
	return is_equal_approx(current_time_to_change, time_to_change)

func _interact() -> void:
	previous_rotation_degrees = Vector3.UP * (opened_angle if opened else closed_angle)
	opened = !opened
	target_rotation_degrees = Vector3.UP * (opened_angle if opened else closed_angle)
	current_time_to_change = 0.0

func _process(delta: float) -> void:
	if !rotation_degrees.is_equal_approx(target_rotation_degrees):
		current_time_to_change = clampf(current_time_to_change + delta, 0.0, time_to_change)
		rotation_degrees = previous_rotation_degrees.slerp(
			target_rotation_degrees,
			current_time_to_change / time_to_change if time_to_change > 0.0 else 1.0
		)
