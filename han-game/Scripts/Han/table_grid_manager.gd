extends Node2D

class_name TableGridManager

#Singleton Instance
static var instance: TableGridManager

#@export var isActive: bool = false

const pixel: int = 16

#Grid
@export var width: int = 10
@export var height: int = 10
@export var cellPrefab: PackedScene
var grid: Array = []

var pixelSize: int = 16

#Table and 
var chosenTableData: TableData
var previewTable: TableController

#Layers
@export var defaultLayer: int
@export var gridLayer: int
@export var tableLayer: int

@export var tablePrefab: PackedScene

func _ready():
	if instance == null:
		instance = self
		
	generate_grid()

func generate_grid():
	grid.clear()
	for x in range(width):
		var row = []
		for y in range(height):
			var cell = cellPrefab.instantiate()
			cell.z_index = -10
			cell.position = Vector2(x * pixelSize, y * pixelSize)
			add_child(cell)
			var cell_script = cell
			cell_script.init(x,y)
			row.append(cell_script)
		grid.append(row)

	
func on_grid_cell_clicked(order_x: int, order_y: int):
	var order: Vector2 = Vector2(order_x, order_y)
	var size: Vector2 = Vector2(chosenTableData.tableWidth, chosenTableData.tableHeight)
	if can_place_table(order, size):
		place_table_at(order, size)
		
func can_place_table(order: Vector2, size: Vector2) -> bool:
	for dx in range(size.x):
		for dy in range(size.y):
			var checkX: int = order.x + dx
			var checkY: int = order.y + dy
			
			if checkX >= width || checkY >=height:
				return false
				
			if grid[checkX][checkY].isOccupied:
				return false
				
	return true
	
func place_table_at(order: Vector2, size: Vector2):
	var cellsUnderTable: Array[TableGridCell]
	for dx in range(size.x):
		for dy in range(size.y):
			var px: int = order.x + dx
			var py: int = order.y+ dy
			
			var cell = grid[px][py]
			cellsUnderTable.append(cell)
			
	var worldPos: Vector2 = Vector2((order.x * pixelSize) + ((size.x - 1) * .5 * pixelSize), (order.y * pixelSize)  + ((size.y - 1) * .5 * pixelSize))
	
	var table =  tablePrefab.instantiate()
	add_child(table)
	table.z_index = 5 * (order.y + 1)
	table.position = worldPos
	var tableController: TableController = table as TableController
	tableController.attach_props(chosenTableData.tableSprite)
	table.cells = cellsUnderTable
	for cell in cellsUnderTable:
		cell.table = table
		cell.isOccupied = true
		cell.HideChair()
		
	choose_proper_chairs()
	
func delete_table(table: TableController):
	var cells: Array[TableGridCell] = table.cells
	for cell in cells:
		cell.isOccupied = false
		cell.table = null
		cell.HideChair()
	
	table.queue_free()
	
	choose_proper_chairs()

func draw_table_preview(order: Vector2):
	var size: Vector2 = Vector2(chosenTableData.tableWidth, chosenTableData.tableHeight)
	var worldPos: Vector2 = Vector2((order.x * pixelSize) + ((size.x - 1) * .5 * pixelSize), (order.y * pixelSize)  + ((size.y - 1) * .5 * pixelSize))
	if can_place_table(order, size) == false:
		delete_table_preview(order)
		return
	
	if previewTable == null:
		previewTable = tablePrefab.instantiate()
		add_child(previewTable)
		previewTable.z_index = 5 * (order.y + 1)
		previewTable.attach_props(chosenTableData.tableSprite)
		var sprite2D: Sprite2D = previewTable.get_child(0)
		sprite2D.modulate.a = 0.5
	
	previewTable.cells.clear()
	previewTable.cells.append(grid[order.x][order.y])
	previewTable.position = worldPos
	
func delete_table_preview(order: Vector2):
	if previewTable == null:
		return
	if previewTable.cells.has(grid[order.x][order.y]):
		previewTable.queue_free()
	
func choose_proper_chairs():
	for dx in range(width):
		for dy in range(height):
			var grid: TableGridCell = grid[dx][dy] 
			grid.show_proper_chairs(get_neighbour_occupancy(Vector2(dx, dy)))
	
func get_neighbour_occupancy(order: Vector2) -> Array[bool]:
	var occupancies: Array[bool]
	occupancies.append(order.y - 1 >= 0 && is_cell_occupied(order.x, order.y - 1)) #Up
	occupancies.append(order.x + 1 < width && is_cell_occupied(order.x + 1, order.y)) #Right
	occupancies.append(order.y + 1 < height && is_cell_occupied(order.x, order.y + 1)) #Down
	occupancies.append(order.x - 1 >= 0 && is_cell_occupied(order.x - 1, order.y)) #Left
	
	return occupancies
	
func is_cell_occupied(x: int, y: int) -> bool:
	if x < 0 || x >= width || y < 0 || y >= height:
		return false
	return grid[x][y].isOccupied
