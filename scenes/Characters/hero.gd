extends Unit


var fov_range := 3
var is_hero_turn := true


func act(dx:int, dy:int) -> void:
	var _x := current_tile.x + dx
	var _y := current_tile.y + dy
	
	var dest := Vector2i(_x, _y)
	var tile := tile_map.get_cell_atlas_coords(1, dest)
	
	if tile == Vector2i(-1, -1):
		var blocked = false
		var monsters = get_tree().get_nodes_in_group("monsters")
		for _m in monsters:
			if _m.current_tile == dest:
				blocked = true
				_m.take_damage(1.0)
		#var _unit = Game.map[dest].unit
		#if _unit:
			#blocked = true
			#_unit.take_damge(1.0)
			
		if !blocked:
			Game.map[current_tile].unit = null
			current_tile = dest
			Game.map[current_tile].unit = self
	
	position = current_tile * Game.TILESIZE
	acted.emit(current_tile)
