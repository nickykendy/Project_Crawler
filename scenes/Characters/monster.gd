extends Unit


var fov_range := 6
var is_monster_turn = true


func act(pathfinding:AStarGrid2D) -> void:
	var heroes = get_tree().get_nodes_in_group("heroes")
	if heroes.is_empty(): return
	
	var player_ref = heroes[0]
	var distance = (player_ref.current_tile - current_tile).length()
	var path = pathfinding.get_id_path(current_tile, player_ref.current_tile)
	
	if path:
		assert(path.size() > 1)
		var dest := Vector2i(path[1].x, path[1].y)
		var tile := tile_map.get_cell_atlas_coords(1, dest)
		
		if tile == Vector2i(-1, -1):
			var blocked = false
			if player_ref.current_tile == dest:
				blocked = true
				player_ref.take_damage(1.0)
			#var _unit = Game.map[dest].unit
			#if _unit:
				#blocked = true
				##_unit.take_damge(1.0)
				
			if !blocked:
				Game.map[current_tile].unit = null
				current_tile = dest
				Game.map[current_tile].unit = self
	
	position = current_tile * Game.TILESIZE
	acted.emit()
