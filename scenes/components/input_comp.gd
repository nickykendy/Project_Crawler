extends Node

func _input(event):
	if !event.is_pressed():
		return
	
	var parent = get_parent()
	if parent:
		if event.is_action_pressed("left"):
			parent.act(-1, 0)
		elif event.is_action_pressed("right"):
			parent.act(1, 0)
		elif event.is_action_pressed("up"):
			parent.act(0, -1)
		elif event.is_action_pressed("down"):
			parent.act(0, 1)
		elif event.is_action_pressed("wait"):
			parent.act(0, 0)
