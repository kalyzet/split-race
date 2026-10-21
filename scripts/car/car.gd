class_name Car
extends CharacterBody2D

@export_group("Movement")
@export var max_speed: float = 420.0
@export var acceleration: float = 380.0
@export var brake_force: float = 780.0
@export var friction: float = 230.0
@export var base_turn_rate: float = 5.2
@export var min_turn_rate: float = 1.7

@export_group("Turbo")
@export var turbo_multiplier: float = 1.45
@export var turbo_drain: float = 38.0
@export var turbo_recharge: float = 9.0
@export var turbo_capacity: float = 100.0

@onready var _body_poly: Polygon2D = $Visual/Body

var speed: float = 0.0
var turbo: float = 100.0
var turbo_active: bool = false

var drive_direction: Vector2 = Vector2.ZERO
var wants_brake: bool = false
var wants_turbo: bool = false

var frozen: bool = true
var is_finished: bool = false
var finish_time: float = -1.0

var lap: int = 0
var next_checkpoint: int = 1
var path_offset: float = 0.0
var lap_mark: float = 0.0
var lap_times: Array[float] = []

var car_id: int = 0
var color_name: String = ""

var _push: Vector2 = Vector2.ZERO


func set_color(color: Color) -> void:
	if _body_poly != null:
		_body_poly.color = color


func apply_push(impulse: Vector2) -> void:
	if is_finished:
		return
	_push += impulse
	speed *= 0.9


func mark_finished(time: float) -> void:
	is_finished = true
	finish_time = time
	speed = 0.0
	velocity = Vector2.ZERO
	_push = Vector2.ZERO
	collision_layer = 0


func _physics_process(delta: float) -> void:
	if is_finished:
		velocity = Vector2.ZERO
		return
	if frozen:
		speed = 0.0
		velocity = Vector2.ZERO
		_push = Vector2.ZERO
		return

	_update_turbo(delta)
	_update_movement(delta)
	_handle_collisions()


func _update_turbo(delta: float) -> void:
	if wants_turbo and turbo > 0.0 and speed > 20.0:
		turbo_active = true
		turbo = maxf(turbo - turbo_drain * delta, 0.0)
	else:
		turbo_active = false
		turbo = minf(turbo + turbo_recharge * delta, turbo_capacity)


func _update_movement(delta: float) -> void:
	var effective_max := max_speed * (turbo_multiplier if turbo_active else 1.0)

	if drive_direction.length_squared() > 0.01:
		var target_angle := drive_direction.angle()
		var diff := wrapf(target_angle - rotation, -PI, PI)
		var speed_ratio := clampf(speed / max_speed, 0.0, 1.0)
		var turn_rate := lerpf(base_turn_rate, min_turn_rate, speed_ratio)
		rotation += clampf(diff, -turn_rate * delta, turn_rate * delta)
		speed = minf(speed + acceleration * delta, effective_max)
	else:
		speed = maxf(speed - friction * delta, 0.0)

	if wants_brake:
		speed = maxf(speed - brake_force * delta, 0.0)

	speed = minf(speed, effective_max)

	var heading := Vector2.RIGHT.rotated(rotation)
	velocity = heading * speed + _push
	move_and_slide()
	_push = _push.move_toward(Vector2.ZERO, 220.0 * delta)


func _handle_collisions() -> void:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider is Car:
			var other := collider as Car
			if other.is_finished:
				continue
			var n := col.get_normal()
			_push += n * 50.0
			speed *= 0.9
			other.apply_push(-n * 130.0)
