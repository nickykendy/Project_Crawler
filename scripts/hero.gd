extends Unit
class_name Hero


var is_hero_turn := true
var fov_range := 6


func _ready():
	_initialization()


func act(dx:int, dy:int) -> void:
	var tile_map :TileMap = get_parent().get_node("TileMap")
	if tile_map == null: return
	var world = get_parent()
	if world == null: return
	
	var _x := current_tile.x + dx
	var _y := current_tile.y + dy
	
	var dest := Vector2i(_x, _y)
	var tile := tile_map.get_cell_atlas_coords(1, dest)
	var is_open_door := false
	var is_wait_range_hit := false
	
	# 尝试移动时，遇敌发起攻击
	if tile == Vector2i(-1, -1):
		var blocked = false
		if !world.monsters.is_empty():
			for mon in world.monsters:
				var mon_pos = mon.current_tile
				if mon_pos == dest:
					# TODO 敌人受击逻辑
					
					if mon.dead:
						world.monsters.erase(mon)
					blocked = true
					break
					
		if !blocked:
			current_tile = dest
	# 尝试打开门
	elif tile == Game.TILE_DOOR:
		tile_map.set_cell(0, dest, 0, Game.TILE_FLOOR)
		is_open_door = true
	
	try_act.emit(dest, is_open_door)
	position = current_tile * Game.TILESIZE
	
	if !is_wait_range_hit:
		acted.emit()
	
	is_hero_turn = false
