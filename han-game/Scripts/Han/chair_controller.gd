extends Node2D

class_name ChairController

@export var isOccupied: bool = false
#@export var customer: CustomerController
@export var dir: int #top-1 right-2 down-3 left-4

@export var customerPoint: Transform2D

func _process(_delta: float) -> void:
	pass
