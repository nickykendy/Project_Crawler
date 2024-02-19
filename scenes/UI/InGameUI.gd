extends CanvasLayer


@onready var hp_label := $Control/Botton/Label2
@onready var turn_label := $Control/Head/Label


func update_hp_ui(cur:float, max:float) -> void:
	hp_label.text = str(cur) + "/" + str(max)


func update_turn_ui(is_my_turn:bool) -> void:
	if is_my_turn:
		turn_label.text = "My Turn"
		turn_label.self_modulate = Color.GREEN
	else:
		turn_label.text = "Enemy Turn"
		turn_label.self_modulate = Color.RED
