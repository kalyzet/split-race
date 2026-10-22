extends Node

var failures: Array[String] = []
var races: Array[Node] = []


func _ready() -> void:
	GameManager.game_mode = GameManager.GameMode.SINGLE_PLAYER
	GameManager.lap_count = 2
	await _test_difficulty_speeds()
	await _test_start_ranking()
	await _test_go_timer()
	GameManager.difficulty = GameManager.Difficulty.NORMAL
	for r in races:
		r.queue_free()
	if failures.is_empty():
		print("DIFFICULTY/TIMING PROBE PASS")
	else:
		for f in failures:
			print("FAIL: ", f)
		print("DIFFICULTY/TIMING PROBE FAILED")
	get_tree().quit(0 if failures.is_empty() else 1)


func _spawn_race():
	var race = load("res://scenes/race.tscn").instantiate()
	add_child(race)
	races.append(race)
	return race


func _test_difficulty_speeds() -> void:
	var expected := {
		GameManager.Difficulty.EASY: 357.0,
		GameManager.Difficulty.NORMAL: 399.0,
		GameManager.Difficulty.HARD: 441.0,
	}
	for diff in expected:
		GameManager.difficulty = diff
		var race = _spawn_race()
		race.set_process(false)
		await get_tree().process_frame
		for i in range(1, race.cars.size()):
			var car: Car = race.cars[i]
			if not is_equal_approx(car.max_speed, expected[diff]):
				failures.append("difficulty %d: CPU %d max_speed %.1f != %.1f" % [diff, i, car.max_speed, expected[diff]])
				break
		var sample: Car = race.cars[1]
		print("difficulty %d: cpu max_speed=%.1f" % [diff, sample.max_speed])


func _test_start_ranking() -> void:
	var race = _spawn_race()
	race.set_process(false)
	await get_tree().process_frame
	race.set_physics_process(false)
	var track: RaceTrack = race.track
	var total := track.curve.get_baked_length()
	var crossed: Car = race.cars[0]
	var behind: Car = race.cars[1]
	crossed.lap = 0
	crossed.next_checkpoint = 1
	crossed.path_offset = 40.0
	behind.lap = 0
	behind.next_checkpoint = 1
	behind.path_offset = fposmod(total - 40.0, total)
	race._update_ranking()
	var p_crossed: int = race.get_position_of(crossed)
	var p_behind: int = race.get_position_of(behind)
	print("start ranking: crossed pos=%d, behind pos=%d" % [p_crossed, p_behind])
	if p_crossed >= p_behind:
		failures.append("start ranking: crossed car ranks behind (%d vs %d)" % [p_crossed, p_behind])


func _test_go_timer() -> void:
	GameManager.difficulty = GameManager.Difficulty.NORMAL
	var race = _spawn_race()
	var at_go := -1.0
	var at_racing := -1.0
	var unfrozen_at_go := false
	for i in 600:
		await get_tree().process_frame
		if race.state == race.State.GO and at_go < 0.0:
			at_go = race.race_time
			unfrozen_at_go = not race.cars[0].frozen
		if race.state == race.State.RACING:
			at_racing = race.race_time
			break
	print("timer: race_time at GO=%.3f, at RACING=%.3f" % [at_go, at_racing])
	if not unfrozen_at_go:
		failures.append("timer: cars still frozen at GO")
	if at_racing < 0.75 or at_racing > 1.15:
		failures.append("timer: race_time at RACING is %.3f (expected ~0.9)" % at_racing)
