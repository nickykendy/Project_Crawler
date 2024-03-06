extends Node

@export var init_state :AISM
var states :Dictionary = {}
var current_state :AISM


func _ready():
	for child in get_children():
		if child is AISM:
			states[child.name.to_lower()] = child
			child.transitioned.connect(_on_child_transitioned)
	
	if init_state:
		init_state.enter()
		current_state = init_state


func _process(delta):
	if current_state:
		current_state.update(delta)


func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)


func _on_child_transitioned(state:AISM, new_state_name:String) -> void:
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
