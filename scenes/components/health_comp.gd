extends Node


var dead := false
var cur_health :float: set = set_cur_health

@export var max_health :float = 0


func _ready():
	cur_health = max_health


func set_cur_health(value):
	cur_health = value


func hurt(attacker, dmg:int) -> void:
	cur_health = cur_health - dmg
	print("DEBUG: ", get_parent().name, " is hit by ", attacker.name, ", with ", dmg, ", HP: ", cur_health)
