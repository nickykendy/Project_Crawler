extends Node2D
class_name Unit

var current_tile :Vector2i
var dead := false
var cur_health :float: set = set_cur_health

@export var is_melee :bool = true
@export var max_health :float = 10.0
@export var attack :float = 3.0

signal dmg_taken
signal acted
signal try_act
signal died


func _initialization():
	current_tile = pos_to_map(position)


func pos_to_map(_pos:Vector2) -> Vector2i:
	var _x = int(_pos.x / Game.TILESIZE)
	var _y = int(_pos.y / Game.TILESIZE)
	return Vector2i(_x, _y)


func map_to_pos(_map:Vector2i) -> Vector2:
	var _x = _map.x * Game.TILESIZE
	var _y = _map.y * Game.TILESIZE
	return Vector2(_x, _y)


func is_in_bound(_pos:Vector2) -> bool:
	var _in_bound := false
	if _pos.x < 0 or _pos.x > Game.level_size.x or _pos.y < 0 or _pos.y > Game.level_size.y:
		_in_bound = true
	return _in_bound


func get_tile_center(tile_x:int, tile_y:int) -> Vector2:
	return Vector2((tile_x + 0.5) * Game.TILESIZE, (tile_y + 0.5) * Game.TILESIZE)


func take_damage(dmg:int) -> void:
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", Color.RED, 0.1)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.1)
	cur_health = cur_health - dmg
	if cur_health <= 0:
		dead = true


func set_cur_health(value):
	cur_health = value
	$HP.size.x = cur_health / max_health * 16.0
