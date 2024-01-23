extends Node

@onready var tile_map := $TileMap

var astar :AStarGrid2D
var monsters :Array
var heroes :Array
var units :Array
var alert_monsters :Array
var fov_map :MRPAS
var battle_log :String
var acted_monster_num := 0
var path_cache :Array


func _ready():
	_generate_map()
	monsters = get_tree().get_nodes_in_group("monsters")
	heroes = get_tree().get_nodes_in_group("heroes")
	units = get_tree().get_nodes_in_group("units")
	
	if !heroes.is_empty():
		for _h in heroes:
			_h.acted.connect(_on_hero_acted)
			_h.died.connect(_on_hero_died)
			var _pos = _h.current_tile
			Game.map[_pos].unit = _h
	
	if !monsters.is_empty():
		for _m in monsters:
			_m.acted.connect(_on_monster_acted)
			_m.died.connect(_on_monster_died)
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
			Game.map[_pos] = Cell.new()
			if _tile == Vector2i(-1, -1): # 没有障碍时
				Game.map[_pos].is_walkable = true
				astar.set_point_solid(_pos, false)


func _process(_delta):
	pass


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


func _switch_turn(_is_hero_turn:bool) ->void:
	if heroes.is_empty(): return
	
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
	if monsters.is_empty(): return
	
	for mon in monsters:
		var pos = mon.current_tile
		if !Game.map[pos].is_in_view:
			mon.visible = false
		else:
			mon.visible = true


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
