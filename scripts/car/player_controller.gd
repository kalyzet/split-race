extends Node

var car: Car
@export var input_prefix: String = "p1_"


func _ready() -> void:
	car = get_parent() as Car


func _physics_process(_delta: float) -> void:
	if car == null:
		return
	if car.is_finished or car.frozen:
		car.drive_direction = Vector2.ZERO
		car.wants_brake = false
		car.wants_turbo = false
		return

	var dir := Input.get_vector(
		input_prefix + "left",
		input_prefix + "right",
		input_prefix + "up",
		input_prefix + "down"
	)
	car.drive_direction = dir if dir.length() > 0.1 else Vector2.ZERO
	car.wants_brake = Input.is_action_pressed(input_prefix + "brake")
	car.wants_turbo = Input.is_action_pressed(input_prefix + "turbo")
