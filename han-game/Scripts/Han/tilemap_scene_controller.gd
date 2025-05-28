extends TileMap

class_name TilemapController

#Tilemap has to in Transform(0,0)

static var instance: TilemapController

@export var layers: Array[TileMapLayer]

const TABLE_PREFAB = preload("res://Prefabs/table_prefab.tscn")
const TILEMAP_CELL = preload("res://Prefabs/table_grid_cell.tscn")

@export var table_parent: Node2D
@export var cell_parent: Node2D

@onready var table_panel: Panel = $"../CanvasLayer/TablePanel"

@export var table_data: TableData

const pixelSize = 16

var active_cells: Array[CellController]

var preview_table: Node2D

func _ready():
	if instance == null:
		instance = self
		
	table_panel.connect("chose_table_signal", Callable(self, "_on_chose_table_signal"))


func _process(delta):
	if table_data == null:
		return
	
	var mouse_pos = get_local_mouse_position()
	var clicked_cell = local_to_map(mouse_pos)
	draw_table_preview(clicked_cell)
	
func _on_chose_table_signal(chose_table_data):
	table_data = chose_table_data
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_local_mouse_position()
			var clicked_cell = local_to_map(mouse_pos)
			
			#place table
			var cell_data = get_cell_data(clicked_cell)
			if cell_data.cell_state == LayerEnums.CellLayer.CELL:
				place_table(clicked_cell)
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			var mouse_pos = get_local_mouse_position()
			var clicked_cell = local_to_map(mouse_pos)
			var cell_data = get_cell_data(clicked_cell)
			if cell_data.cell_state == LayerEnums.CellLayer.TABLE :
				delete_table(clicked_cell)
				
func place_table(cell_pos: Vector2):
	if !can_place_table(cell_pos):
		return
	var table = TABLE_PREFAB.instantiate()
	table_parent.add_child(table)
	table.z_index = 50 + (cell_pos.y + 1) * 5
	table.attach_props(table_data.tableSprite)
	var pos = cell_pos * 16 + Vector2(8, 8)
	pos += Vector2((table_data.tableWidth - 1) * .5 * pixelSize, (table_data.tableHeight - 1) * .5 * pixelSize)
	table.position = pos
	generate_cells(cell_pos, table)
	
	update_whole_chairs()
	
func delete_table(cell_pos: Vector2):
	var table: TableController
	for cell in active_cells:
		if cell.order == cell_pos:
			table = cell.table
	
	var cells: Array[CellController] = table.cells
	for cell in cells:
		active_cells.erase(cell)
		cell.queue_free()
		
		layers[3].erase_cell(cell.order)
	
	update_whole_chairs()
	
	table.queue_free()
	
func can_place_table(cell_pos: Vector2) -> bool:
	for m in table_data.tableWidth:
		for n in table_data.tableHeight:
			if !can_place_cell(cell_pos + Vector2(m, n)):
				return false
	return true

func can_place_cell(cell_pos: Vector2) -> bool:
	var is_empty = true
	
	var tile_data = layers[2].get_cell_tile_data(cell_pos)
	if tile_data == null:
		is_empty = false
		
	tile_data = layers[3].get_cell_tile_data(cell_pos)
	if tile_data != null:
		is_empty = false
		
	return is_empty

func is_occupy_cell(cell_pos: Vector2) -> bool:
	var cell_data = get_cell_data(cell_pos)
	if cell_data.cell_state == LayerEnums.CellLayer.TABLE \
	or cell_data.collision_layer_state == LayerEnums.CollisionLayer.WALL \
	or cell_data.collision_layer_state == LayerEnums.CollisionLayer.POOL:
		return true
	return false

func get_cell_data(cell_pos: Vector2) -> CellData:
	var cell_data: CellData = CellData.new()
	
	var tile_pos_ground = layers[0].get_cell_tile_data(cell_pos)
	
	
	if tile_pos_ground == null:
		var tile_pos_collider = layers[1].get_cell_atlas_coords(cell_pos)
		match(tile_pos_collider):
			null:
				cell_data.collision_layer_state = LayerEnums.CollisionLayer.EMPTY
			Vector2i(1, 0):
				cell_data.collision_layer_state = LayerEnums.CollisionLayer.POOL
			Vector2i(2,0):
				cell_data.collision_layer_state = LayerEnums.CollisionLayer.WALL
	else:
		cell_data.collision_layer_state = LayerEnums.CollisionLayer.GROUND
			
	var tile_data_2 = layers[2].get_cell_tile_data(cell_pos)
	if tile_data_2 != null:
		var tile_data_3 = layers[3].get_cell_tile_data(cell_pos)
		if tile_data_3 != null:
			cell_data.cell_state = LayerEnums.CellLayer.TABLE
		else:
			cell_data.cell_state = LayerEnums.CellLayer.CELL
	else:
		cell_data.cell_state = LayerEnums.CellLayer.NOTCELL
		
	return cell_data

func generate_cells(cell_pos: Vector2, table: TableController):
	for m in table_data.tableWidth:
		for n in table_data.tableHeight:
			var cell = TILEMAP_CELL.instantiate()
			var pos = (cell_pos + Vector2(m, n)) * 16 + Vector2(8, 8)
			cell.position = pos
			cell_parent.add_child(cell)
			
			var new_cell_pos = cell_pos + Vector2(m, n)
			layers[3].set_cell(new_cell_pos, 0, Vector2i(3, 0), 0)
			var a = layers[3].get_cell_tile_data(new_cell_pos)
			
			var cell_controller: CellController = cell
			cell_controller.init(new_cell_pos.x, new_cell_pos.y)
			cell_controller.table = table
			active_cells.append(cell_controller)
			table.cells.append(cell_controller)
			
func attach_occupant_chair(cell_pos: Vector2) -> Array[bool]:
	var occupancies: Array[bool]
	occupancies.append(is_occupy_cell(cell_pos + Vector2(0, -1))) #up
	occupancies.append(is_occupy_cell(cell_pos + Vector2(1, 0))) #right
	occupancies.append(is_occupy_cell(cell_pos + Vector2(0, 1))) #down
	occupancies.append(is_occupy_cell(cell_pos + Vector2(-1, 0))) #left
	return occupancies

func update_whole_chairs():
	for cell in active_cells:
		cell.show_proper_chairs(attach_occupant_chair(cell.order))
		
func draw_table_preview(cell_pos: Vector2):
	if can_place_table(cell_pos) == false :
		if preview_table != null:
			delete_table_preview(cell_pos)
		return
	
	if preview_table == null:
		preview_table = TABLE_PREFAB.instantiate()
		table_parent.add_child(preview_table)
		
	preview_table.z_index = 50
	preview_table.attach_props(table_data.tableSprite)
	var sprite2D: Sprite2D = preview_table.get_child(0)
	sprite2D.modulate.a = 0.5
		
	var pos = cell_pos * 16 + Vector2(8, 8)
	pos += Vector2((table_data.tableWidth - 1) * .5 * pixelSize, (table_data.tableHeight - 1) * .5 * pixelSize)
	preview_table.position = pos
	
	
func delete_table_preview(cell_pos: Vector2):
	if preview_table == null:
		return
	preview_table.queue_free()
	preview_table = null
