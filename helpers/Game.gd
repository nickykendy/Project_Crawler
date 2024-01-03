extends Node


const TILESIZE := 32
const TILE_NONE := Vector2i(0, 0)
const TILE_FLOOR := Vector2i(1, 0)
const TILE_WALL := Vector2i(2, 0)
const TILE_STAIRS := Vector2i(1, 1)
const TILE_DOOR := Vector2i(0, 1)
const TILE_FOG := Vector2i(1, 0)
const TILE_DARK := Vector2i(2, 0)

var level_size := Vector2i(50, 50)

func _ready():
	DisplayServer.window_set_size(Vector2(1280, 800), 0)
	randomize()
