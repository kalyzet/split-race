extends CanvasLayer

@onready var p1_lap: Label = %P1Lap
@onready var p1_pos: Label = %P1Pos
@onready var p2_box: VBoxContainer = %P2Box
@onready var p2_lap: Label = %P2Lap
@onready var p2_pos: Label = %P2Pos
@onready var time_label: Label = %TimeLabel
@onready var turbo1: ProgressBar = %Turbo1
@onready var turbo2: ProgressBar = %Turbo2
@onready var p2_turbo_box: HBoxContainer = %P2TurboBox
@onready var countdown_label: Label = %CountdownLabel
@onready var pause_layer: CanvasLayer = %PauseLayer

var race


func bind(race_manager) -> void:
	race = race_manager
	var multi := GameManager.game_mode == GameManager.GameMode.LOCAL_MULTIPLAYER
	p2_box.visible = multi
	p2_turbo_box.visible = multi


func set_countdown(text: String) -> void:
	countdown_label.text = text
	countdown_label.visible = text != ""


func _process(_delta: float) -> void:
	if race == null:
		return
	time_label.text = GameManager.format_time(race.race_time)

	var p1: Car = race.cars[0]
	p1_lap.text = "LAP %d/%d" % [mini(p1.lap + 1, GameManager.lap_count), GameManager.lap_count]
	p1_pos.text = "POS %d/%d" % [race.get_position_of(p1) + 1, race.cars.size()]
	turbo1.value = p1.turbo

	if p2_box.visible and race.cars.size() > 1:
		var p2: Car = race.cars[1]
		p2_lap.text = "LAP %d/%d" % [mini(p2.lap + 1, GameManager.lap_count), GameManager.lap_count]
		p2_pos.text = "POS %d/%d" % [race.get_position_of(p2) + 1, race.cars.size()]
		turbo2.value = p2.turbo


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and race != null:
		if race.state == race.State.FINISHED:
			return
		var tree := get_tree()
		tree.paused = not tree.paused
		pause_layer.visible = tree.paused


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_layer.visible = false


func _on_home_pressed() -> void:
	GameManager.go_home()
