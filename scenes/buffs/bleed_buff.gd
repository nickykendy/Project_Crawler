extends Node
class_name BleedBuff

@export var dmg := 1.0
@export var lasts := 3

var left_turns := 3


func apply_buff_to_target(_target:Unit) -> void:
	var atk = dmg
	_target.take_damage(atk)
	left_turns -= 1
	
	if left_turns == 0:
		queue_free()
