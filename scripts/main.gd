extends Node2D

@onready var tile_map := $TileMap

var astar :AStarGrid2D
var monsters :Array
var hero :Unit
var units :Array
var fov_map :MRPAS
var battle_log :String
var acted_monster_num := 0
var path_cache :Array

signal turn_switched
signal turn_end


func _ready():
	_generate_map()
	$InGameUI.update_turn_ui(Game.is_hero_turn)
	monsters = get_tree().get_nodes_in_group("monsters")
	hero = get_tree().get_first_node_in_group("heroes")
	units = get_tree().get_nodes_in_group("units")
	
	if hero:
		$InGameUI.update_hp_ui(hero.health_comp.cur_health, hero.health_comp.max_health)
	
	if !units.is_empty():
		for _u in units:
			_u.acted.connect(_on_unit_acted)
			_u.died.connect(_on_unit_died)
			var _pos = _u.current_tile
			Game.map[_pos].unit = _u
			
			if _u.is_in_group("heroes"):
				_u.acted.connect(_on_hero_acted)
				_u.died.connect(_on_hero_died)
				_u.hp_changed.connect(_on_hero_hp_changed)
			elif _u.is_in_group("monsters"):
				_u.acted.connect(_on_monster_acted)
				_u.died.connect(_on_monster_died)
				_u.selected.connect(_on_monster_selected)
				_u.unselected.connect(_on_monster_unselected)
	
	var map_pos = pos_to_map(get_global_mouse_position())
	Game.pointed_pos = map_pos
	Game.last_pointed_pos = map_pos
	
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
	if map_pos != Game.pointed_pos:
		Game.last_pointed_pos = Game.pointed_pos
		Game.pointed_pos = map_pos
		tile_map.set_cell(3, Game.pointed_pos, 0, Vector2i(15, 26))
		tile_map.set_cell(3, Game.last_pointed_pos, 0, Vector2i(0, 0))


func _input(event):
	if !event.is_pressed(): return
	if !hero: return
	
	if Game.is_hero_turn:
		if event.is_action_pressed("Skill1"):
			var skill = hero.get_node("regular_melee_skill")
			if skill.is_ready:
				Game.selected_skill = skill
				MouseCursor.switch_arrow(1)
			else:
				$InGameUI.update_head_tip_ui("Skill is not ready", 1.0)
		elif event.is_action_pressed("Skill2"):
			var skill = hero.get_node("fierce_melee_skill")
			if skill.is_ready:
				Game.selected_skill = skill
				MouseCursor.switch_arrow(1)
			else:
				$InGameUI.update_head_tip_ui("Skill is not ready", 1.0)
	
	if Game.selected_skill:
		if event.is_action_pressed("cancel"):
			Game.selected_skill = null
			MouseCursor.switch_arrow(0)
		elif event.is_action_pressed("confirm"):
			var map_pos = pos_to_map(get_global_mouse_position())
			var target = Game.map[map_pos].unit
			if target:
				if is_target_in_range(hero.current_tile, target.current_tile, Game.selected_skill.range):
					hero.cast_skill(Game.selected_skill, target)
					Game.selected_skill = null
					MouseCursor.switch_arrow(0)
				else:
					$InGameUI.update_head_tip_ui("Out of range", 2.0)
					
	if event.is_action_pressed("debug_on"):
		for _x in Game.level_size.x:
			for _y in Game.level_size.y:
				if Game.map[Vector2i(_x, _y)].debug != null:
					Game.map[Vector2i(_x, _y)].debug.queue_free()
				
				var _c
				if Game.map[Vector2i(_x, _y)].unit:
					_c = "1"
				else:
					_c = "0"
				Game.map[Vector2i(_x, _y)].debug = map_debug(Vector2i(_x, _y), _c)
	
	if event.is_action_pressed("debug_off"):
		for _x in Game.level_size.x:
			for _y in Game.level_size.y:
				if Game.map[Vector2i(_x, _y)].debug != null:
					Game.map[Vector2i(_x, _y)].debug.queue_free()


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
	turn_end.emit(_unit)


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
	else:
		_switch_turn(true)


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
	unit.set_outline_width(1.0)
	$InGameUI.update_monster_ui(unit.name, unit.health_comp.cur_health, unit.health_comp.max_health)


func _on_monster_unselected(unit:Unit) -> void:
	unit.set_outline_width(0.0)
	$InGameUI.update_monster_ui("", 0.0, 0.0)


func _switch_turn(_is_hero_turn:bool) ->void:
	if !hero: return
		
	$InGameUI.update_turn_ui(_is_hero_turn)
	if _is_hero_turn:
		Game.is_hero_turn = true
		
		var skills = hero.find_children("*_skill", "Node", false, true)
		if !skills.is_empty():
			for _s in skills:
				_s.cool_down()
	else:
		Game.is_hero_turn = false
		turn_switched.emit()


func _populate_mrpas() -> void:
	if Game.map.is_empty(): return
	
	fov_map = MRPAS.new(Game.level_size)
	for pos in Game.map:
		fov_map.set_transparent(pos, Game.map[pos].is_walkable)


func _compute_field_of_view() -> void:
	if !fov_map: return
	if !hero: return
	
	fov_map.clear_field_of_view()
	fov_map.compute_field_of_view(hero.current_tile, hero.fov_range)
	
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


func map_debug(_pos:Vector2i, _content) -> Label:
	var debug_text := Label.new()
	add_child(debug_text)
	debug_text.global_position = Vector2(_pos.x * Game.TILESIZE, _pos.y * Game.TILESIZE)
	debug_text.text = str(_content)
	return debug_text
