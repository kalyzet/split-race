extends Area2D

signal checkpoint_passed(car: Car, index: int)

@export var checkpoint_index: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Car:
		checkpoint_passed.emit(body as Car, checkpoint_index)
