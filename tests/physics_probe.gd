extends Node

var race: Control
var track: RaceTrack
var cars: Array[Car] = []
var failures: Array[String] = []


func _ready() -> void:
	race = load("res://scenes/race.tscn").instantiate()
	add_child(race)
	race.set_process(false)
	await get_tree().process_frame
	track = race.track
	cars = race.cars
	for c in cars:
		var controller := c.get_node_or_null("Controller")
		if controller != null:
			controller.set_physics_process(false)
		c.frozen = true
		c.speed = 0.0
		c.drive_direction = Vector2.ZERO
	await _test_wall_scrape()
	await _test_head_on()
	if failures.is_empty():
		print("PHYSICS PROBE PASS")
	else:
		for f in failures:
			print("FAIL: ", f)
		print("PHYSICS PROBE FAILED")
	get_tree().quit(0 if failures.is_empty() else 1)


func _test_wall_scrape() -> void:
	var total := track.curve.get_baked_length()
	var o := _straight_offset(total)
	var p := track.curve.sample_baked(o)
	var t := track._tangent_at(o)
	var n := t.orthogonal()
	var half := track.width_at_offset(o) * 0.5
	var car := cars[0]
	car.global_position = p + n * (half - 30.0)
	var heading := (t + n * 0.45).normalized()
	car.rotation = heading.angle()
	car.speed = 200.0
	car.frozen = false
	var start := car.global_position
	var max_lateral := 0.0
	for i in 90:
		car.drive_direction = heading
		await get_tree().physics_frame
		max_lateral = maxf(max_lateral, _lateral_from_center(car.global_position))
	var progress := (car.global_position - start).dot(t)
	print("wall scrape: progress=%.1f px max_lateral=%.1f px" % [progress, max_lateral])
	if progress < 250.0:
		failures.append("wall scrape: only %.1f px progress in 1.5s (snagged)" % progress)
	if max_lateral > half + 10.0:
		failures.append("wall scrape: escaped track (lateral %.1f > %.1f)" % [max_lateral, half + 10.0])
	car.drive_direction = Vector2.ZERO
	car.frozen = true


func _test_head_on() -> void:
	var total := track.curve.get_baked_length()
	var o := _straight_offset(total)
	var p := track.curve.sample_baked(o)
	var t := track._tangent_at(o)
	var a := cars[0]
	var b := cars[1]
	a.global_position = p
	a.rotation = t.angle()
	a.speed = 260.0
	a.frozen = false
	b.global_position = p + t * 380.0
	b.rotation = (-t).angle()
	b.speed = 240.0
	b.frozen = false
	var min_dist := INF
	var min_after_contact := INF
	var contacted := false
	var max_speed := 0.0
	var non_finite := false
	for i in 120:
		a.drive_direction = t
		b.drive_direction = -t
		await get_tree().physics_frame
		var d := a.global_position.distance_to(b.global_position)
		min_dist = minf(min_dist, d)
		if d < 44.0:
			contacted = true
		if contacted:
			min_after_contact = minf(min_after_contact, d)
		max_speed = maxf(max_speed, maxf(a.speed, b.speed))
		if not is_finite(a.global_position.x) or not is_finite(b.global_position.x):
			non_finite = true
			break
	print("head-on: min_dist=%.1f min_after_contact=%.1f max_speed=%.1f" % [min_dist, min_after_contact, max_speed])
	if not contacted:
		failures.append("head-on: cars never met (min_dist %.1f)" % min_dist)
	elif min_after_contact < 41.0:
		failures.append("head-on: overlap down to %.1f px" % min_after_contact)
	if non_finite:
		failures.append("head-on: non-finite position")
	if max_speed > 700.0:
		failures.append("head-on: runaway speed %.1f" % max_speed)
	a.drive_direction = Vector2.ZERO
	b.drive_direction = Vector2.ZERO
	a.frozen = true
	b.frozen = true


func _straight_offset(total: float) -> float:
	var best_o := total * 0.2
	var best_bend := INF
	for k in 40:
		var o := total * (0.15 + 0.2 * float(k) / 40.0)
		var bend := absf(track._tangent_at(o).angle_to(track._tangent_at(o + 300.0)))
		if bend < best_bend:
			best_bend = bend
			best_o = o
	return fposmod(best_o, total)


func _lateral_from_center(pos: Vector2) -> float:
	var o := track.curve.get_closest_offset(pos)
	return pos.distance_to(track.curve.sample_baked(o))
