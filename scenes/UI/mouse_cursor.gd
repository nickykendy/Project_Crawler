extends Node


var arrow1 = load("res://assets/ui/arrow.png")
var arrow2 = load("res://assets/ui/arrow2.png")


func _ready():
	Input.set_custom_mouse_cursor(arrow1)


func switch_arrow(_type:int) -> void:
	match _type:
		0:
			Input.set_custom_mouse_cursor(arrow1)
		1:
			Input.set_custom_mouse_cursor(arrow2)
