extends Node2D

class_name TableController

@export var cells: Array[CellController]
#@export var customers

var table_sprite: Sprite2D

func attach_props(sprite: Texture2D):
	table_sprite = get_child(0)
	table_sprite.texture = sprite
