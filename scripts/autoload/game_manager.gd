extends Node

enum GameMode { SINGLE_PLAYER, LOCAL_MULTIPLAYER }
enum Difficulty { EASY, NORMAL, HARD }

const SCENE_HOME := "res://scenes/main_menu.tscn"
const SCENE_SETUP := "res://scenes/race_setup.tscn"
const SCENE_RACE := "res://scenes/race.tscn"
const SCENE_RESULTS := "res://scenes/results.tscn"

var game_mode: GameMode = GameMode.SINGLE_PLAYER
var lap_count: int = 2
var difficulty: Difficulty = Difficulty.NORMAL
var race_results: Array[Dictionary] = []
var best_lap: float = -1.0


func go_home() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(SCENE_HOME)


func go_setup() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(SCENE_SETUP)


func start_race() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(SCENE_RACE)


func go_results() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(SCENE_RESULTS)


func play_again() -> void:
	start_race()


func cpu_params() -> Dictionary:
	match difficulty:
		Difficulty.EASY:
			return {
				"speed_mult": 0.85,
				"steering_noise": 55.0,
				"brake_threshold": 0.38,
				"mistake_chance": 0.35,
				"turbo_threshold": 45.0,
			}
		Difficulty.NORMAL:
			return {
				"speed_mult": 0.95,
				"steering_noise": 28.0,
				"brake_threshold": 0.5,
				"mistake_chance": 0.14,
				"turbo_threshold": 32.0,
			}
		Difficulty.HARD:
			return {
				"speed_mult": 1.05,
				"steering_noise": 10.0,
				"brake_threshold": 0.62,
				"mistake_chance": 0.04,
				"turbo_threshold": 22.0,
			}
	return cpu_params()


static func format_time(t: float) -> String:
	if t < 0.0:
		return "--:--.--"
	var total_cs := int(t * 100.0)
	var cs := total_cs % 100
	var total_s := total_cs / 100
	var s := total_s % 60
	var m := total_s / 60
	return "%02d:%02d.%02d" % [m, s, cs]


static func ordinal(n: int) -> String:
	match n:
		1:
			return "1st"
		2:
			return "2nd"
		3:
			return "3rd"
	return "%dth" % n
