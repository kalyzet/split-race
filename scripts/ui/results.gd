extends Control


func _ready() -> void:
	for entry in GameManager.race_results:
		%Rows.add_child(_make_row(entry))
	if GameManager.best_lap >= 0.0:
		%BestLapLabel.text = "BEST LAP  %s" % GameManager.format_time(GameManager.best_lap)
	else:
		%BestLapLabel.text = "BEST LAP  --:--.--"
	%AgainButton.grab_focus()


func _make_row(entry: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(560, 34)

	var pos_label := Label.new()
	pos_label.text = GameManager.ordinal(entry["position"])
	pos_label.custom_minimum_size = Vector2(70, 0)
	row.add_child(pos_label)

	var name_label := Label.new()
	var name: String = entry["color_name"] + " Car"
	var player_index: int = entry["player_index"]
	if player_index >= 0:
		name += "  (P%d)" % (player_index + 1)
	else:
		name += "  (CPU)"
	name_label.text = name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)

	var time_label := Label.new()
	time_label.text = GameManager.format_time(entry["finish_time"])
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	time_label.custom_minimum_size = Vector2(140, 0)
	row.add_child(time_label)

	return row


func _on_again_button_pressed() -> void:
	GameManager.play_again()


func _on_home_button_pressed() -> void:
	GameManager.go_home()
