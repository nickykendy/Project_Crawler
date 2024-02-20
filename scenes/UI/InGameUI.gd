extends CanvasLayer


@onready var hero_hp := $Control/BottomLeft/Label2
@onready var turn := $Control/TopLeft/Label
@onready var monster_name := $Control/TopRight/Name/Label2
@onready var monster_hp := $Control/TopRight/HP/Label2
@onready var head_tip := $Control/Head/Label


func update_hp_ui(cur:float, max:float) -> void:
	hero_hp.text = str(cur) + "/" + str(max)


func update_head_tip_ui(content:String, time:float) -> void:
	head_tip.visible = true
	head_tip.text = content
	await get_tree().create_timer(time).timeout
	head_tip.visible = false


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
