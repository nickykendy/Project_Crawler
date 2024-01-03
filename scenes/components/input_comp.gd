extends Node

func _input(event):
	if !event.is_pressed():
		return
	
	var parent = get_parent()
	if parent and parent.has_node("move_comp"):
		var move_component = parent.get_node("move_comp")
		if event.is_action_pressed("left"):
			move_component.act(-1, 0)
		elif event.is_action_pressed("right"):
			move_component.act(1, 0)
		elif event.is_action_pressed("up"):
			move_component.act(0, -1)
		elif event.is_action_pressed("down"):
			move_component.act(0, 1)
		elif event.is_action_pressed("wait"):
			move_component.act(0, 0)
