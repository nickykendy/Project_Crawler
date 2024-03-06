extends Unit


@export var fov_range := 3


func act(dx:int, dy:int) -> void:
	var _x := current_tile.x + dx
	var _y := current_tile.y + dy
	
	var tween = get_tree().create_tween().bind_node(self)
	
	# check target location has no obstacles in the layer "obstacle" on tile map, 
	var dest := Vector2i(_x, _y)
	var tile := tile_map.get_cell_atlas_coords(1, dest)
	
	if tile == Vector2i(-1, -1):
		var blocked = false
		if Game.map[dest].unit:
			blocked = true
		
		if !blocked:
			Game.map[current_tile].unit = null
			current_tile = dest
			Game.map[current_tile].unit = self
	
	tween.tween_property(self, "position", Vector2(current_tile * Game.TILESIZE), 0.2)
	await get_tree().create_timer(0.2).timeout
	acted.emit(self)


func cast_skill(skill:Node, target:Unit) -> void:
	var tween = get_tree().create_tween().bind_node(self)
	var _dir = (target.current_tile - current_tile).sign()
	var origin_pos = global_position
	tween.tween_property(self, "position", origin_pos + Vector2(_dir * 5), 0.1)
	tween.tween_property(self, "position", origin_pos, 0.1)
	skill.apply_skill_to_target(target)
	await get_tree().create_timer(0.2).timeout
	acted.emit(self)
