extends Node2D
class_name Unit


@onready var blood = preload("res://scenes/Effects/blood.tscn")

@export var is_hero :bool = false

var current_tile := Vector2i(0, 0)
var tile_map :TileMap
var world :Node
var dead := false
var tag :String
var health_comp :Node

signal acted
signal died
signal hp_changed


func _ready():
	tile_map = get_parent().get_node("TileMap")
	world = get_parent()
	current_tile = pos_to_map(position)
	health_comp = get_node("health_comp")


func take_damage(value:float) -> void:
	if health_comp != null:
		if health_comp.cur_health - value > 0:
			health_comp.hurt(value)
			hp_changed.emit(health_comp.cur_health, health_comp.max_health)
		else:
			dead = true
			die_process()
	else:
		print("DEBUG health_comp missing, node name: ", name)


func die_process() -> void:
	var b = blood.instantiate()
	get_parent().add_child(b)
	get_parent().move_child(b, 1)
	b.current_tile = current_tile
	b.initialize()
	died.emit(self)
	queue_free()


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


func debug():
	print("my name: ", name)
