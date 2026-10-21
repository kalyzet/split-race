extends Node

class Observer:
	extends Node
	var frames := 0
	var target_path := ""
	func _process(_delta: float) -> void:
		frames += 1
		var scene := get_tree().current_scene
		if scene != null and scene.scene_file_path.contains(target_path):
			print("SCENE CHANGED TO: ", scene.scene_file_path)
			print("RESULTS BUTTON OK")
			get_tree().quit()
		elif frames > 600:
			print("TIMEOUT, current=", scene.scene_file_path if scene else "null")
			get_tree().quit()

func _ready() -> void:
	GameManager.race_results = [
		{"position": 1, "color_name": "Blue", "player_index": 0, "finish_time": 90.5, "lap_times": [44.1]},
		{"position": 2, "color_name": "Red", "player_index": -1, "finish_time": 92.1, "lap_times": [45.0]},
	]
	GameManager.best_lap = 44.1
	var results: Control = load("res://scenes/results.tscn").instantiate()
	add_child(results)
	await get_tree().process_frame
	await get_tree().process_frame
	var again := OS.get_cmdline_user_args().has("again")
	var target := "race.tscn" if again else "main_menu.tscn"
	var observer := Observer.new()
	observer.target_path = target
	get_tree().root.add_child.call_deferred(observer)
	await get_tree().process_frame
	if again:
		print("PRESSING AGAIN")
		results.get_node("Center/Menu/Buttons/AgainButton").pressed.emit()
	else:
		print("PRESSING HOME")
		results.get_node("Center/Menu/Buttons/HomeButton").pressed.emit()
