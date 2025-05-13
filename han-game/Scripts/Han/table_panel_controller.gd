extends Panel

@export var tablePanels: Array[Node] = []

@export var tableDatas: Array[TableData] = []
@export var chosenTableData: TableData

func _ready():
	attach_panel_properties()
	chosenTableData = tableDatas[0]
	TableGridManager.instance.chosenTableData = chosenTableData


func attach_panel_properties():
	var index := 0
	for panel in tablePanels:
		var textureRect: TextureRect = panel.get_child(0) as TextureRect
		var panelName: Label = panel.get_child(1) as Label
		var button: Button = panel.get_child(3) as Button
		
		var tableData: TableData = tableDatas.get(index)
		
		textureRect.texture = tableData.tableSprite
		panelName.text = tableData.tableName
		button.pressed.connect(_on_button_pressed.bind(index))
		
		index += 1
	
func _on_button_pressed(button_id):
	chosenTableData = tableDatas[button_id]
	TableGridManager.instance.chosenTableData = chosenTableData
