extends Sprite2D


func _ready():
	var i = randi() % 10
	var _x = i * 32 + 480
	region_rect = Rect2(_x, 1632, 32, 32)
