extends Node

var car: Car
var curve: Curve2D

var params: Dictionary = {
	"speed_mult": 1.0,
	"steering_noise": 25.0,
	"brake_threshold": 0.5,
	"mistake_chance": 0.1,
	"turbo_threshold": 30.0,
}

var _noise: Vector2 = Vector2.ZERO
var _noise_time: float = 0.0
var _stuck_time: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	car = get_parent() as Car


func setup(p_curve: Curve2D, p_params: Dictionary) -> void:
	curve = p_curve
	params = p_params


func _physics_process(delta: float) -> void:
	if car == null:
		return
	if car.is_finished or car.frozen or curve == null:
		if car != null:
			car.drive_direction = Vector2.ZERO
			car.wants_brake = false
			car.wants_turbo = false
		return

	var total_len := curve.get_baked_length()
	var target_ahead := 90.0 + car.speed * 0.35
	var target_pos := curve.sample_baked(fposmod(car.path_offset + target_ahead, total_len))
	var to_target := target_pos - car.global_position

	_noise_time -= delta
	if _noise_time <= 0.0:
		_noise_time = _rng.randf_range(0.4, 1.1)
		var n: float = params["steering_noise"]
		_noise = Vector2(_rng.randf_range(-n, n), _rng.randf_range(-n, n))

	car.drive_direction = (to_target + _noise).normalized()

	var danger := _corner_danger(total_len)
	var brake_threshold: float = params["brake_threshold"]
	car.wants_brake = danger > brake_threshold and car.speed > car.max_speed * 0.5

	var turbo_threshold: float = params["turbo_threshold"]
	car.wants_turbo = (
		danger < 0.15
		and car.turbo > turbo_threshold
		and car.speed > car.max_speed * 0.75
	)

	if car.speed < 15.0:
		_stuck_time += delta
		if _stuck_time > 2.5:
			_recover()
			_stuck_time = 0.0
	else:
		_stuck_time = 0.0

	if _rng.randf() < float(params["mistake_chance"]) * delta:
		car.drive_direction = car.drive_direction.rotated(_rng.randf_range(-0.7, 0.7))


func _corner_danger(total_len: float) -> float:
	var o_now := car.path_offset
	var o_mid := fposmod(o_now + 110.0, total_len)
	var o_far := fposmod(o_now + 230.0, total_len)
	var t_now := _tangent_at(o_now)
	var t_mid := _tangent_at(o_mid)
	var t_far := _tangent_at(o_far)
	var angle := absf(t_now.angle_to(t_mid)) + absf(t_mid.angle_to(t_far))
	return clampf(angle / PI * 1.4, 0.0, 1.0)


func _tangent_at(offset: float) -> Vector2:
	var total_len := curve.get_baked_length()
	var a := curve.sample_baked(fposmod(offset - 4.0, total_len))
	var b := curve.sample_baked(fposmod(offset + 4.0, total_len))
	var t := (b - a).normalized()
	return t if t.length_squared() > 0.001 else Vector2.RIGHT


func _recover() -> void:
	var total_len := curve.get_baked_length()
	car.global_position = curve.sample_baked(fposmod(car.path_offset, total_len))
	car.rotation = _tangent_at(car.path_offset).angle()
	car.speed = car.max_speed * 0.4
