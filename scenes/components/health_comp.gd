extends Node

var dead := false
var cur_health :float: set = set_cur_health

signal died

@export var max_health :float = 10.0


func set_cur_health(value):
	cur_health = value
	$HP.size.x = cur_health / max_health * 16.0


func take_damage(dmg:int) -> void:
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", Color.RED, 0.1)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.1)
	cur_health = cur_health - dmg
	if cur_health <= 0:
		dead = true
