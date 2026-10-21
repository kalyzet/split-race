class_name RaceTrack
extends Node2D

const CheckpointScript := preload("res://scripts/race/checkpoint.gd")

@export var centerline: PackedVector2Array
@export var point_widths: PackedFloat32Array
@export var checkpoint_offsets: PackedFloat32Array = PackedFloat32Array([0.0, 0.2, 0.4, 0.6, 0.8])
@export var wall_thickness: float = 28.0
@export var visual_step: float = 12.0
@export var wall_step: float = 36.0

var curve := Curve2D.new()


func _ready() -> void:
	_build_curve()
	_build_road_visual()
	_build_walls()
	_build_checkpoints()
	_build_start_line()


func get_grid_transforms(count: int) -> Array[Transform2D]:
	var result: Array[Transform2D] = []
	var total_len := curve.get_baked_length()
	for i in count:
		var row := i / 2
		var lateral := 48.0 if i % 2 == 0 else -48.0
		var back := 55.0 + float(row) * 95.0
		var o := fposmod(total_len - back, total_len)
		var pos := curve.sample_baked(o)
		var tan := _tangent_at(o)
		var nrm := tan.orthogonal()
		result.append(Transform2D(tan.angle(), pos + nrm * lateral))
	return result


func get_checkpoint_count() -> int:
	return checkpoint_offsets.size()


func _build_curve() -> void:
	curve.clear_points()
	var n := centerline.size()
	var tangents: Array[Vector2] = []
	for i in n:
		var prev := centerline[(i - 1 + n) % n]
		var next := centerline[(i + 1) % n]
		tangents.append((next - prev).normalized())
	for i in n:
		var p := centerline[i]
		var tangent := tangents[i]
		var handle_len := centerline[(i + 1) % n].distance_to(centerline[(i - 1 + n) % n]) * 0.22
		curve.add_point(p, -tangent * handle_len, tangent * handle_len)
	# Curve2D in Godot 4.7 has no `closed` flag; append first point to close the loop.
	var handle_len_first := centerline[1].distance_to(centerline[n - 1]) * 0.22
	curve.add_point(centerline[0], -tangents[0] * handle_len_first, tangents[0] * handle_len_first)


func _tangent_at(offset: float) -> Vector2:
	var total_len := curve.get_baked_length()
	var a := curve.sample_baked(fposmod(offset - 4.0, total_len))
	var b := curve.sample_baked(fposmod(offset + 4.0, total_len))
	var t := (b - a).normalized()
	return t if t.length_squared() > 0.001 else Vector2.RIGHT


func width_at_offset(offset: float) -> float:
	var total_len := curve.get_baked_length()
	var t := fposmod(offset / total_len, 1.0)
	var f := t * float(point_widths.size())
	var i := int(f) % point_widths.size()
	var j := (i + 1) % point_widths.size()
	return lerpf(point_widths[i], point_widths[j], f - float(int(f)))


func _sample_road() -> Dictionary:
	var total_len := curve.get_baked_length()
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var o := 0.0
	while o <= total_len:
		var p := curve.sample_baked(o)
		var t := _tangent_at(o)
		var n := t.orthogonal()
		var w := width_at_offset(o) * 0.5
		left.append(p + n * w)
		right.append(p - n * w)
		o += visual_step
	return {"left": left, "right": right, "length": total_len}


func _build_road_visual() -> void:
	var data := _sample_road()
	var left: PackedVector2Array = data["left"]
	var right: PackedVector2Array = data["right"]

	var ribbon := PackedVector2Array()
	ribbon.append_array(left)
	var reversed_right := PackedVector2Array()
	for i in range(right.size() - 1, -1, -1):
		reversed_right.append(right[i])
	ribbon.append_array(reversed_right)

	var road := Polygon2D.new()
	road.name = "Road"
	road.polygon = ribbon
	road.color = Color(0.23, 0.23, 0.26)
	add_child(road)

	var edge_left := Line2D.new()
	edge_left.name = "EdgeLeft"
	edge_left.points = left
	edge_left.width = 5.0
	edge_left.default_color = Color(0.92, 0.92, 0.92)
	add_child(edge_left)

	var edge_right := Line2D.new()
	edge_right.name = "EdgeRight"
	edge_right.points = right
	edge_right.width = 5.0
	edge_right.default_color = Color(0.92, 0.92, 0.92)
	add_child(edge_right)


func _build_walls() -> void:
	var boundaries := StaticBody2D.new()
	boundaries.name = "Boundaries"
	boundaries.collision_layer = 1
	boundaries.collision_mask = 0
	add_child(boundaries)

	var total_len := curve.get_baked_length()
	var sample_positions := PackedFloat32Array()
	var o := 0.0
	while o <= total_len:
		sample_positions.append(o)
		o += wall_step
	if sample_positions[sample_positions.size() - 1] < total_len - 1.0:
		sample_positions.append(total_len)

	for side_index in 2:
		var side: float = 1.0 if side_index == 0 else -1.0
		for i in sample_positions.size():
			var o0: float = sample_positions[i]
			var o1: float = sample_positions[(i + 1) % sample_positions.size()]
			var p0 := curve.sample_baked(o0)
			var p1 := curve.sample_baked(fposmod(o1, total_len))
			var t := _tangent_at(o0)
			var n := t.orthogonal() * side
			var w0 := width_at_offset(o0) * 0.5
			var mid := ((p0 + n * (w0 + wall_thickness * 0.5)) + (p1 + n * (w0 + wall_thickness * 0.5))) * 0.5
			var seg_len := p0.distance_to(p1) + 4.0

			var shape_node := CollisionShape2D.new()
			var box := RectangleShape2D.new()
			box.size = Vector2(seg_len, wall_thickness)
			shape_node.shape = box
			shape_node.position = mid
			shape_node.rotation = t.angle()
			boundaries.add_child(shape_node)


func _build_checkpoints() -> void:
	var container := Node2D.new()
	container.name = "Checkpoints"
	add_child(container)

	var total_len := curve.get_baked_length()
	for i in checkpoint_offsets.size():
		var o := checkpoint_offsets[i] * total_len
		var pos := curve.sample_baked(o)
		var t := _tangent_at(o)
		var w := width_at_offset(o) + 80.0

		var area := Area2D.new()
		area.name = "Checkpoint%d" % i
		area.set_script(CheckpointScript)
		area.collision_layer = 0
		area.collision_mask = 2
		area.checkpoint_index = i
		area.position = pos
		area.rotation = t.angle()

		var shape_node := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(46.0, w)
		shape_node.shape = rect
		area.add_child(shape_node)

		var visual := Polygon2D.new()
		var hw := w * 0.5
		visual.polygon = PackedVector2Array([
			Vector2(-3, -hw), Vector2(3, -hw), Vector2(3, hw), Vector2(-3, hw),
		])
		visual.color = Color(1.0, 1.0, 1.0, 0.35)
		area.add_child(visual)

		container.add_child(area)


func _build_start_line() -> void:
	var pos := curve.sample_baked(0.0)
	var t := _tangent_at(0.0)
	var n := t.orthogonal()
	var w := width_at_offset(0.0) * 0.5
	var line := Polygon2D.new()
	line.name = "StartLine"
	line.polygon = PackedVector2Array([
		pos + t * 8.0 - n * w,
		pos - t * 8.0 - n * w,
		pos - t * 8.0 + n * w,
		pos + t * 8.0 + n * w,
	])
	line.color = Color(0.95, 0.95, 0.95, 0.9)
	add_child(line)
