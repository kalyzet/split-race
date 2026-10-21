extends Control

const LAP_OPTIONS := [2, 3]
const DIFFICULTY_NAMES := ["Easy", "Normal", "Hard"]


func _ready() -> void:
	%ModeLabel.text = (
		"MULTIPLAYER" if GameManager.game_mode == GameManager.GameMode.LOCAL_MULTIPLAYER
		else "SINGLE PLAYER"
	)
	%LapsOption.clear()
	for lap in LAP_OPTIONS:
		%LapsOption.add_item("%d Laps" % lap)
	%LapsOption.select(LAP_OPTIONS.find(GameManager.lap_count))

	%DifficultyOption.clear()
	for name in DIFFICULTY_NAMES:
		%DifficultyOption.add_item(name)
	%DifficultyOption.select(int(GameManager.difficulty))

	%StartButton.grab_focus()


func _on_start_button_pressed() -> void:
	GameManager.lap_count = LAP_OPTIONS[%LapsOption.selected]
	GameManager.difficulty = GameManager.Difficulty(%DifficultyOption.selected)
	GameManager.start_race()


func _on_back_button_pressed() -> void:
	GameManager.go_home()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameManager.go_home()
