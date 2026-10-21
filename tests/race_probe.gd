extends Node

var frames := 0
var race: Node2D
var results_tested := false


func _ready() -> void:
	GameManager.game_mode = GameManager.GameMode.LOCAL_MULTIPLAYER
	GameManager.lap_count = 2
	race = load("res://scenes/race.tscn").instantiate()
	add_child(race)


func _process(_delta: float) -> void:
	frames += 1
	if frames % 180 == 0 and race != null:
		var line := "t=%d state=%s time=%.1f" % [frames, race.state, race.race_time]
		for c in race.cars:
			line += " | id%d lap%d cp%d spd%.0f off%.0f%s" % [
				c.car_id, c.lap, c.next_checkpoint, c.speed, c.path_offset,
				" FIN" if c.is_finished else "",
			]
		print(line)

	if frames == 900 and race != null:
		print("VIEWPORT2 WORLD SHARED: ", race.viewport2.world_2d == race.viewport1.world_2d)
		print("CONTAINER2 VISIBLE: ", race.container2.visible)
		print("CAMERA1 TARGET: ", race.camera1.target.car_id if race.camera1.target else "none")
		print("CAMERA2 TARGET: ", race.camera2.target.car_id if race.camera2.target else "none")

	if frames >= 900 and not results_tested:
		results_tested = true
		_test_results_scene()

	if frames >= 1100:
		get_tree().quit()


func _test_results_scene() -> void:
	GameManager.race_results = [
		{"position": 1, "color_name": "Blue", "player_index": 0, "finish_time": 151.42, "lap_times": [48.17]},
		{"position": 2, "color_name": "Red", "player_index": 1, "finish_time": 154.17, "lap_times": [49.0]},
		{"position": 3, "color_name": "Yellow", "player_index": -1, "finish_time": 158.51, "lap_times": [50.2]},
	]
	GameManager.best_lap = 48.17
	var results: Control = load("res://scenes/results.tscn").instantiate()
	add_child(results)
	await get_tree().process_frame
	await get_tree().process_frame
	var rows: VBoxContainer = results.get_node("%Rows")
	print("RESULTS ROWS: ", rows.get_child_count())
	print("BEST LAP LABEL: ", results.get_node("%BestLapLabel").text)
	results.queue_free()
	print("RESULTS SCENE OK")
