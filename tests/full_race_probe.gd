extends Node

var frames := 0
var race
var _auto_curve: Curve2D
var _observed := false


class Observer:
	extends Node

	var frames := 0

	func _process(_delta: float) -> void:
		frames += 1
		var scene := get_tree().current_scene
		if scene != null and scene.scene_file_path.contains("results"):
			print("SCENE CHANGED TO: ", scene.scene_file_path)
			var rows: VBoxContainer = scene.get_node("%Rows")
			print("RESULTS ROWS: ", rows.get_child_count())
			for row in rows.get_children():
				var texts: Array[String] = []
				for child in row.get_children():
					if child is Label:
						texts.append(child.text)
				print("  ", " ".join(texts))
			print("BEST: ", scene.get_node("%BestLapLabel").text)
			print("E2E RACE COMPLETE OK")
			get_tree().quit()
		elif frames > 30000:
			print("E2E TIMEOUT WAITING FOR RESULTS, current=", scene.scene_file_path if scene else "null")
			get_tree().quit()


func _ready() -> void:
	GameManager.game_mode = GameManager.GameMode.SINGLE_PLAYER
	GameManager.lap_count = 2
	GameManager.difficulty = GameManager.Difficulty.NORMAL
	race = load("res://scenes/race.tscn").instantiate()
	add_child(race)
	var observer := Observer.new()
	observer.name = "ResultsObserver"
	get_tree().root.add_child.call_deferred(observer)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(race) or _auto_curve == null:
		return
	for i in 2:
		if i >= race.cars.size():
			break
		var c: Car = race.cars[i]
		if c.is_finished or c.frozen:
			continue
		var total_len := _auto_curve.get_baked_length()
		var target := _auto_curve.sample_baked(fposmod(c.path_offset + 100.0 + c.speed * 0.3, total_len))
		c.drive_direction = (target - c.global_position).normalized()
		c.wants_brake = false
		c.wants_turbo = c.turbo > 50.0 and c.speed > c.max_speed * 0.8


func _process(_delta: float) -> void:
	frames += 1
	if frames == 60 and is_instance_valid(race):
		_auto_curve = race.track.curve
	if frames % 300 == 0 and is_instance_valid(race):
		var finished := 0
		for c in race.cars:
			if c.is_finished:
				finished += 1
		print("t=%d state=%s time=%.1f finished=%d/7" % [frames, race.state, race.race_time, finished])
	if frames >= 30000 and not _observed:
		_observed = true
		print("E2E TIMEOUT IN PROBE")
		get_tree().quit()
