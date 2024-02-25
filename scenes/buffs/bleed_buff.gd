extends Node
class_name BleedBuff

@export var dmg := 1.0
@export var lasts := 3

var left_turns := 3
var target: Unit


func _ready():
	var world_nodes = get_tree().get_nodes_in_group("world")
	if !world_nodes.is_empty():
		var world = world_nodes[0]
		world.turn_switched.connect(_on_turn_switched)


func apply_buff_to_target(_target:Unit) -> void:
	var atk = dmg
	_target.take_damage(atk)
	left_turns -= 1
	
	if left_turns == 0:
		queue_free()


func set_target(value:Unit) -> void:
	target = value


func _on_turn_switched() -> void:
	if target:
		apply_buff_to_target(target)
		
	print("turn switched!!!")
