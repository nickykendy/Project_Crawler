extends Node2D


var fov_range := 3
var current_tile :Vector2i
var is_hero_turn := true

@onready var move_component := $move_comp

signal acted
signal try_act

func _ready():
	var _tilemap = get_parent().get_node("TileMap")
	move_component.initialize(_tilemap)
	current_tile = move_component.current_tile
