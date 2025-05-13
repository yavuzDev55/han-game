extends Node2D

class_name TableGridCell

var order_x: int
var order_y: int

@export var isOccupied: bool

@onready var tile_sprite: Sprite2D = $Sprite2D

@export var chairControllers: Array[ChairController]
var chairSprites: Array[Sprite2D] = []

@export var mouseIn: bool = false

@export var table: TableController =  null

func _ready():
	for chair in chairControllers:
		var sprite = chair.get_child(0) as Sprite2D
		chairSprites.append(sprite)
	
	HideChair()
	
	#initally hidden
	tile_sprite.visible = true

#Attaching cell pos
func init(x_pos: int, y_pos: int):
	self.order_x = x_pos
	self.order_y = y_pos
	
func EditSortingOrderOfChairs():
	if(table == null): return
	chairControllers[0].z_index = table.z_index - 1; #top
	chairControllers[1].z_index = table.z_index - 1; #right
	chairControllers[2].z_index = table.z_index + 2; #down
	chairControllers[3].z_index = table.z_index - 1; #left
	
	pass	

func HideChair():
	for controller in chairControllers:
		controller.set_process(false)
	
	for sprite in chairSprites:
		sprite.visible = false
		
func show_proper_chairs(occupancies: Array[bool]):
	if isOccupied == false:
		HideChair()
		return
	
	var i = 0
	for chairSprite in chairSprites:
		chairSprite.visible = !occupancies[i]
		i += 1
	i = 0
	for chairController in chairControllers:
		chairController.set_process(!occupancies[i]) 
		i += 1
		
	EditSortingOrderOfChairs()
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:	
		if mouseIn:
			TableGridManager.instance.on_grid_cell_clicked(order_x, order_y)
			
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if mouseIn && isOccupied:
			TableGridManager.instance.delete_table(table)
		
func _on_area_2d_mouse_entered() -> void:
	mouseIn = true
	TableGridManager.instance.draw_table_preview(Vector2(order_x, order_y))


func _on_area_2d_mouse_exited() -> void:
	mouseIn = false
	TableGridManager.instance.delete_table_preview(Vector2(order_x, order_y))
