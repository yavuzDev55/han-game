extends Node2D

class_name CellController

var order: Vector2

@export var chairControllers: Array[ChairController]
var chairSprites: Array[Sprite2D] = []

@export var table: TableController =  null

func _ready():
	for chair in chairControllers:
		var sprite = chair.get_child(0) as Sprite2D
		chairSprites.append(sprite)
		
	EditSortingOrderOfChairs()

#Attaching cell pos
func init(x_pos: int, y_pos: int):
	self.order = Vector2(x_pos, y_pos)
	
func EditSortingOrderOfChairs():
	if(table == null): return
	chairControllers[0].z_index = table.z_index - 1; #top
	chairControllers[1].z_index = table.z_index - 1; #right
	chairControllers[2].z_index = table.z_index + 2; #down
	chairControllers[3].z_index = table.z_index - 1; #left
	
	pass	

func show_proper_chairs(occupancies: Array[bool]):
	var i = 0
	for chairSprite in chairSprites:
		chairSprite.visible = !occupancies[i]
		i += 1
	i = 0
	for chairController in chairControllers:
		chairController.set_process(!occupancies[i]) 
		i += 1
		
	EditSortingOrderOfChairs()
