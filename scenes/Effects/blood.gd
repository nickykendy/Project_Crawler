extends Sprite2D

var current_tile := Vector2i(0, 0)

func _ready():
	var i = randi() % 10
	var _x = i * 32 + 480
	region_rect = Rect2(_x, 1632, 32, 32)


func initialize():
	position = current_tile * Game.TILESIZE + Vector2i(Game.TILESIZE/2, Game.TILESIZE/2)
