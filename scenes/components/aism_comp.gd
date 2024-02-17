extends Node
class_name AISM

var current_state := "idle"
var last_state : String
var next_state : String
var pathfinding : AStarGrid2D
var AI : Unit

enum DIR {RIGHT, UP, LEFT, DOWN}


func _ready():
	AI = get_parent()


func change_state(new_state:String) -> void:
	pass


func execute() -> void:
	pass
