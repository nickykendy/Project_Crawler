extends Node2D


func show_alert():
	$Spr_alert.visible = true
	$Spr_doubt.visible = false


func show_doubt():
	$Spr_alert.visible = false
	$Spr_doubt.visible = true
