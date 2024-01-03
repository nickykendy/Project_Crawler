extends Node


var current_tile := Vector2i(0, 0)
var tile_map :TileMap


func initialize(_tilemap):
	tile_map = _tilemap
	var _pos = get_parent().position
	current_tile = pos_to_map(_pos)


func act(dx:int, dy:int) -> void:
	var _x := current_tile.x + dx
	var _y := current_tile.y + dy
	
	var dest := Vector2i(_x, _y)
	var tile := tile_map.get_cell_atlas_coords(1, dest)
	var is_open_door := false
	
	# 尝试移动时，遇敌发起攻击
	if tile == Vector2i(-1, -1):
		var blocked = false
		# TODO 处理dest位置有没有敌人
		if !blocked:
			current_tile = dest
	# 尝试打开门
	elif tile == Game.TILE_DOOR:
		tile_map.set_cell(0, dest, 0, Game.TILE_FLOOR)
		is_open_door = true
	
	get_parent().current_tile = current_tile
	get_parent().try_act.emit(dest, is_open_door)
	get_parent().position = current_tile * Game.TILESIZE
	get_parent().acted.emit()


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
