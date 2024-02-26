extends Node

@export var min_dmg := 2.0
@export var max_dmg := 6.0
@export var cd := 1
@export var skill_lv := 1
@export var range := 1.0

var is_ready := true
var left_turns := 0



func apply_skill_to_target(_target:Unit) -> void:
	var atk = randi_range(min_dmg, max_dmg)
	_target.take_damage(self, atk)
	is_ready = false
	left_turns = cd


func cool_down() -> void:
	left_turns -= 1
	left_turns = clamp(left_turns, 0, cd)
	if left_turns == 0:
		is_ready = true
