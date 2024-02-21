extends Node2D

@onready var tile_map := $TileMap

var astar :AStarGrid2D
var monsters :Array
var heroes :Array
var units :Array
var fov_map :MRPAS
var battle_log :String
var acted_monster_num := 0
var path_cache :Array


func _ready():
	_generate_map()
	$InGameUI.update_turn_ui(Game.is_hero_turn)
	monsters = get_tree().get_nodes_in_group("monsters")
	heroes = get_tree().get_nodes_in_group("heroes")
	units = get_tree().get_nodes_in_group("units")
	
	if !heroes.is_empty():
		for _h in heroes:
			_h.acted.connect(_on_hero_acted)
			_h.died.connect(_on_hero_died)
			_h.hp_changed.connect(_on_hero_hp_changed)
			var _pos = _h.current_tile
			Game.map[_pos].unit = _h
		
		var player = heroes[0]
		$InGameUI.update_hp_ui(player.health_comp.cur_health, player.health_comp.max_health)
	
	if !monsters.is_empty():
		for _m in monsters:
			_m.acted.connect(_on_monster_acted)
			_m.died.connect(_on_monster_died)
			_m.selected.connect(_on_monster_selected)
			var _pos = _m.current_tile
			Game.map[_pos].unit = _m
	
	if !units.is_empty():
		for _u in units:
			_u.acted.connect(_on_unit_acted)
			_u.died.connect(_on_unit_died)
	
	_populate_mrpas()
	_compute_field_of_view()
	_update_monsters_visibility()


func _generate_map() -> void:
	astar = AStarGrid2D.new()
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.region = Rect2i(0, 0, Game.level_size.x, Game.level_size.y)
	astar.cell_size = Vector2(Game.TILESIZE, Game.TILESIZE)
	astar.update()
	
	for _x in Game.level_size.x:
		for _y in Game.level_size.y:
			var _pos = Vector2i(_x, _y)
			var _tile = tile_map.get_cell_atlas_coords(1, _pos, false)
			#map_debug(_pos, _x)
			
			Game.map[_pos] = Cell.new()
			if _tile == Vector2i(-1, -1): # 没有障碍时
				Game.map[_pos].is_walkable = true
				astar.set_point_solid(_pos, false)
			else:
				Game.map[_pos].is_walkable = false
				astar.set_point_solid(_pos, true)


func _process(_delta):
	var map_pos = pos_to_map(get_global_mouse_position())
	for _m in monsters:
		if _m.current_tile == map_pos:
			_m.set_outline_width(1.0)
			$InGameUI.update_monster_ui(_m.name, _m.health_comp.cur_health, _m.health_comp.max_health)
			break
		else:
			_m.set_outline_width(0.0)
			$InGameUI.update_monster_ui("", 0.0, 0.0)


func _input(event):
	if !event.is_pressed():
		return
	
	if heroes.is_empty():
		return
	
	if Game.is_hero_turn:
		if event.is_action_pressed("Skill1"):
			Game.selected_skill = heroes[0].get_node("regular_melee_comp")
			MouseCursor.switch_arrow(1)
	
	if Game.selected_skill:
		if event.is_action_pressed("cancel"):
			Game.selected_skill = null
			MouseCursor.switch_arrow(0)
		elif event.is_action_pressed("confirm"):
			var map_pos = pos_to_map(get_global_mouse_position())
			for _m in monsters:
				if _m.current_tile == map_pos:
					if is_target_in_range(heroes[0].current_tile, _m.current_tile, Game.selected_skill.range):
						heroes[0].cast_skill(Game.selected_skill, _m)
						Game.selected_skill = null
						MouseCursor.switch_arrow(0)
						break
					else:
						$InGameUI.update_head_tip_ui("Out of range", 3.0)


func is_target_in_range(my_loc:Vector2i, target_loc:Vector2i, range:float) -> bool:
	var dis_vec := target_loc - my_loc
	var length_x := dis_vec.x
	var length_y := dis_vec.y
	var dis :float
	
	if length_x == 0:
		dis = length_y
	elif length_y == 0:
		dis = length_x
	elif length_x > length_y:
		var temp := length_x - length_y
		dis = temp + length_y * 1.5
	elif length_y > length_x:
		var temp := length_y - length_x
		dis = temp + length_x * 1.5
	else:
		dis = length_x * 1.5
	
	if floor(dis) <= range:
		return true
	else:
		return false


func _on_unit_acted(_unit:Unit) -> void:
	#if _unit.is_hero:
		#_compute_field_of_view()
		#_update_monsters_visibility()
	pass


func _on_unit_died(_unit) -> void:
	pass


func _on_hero_acted(hero:Unit) -> void:
	#if _is_open_door:
		#astar.set_point_solid(_coord, false)
		#map[_coord].is_walkable = true
		#fov_map.set_transparent(_coord, true)
	_switch_turn(false)
	_compute_field_of_view()
	_update_monsters_visibility()
	
	acted_monster_num = 0
	if !monsters.is_empty():
		for mon in monsters:
			mon.act(astar)


func _on_hero_died(unit:Unit) -> void:
	pass


func _on_hero_hp_changed(cur:float, max:float) -> void:
	$InGameUI.update_hp_ui(cur, max)


func _on_monster_acted(monster:Unit) -> void:
	var is_monster_turn = true
	acted_monster_num += 1
	if !monsters.is_empty():
		if acted_monster_num >= monsters.size():
			is_monster_turn = false
	else:
		is_monster_turn = false
	
	if !is_monster_turn:
		_switch_turn(true)


func _on_monster_died(unit:Unit) -> void:
	var i = monsters.find(unit)
	monsters.remove_at(i)


func _on_monster_selected(unit:Unit) -> void:
	pass


func _switch_turn(_is_hero_turn:bool) ->void:
	$InGameUI.update_turn_ui(_is_hero_turn)
	if _is_hero_turn:
		Game.is_hero_turn = true
	else:
		Game.is_hero_turn = false


func _populate_mrpas() -> void:
	if Game.map.is_empty(): return
	
	fov_map = MRPAS.new(Game.level_size)
	for pos in Game.map:
		fov_map.set_transparent(pos, Game.map[pos].is_walkable)


func _compute_field_of_view() -> void:
	if !fov_map: return
	if heroes.is_empty(): return
	
	fov_map.clear_field_of_view()
	fov_map.compute_field_of_view(heroes[0].current_tile, heroes[0].fov_range)
	
	for pos in Game.map:
		if fov_map.is_in_view(pos):
			Game.map[pos].is_in_view = true
			Game.map[pos].is_explored = true
		else:
			Game.map[pos].is_in_view = false
		
		update_fog(pos, Game.map[pos].is_in_view, Game.map[pos].is_explored)


func _update_monsters_visibility() -> void:
	if !monsters.is_empty():
		for mon in monsters:
			var pos = mon.current_tile
			if !Game.map[pos].is_in_view:
				mon.visible = false
			else:
				mon.visible = true
	
	var bloods = get_tree().get_nodes_in_group("Blood")
	if !bloods.is_empty():
		for _b in bloods:
			var pos = _b.current_tile
			if !Game.map[pos].is_in_view:
				_b.visible = false
			else:
				_b.visible = true


func update_fog(pos:Vector2i, is_in_view:bool, is_explored) -> void:
	if is_in_view:
		tile_map.set_cell(2, pos, 1, Game.TILE_NONE)
	elif is_explored:
		tile_map.set_cell(2, pos, 1, Game.TILE_FOG)
	else:
		tile_map.set_cell(2, pos, 1, Game.TILE_DARK)


func get_tile_center(tile_x:int, tile_y:int) -> Vector2:
	return Vector2((tile_x + 0.5) * Game.TILESIZE, (tile_y + 0.5) * Game.TILESIZE)


func pos_to_map(_pos:Vector2) -> Vector2i:
	var _x = int(_pos.x / Game.TILESIZE)
	var _y = int(_pos.y / Game.TILESIZE)
	return Vector2i(_x, _y)


func is_in_bound(_pos:Vector2) -> bool:
	var _in_bound := false
	if _pos.x >= 0 and _pos.x <= Game.level_size.x and _pos.y >= 0 and _pos.y <= Game.level_size.y:
		_in_bound = true
	return _in_bound


func map_debug(_pos, _content):
	var debug_text := Label.new()
	add_child(debug_text)
	debug_text.global_position = Vector2(_pos.x * Game.TILESIZE, _pos.y * Game.TILESIZE)
	debug_text.text = str(_content)
