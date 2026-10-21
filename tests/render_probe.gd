extends Node

func _ready() -> void:
	GameManager.game_mode = GameManager.GameMode.SINGLE_PLAYER
	var race = load("res://scenes/race.tscn").instantiate()
	add_child(race)
	await get_tree().process_frame
	await get_tree().process_frame
	var split: Control = race.get_node("SplitScreen")
	print("anchors LRTB: ", split.anchor_left, "/", split.anchor_top, "/", split.anchor_right, "/", split.anchor_bottom)
	print("offsets: ", split.offset_left, "/", split.offset_top, "/", split.offset_right, "/", split.offset_bottom)
	print("parent: ", split.get_parent(), " parent_control: ", split.get_parent_control())
	print("visible_rect: ", get_viewport().get_visible_rect().size)
	print("window size: ", get_window().size)
	print("split size: ", split.size)
	split.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	print("split size after preset reapply: ", split.size)
	await get_tree().process_frame
	print("split size after frame: ", split.size)
	var c1: SubViewportContainer = race.get_node("SplitScreen/ViewportContainer1")
	print("container1 size: ", c1.size, " vp1 size: ", race.viewport1.size)
	get_tree().quit()
