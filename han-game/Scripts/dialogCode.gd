extends Sprite2D

@onready var label = $"../Label"
@onready var button = $"../Button"
@onready var button_2 = $"../Button2"

var situation:int = 0

@export var character : int
var texts = load("res://scripts/texts.gd").new()
@onready var strings = texts.characters[character]


func _process(delta):
	label.text = strings[situation][0]
	button.text = strings[situation][1]
	button_2.text = strings[situation][2]

func _on_button_pressed():
	dialog(true)


func _on_button_2_pressed():
	dialog(false)


func dialog(option:bool):
	if option == true:
		situation = strings[situation][3]
	else:
		situation = strings[situation][4]
