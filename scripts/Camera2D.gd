extends Camera2D


var heroes :Array

func _ready():
	heroes = get_tree().get_nodes_in_group("heroes")


func _process(delta):
	if heroes.is_empty():
		return
	
	var player = heroes[0]
	position = player.position + Vector2(16, 16)
