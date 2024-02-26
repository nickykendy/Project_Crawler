extends Node

@export var min_dmg := 3.0
@export var max_dmg := 7.0
@export var cd := 3
@export var skill_lv := 1
@export var range := 1.0

var is_ready := true
var left_turns := 0

@onready var bleed := preload("res://scenes/buffs/bleed_buff.tscn")



func apply_skill_to_target(_target:Unit) -> void:
	var atk = randi_range(min_dmg, max_dmg)
	_target.take_damage(self, atk)
	is_ready = false
	left_turns = cd
	
	var _b = bleed.instantiate()
	_target.add_child(_b)
	_b.set_target(_target)


func cool_down() -> void:
	left_turns -= 1
	left_turns = clamp(left_turns, 0, cd)
	if left_turns == 0:
		is_ready = true
