extends CanvasLayer


@onready var hp_label := $Control/HBoxContainer/Label2


func update_hp_ui(cur:float, max:float) -> void:
	hp_label.text = str(cur) + "/" + str(max)
