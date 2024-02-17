extends Node


var dead := false
var cur_health :float: set = set_cur_health

@export var max_health :float = 0


func _ready():
	cur_health = max_health


func set_cur_health(value):
	cur_health = value


func hurt(dmg:int) -> void:
	var tween = create_tween()
	var par = get_parent()
	tween.tween_property(par, "self_modulate", Color.RED, 0.1)
	tween.tween_property(par, "self_modulate", Color.WHITE, 0.1)
	cur_health = cur_health - dmg
	print("DEBUG: ", get_parent().name, " is hit by ", dmg, ", remaining health is ", cur_health)
