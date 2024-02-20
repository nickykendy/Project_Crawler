extends Node

@export var min_dmg := 2.0
@export var max_dmg := 6.0
@export var skill_lv := 1
@export var range := 1.0

var target : Unit


func apply_skill_to_target(_target:Unit):
	var atk = randi_range(3, 6)
	_target.take_damage(atk)


func pos_to_map(_pos:Vector2) -> Vector2i:
	var _x = int(_pos.x / Game.TILESIZE)
	var _y = int(_pos.y / Game.TILESIZE)
	return Vector2i(_x, _y)
