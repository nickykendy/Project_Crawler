extends Unit


var fov_range := 6
var is_monster_turn = true


func act(pathfinding:AStarGrid2D) -> void:
	var heroes = get_tree().get_nodes_in_group("heroes")
	if heroes.is_empty(): return
	
	var player_ref = heroes[0]
	var distance = (player_ref.current_tile - current_tile).length()
	var path = pathfinding.get_id_path(current_tile, player_ref.current_tile)
	
	var tween = get_tree().create_tween().bind_node(self)
	
	if path:
		assert(path.size() > 1)
		var dest := Vector2i(path[1].x, path[1].y)
		var tile := tile_map.get_cell_atlas_coords(1, dest)
		
		if tile == Vector2i(-1, -1):
			var blocked = false
			if player_ref.current_tile == dest:
				blocked = true
				var _dir = dest - current_tile
				tween.tween_property(self, "position", global_position + Vector2(_dir * 10), 0.05)
				player_ref.take_damage(1.0)
				
			if !blocked:
				pathfinding.set_point_solid(current_tile, false)
				current_tile = dest
				pathfinding.set_point_solid(current_tile, true)
	
	tween.tween_property(self, "position", Vector2(current_tile * Game.TILESIZE), 0.2)
	await get_tree().create_timer(0.2).timeout
	acted.emit(self)
