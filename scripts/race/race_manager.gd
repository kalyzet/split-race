extends Control

enum State { COUNTDOWN, GO, RACING, FINISHED }

const PLAYER_CAR_SCENE := preload("res://scenes/cars/player_car.tscn")
const CPU_CAR_SCENE := preload("res://scenes/cars/cpu_car.tscn")

const CAR_COLORS: Array[Dictionary] = [
	{"name": "Blue", "color": Color(0.2, 0.45, 1.0)},
	{"name": "Red", "color": Color(0.95, 0.25, 0.25)},
	{"name": "Yellow", "color": Color(0.98, 0.85, 0.2)},
	{"name": "Green", "color": Color(0.25, 0.85, 0.35)},
	{"name": "Purple", "color": Color(0.7, 0.35, 0.95)},
	{"name": "Orange", "color": Color(1.0, 0.55, 0.15)},
	{"name": "White", "color": Color(0.92, 0.92, 0.92)},
]

@onready var viewport1: SubViewport = $SplitScreen/ViewportContainer1/Viewport1
@onready var viewport2: SubViewport = $SplitScreen/ViewportContainer2/Viewport2
@onready var container2: SubViewportContainer = $SplitScreen/ViewportContainer2
@onready var world: Node2D = $SplitScreen/ViewportContainer1/Viewport1/World
@onready var cars_root: Node2D = $SplitScreen/ViewportContainer1/Viewport1/World/Cars
@onready var track: RaceTrack = $SplitScreen/ViewportContainer1/Viewport1/World/Track
@onready var camera1: Camera2D = $SplitScreen/ViewportContainer1/Viewport1/World/CameraPlayer1
@onready var camera2: Camera2D = $SplitScreen/ViewportContainer2/Viewport2/CameraPlayer2
@onready var hud: CanvasLayer = $HUD

var state: State = State.COUNTDOWN
var race_time: float = 0.0
var cars: Array[Car] = []
var rankings: Array[Car] = []

var _state_t: float = 3.0
var _curve: Curve2D
var _cp_count: int = 0
var _multiplayer: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = 10
	_multiplayer = GameManager.game_mode == GameManager.GameMode.LOCAL_MULTIPLAYER
	_curve = track.curve
	_cp_count = track.get_checkpoint_count()

	viewport2.world_2d = viewport1.world_2d
	viewport1.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container2.visible = _multiplayer
	if not _multiplayer:
		camera2.enabled = false
		viewport2.render_target_update_mode = SubViewport.UPDATE_DISABLED

	_spawn_cars()
	_connect_checkpoints()
	_setup_cameras()
	hud.bind(self)
	state = State.COUNTDOWN
	_state_t = 3.0


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	match state:
		State.COUNTDOWN:
			_state_t -= delta
			if _state_t > 0.0:
				hud.set_countdown(str(ceili(_state_t)))
			else:
				state = State.GO
				_state_t = 0.9
				_begin_racing()
		State.GO:
			_state_t -= delta
			hud.set_countdown("GO!")
			if _state_t <= 0.0:
				state = State.RACING
				hud.set_countdown("")
		State.RACING:
			race_time += delta
			var all_done := true
			for c in cars:
				if not c.is_finished:
					all_done = false
					break
			if all_done:
				_finish_race()
		State.FINISHED:
			pass


func _physics_process(_delta: float) -> void:
	if get_tree().paused:
		return
	if state == State.FINISHED:
		return
	_resolve_car_collisions()
	for c in cars:
		if not c.is_finished:
			c.path_offset = _curve.get_closest_offset(c.global_position)
	_update_ranking()


func _resolve_car_collisions() -> void:
	var min_dist := Car.COLLISION_RADIUS * 2.0
	for i in cars.size():
		var a := cars[i]
		if a.is_finished or a.frozen:
			continue
		for j in range(i + 1, cars.size()):
			var b := cars[j]
			if b.is_finished or b.frozen:
				continue
			var offset := b.global_position - a.global_position
			var dist := offset.length()
			if dist >= min_dist:
				continue
			var normal := offset.normalized() if dist > 0.001 else Vector2.RIGHT.rotated(a.rotation)
			var overlap := min_dist - dist
			a.global_position -= normal * overlap * 0.5
			b.global_position += normal * overlap * 0.5
			var approach := (b.velocity - a.velocity).dot(normal)
			if approach < 0.0:
				var impulse := -approach * 0.5
				a.apply_knockback(-normal * impulse)
				b.apply_knockback(normal * impulse)
				if -approach > 40.0:
					a.speed *= 0.97
					b.speed *= 0.97


func get_position_of(car: Car) -> int:
	var idx := rankings.find(car)
	return idx if idx >= 0 else 0


func _begin_racing() -> void:
	race_time = 0.0
	for c in cars:
		c.frozen = false
		c.lap_mark = 0.0


func _spawn_cars() -> void:
	var player_count := 2 if _multiplayer else 1
	var grid := track.get_grid_transforms(7)
	for i in 7:
		var is_player := i < player_count
		var car: Car = (PLAYER_CAR_SCENE if is_player else CPU_CAR_SCENE).instantiate()
		car.car_id = i
		var color_info: Dictionary = CAR_COLORS[i]
		car.color_name = color_info["name"]
		cars_root.add_child(car)
		car.position = grid[i].origin
		car.rotation = grid[i].get_rotation()
		car.set_color(color_info["color"])
		cars.append(car)

		var controller := car.get_node("Controller")
		if is_player:
			controller.input_prefix = "p1_" if i == 0 else "p2_"
		else:
			controller.setup(_curve, GameManager.cpu_params())


func _connect_checkpoints() -> void:
	var container := track.get_node("Checkpoints")
	for cp in container.get_children():
		cp.checkpoint_passed.connect(_on_checkpoint_passed)


func _setup_cameras() -> void:
	camera1.position_smoothing_enabled = true
	camera1.position_smoothing_speed = 7.0
	camera1.target = cars[0]
	camera2.position_smoothing_enabled = true
	camera2.position_smoothing_speed = 7.0
	if _multiplayer:
		camera2.target = cars[1]


func _on_checkpoint_passed(car: Car, index: int) -> void:
	if car.is_finished or state != State.RACING:
		return
	if index != car.next_checkpoint:
		return
	car.next_checkpoint = (index + 1) % _cp_count
	if index == 0:
		car.lap += 1
		car.lap_times.append(race_time - car.lap_mark)
		car.lap_mark = race_time
		if car.lap >= GameManager.lap_count:
			_mark_finished(car)


func _mark_finished(car: Car) -> void:
	car.mark_finished(race_time)


func _update_ranking() -> void:
	rankings = cars.duplicate()
	rankings.sort_custom(_car_rank)


func _car_rank(a: Car, b: Car) -> bool:
	if a.is_finished and b.is_finished:
		return a.finish_time < b.finish_time
	if a.is_finished != b.is_finished:
		return a.is_finished
	if a.lap != b.lap:
		return a.lap > b.lap
	var pa := a.next_checkpoint if a.next_checkpoint != 0 else _cp_count
	var pb := b.next_checkpoint if b.next_checkpoint != 0 else _cp_count
	if pa != pb:
		return pa > pb
	return a.path_offset > b.path_offset


func _finish_race() -> void:
	state = State.FINISHED
	hud.set_countdown("")
	_build_results()
	await get_tree().create_timer(2.5).timeout
	GameManager.go_results()


func _build_results() -> void:
	var results: Array[Dictionary] = []
	for i in rankings.size():
		var c := rankings[i]
		var player_index := -1
		if c.car_id == 0:
			player_index = 0
		elif _multiplayer and c.car_id == 1:
			player_index = 1
		results.append({
			"position": i + 1,
			"color_name": c.color_name,
			"player_index": player_index,
			"finish_time": c.finish_time,
			"lap_times": c.lap_times.duplicate(),
		})
	GameManager.race_results = results

	var best := -1.0
	for c in cars:
		for t in c.lap_times:
			if best < 0.0 or t < best:
				best = t
	GameManager.best_lap = best
