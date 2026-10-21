extends Camera2D

@export var target: Car


func _process(_delta: float) -> void:
	if target != null:
		global_position = target.global_position
