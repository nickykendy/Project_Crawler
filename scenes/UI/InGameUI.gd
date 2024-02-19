extends CanvasLayer


@onready var hero_hp := $Control/Botton/Label2
@onready var turn := $Control/Head/Label
@onready var monster_name := $Control/TopRight/Name/Label2
@onready var monster_hp := $Control/TopRight/HP/Label2


func update_hp_ui(cur:float, max:float) -> void:
	hero_hp.text = str(cur) + "/" + str(max)


func update_monster_ui(name:String, cur:float, max:float) -> void:
	if monster_name != null:
		monster_name.visible = true
		monster_name.text = name
		monster_hp.visible = true
		monster_hp.text = str(cur) + "/" + str(max)
	else:
		monster_name.visible = false
		monster_hp.visible = false


func update_turn_ui(is_my_turn:bool) -> void:
	if is_my_turn:
		turn.text = "My Turn"
		turn.self_modulate = Color.GREEN
	else:
		turn.text = "Enemy Turn"
		turn.self_modulate = Color.RED
