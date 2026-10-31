extends Node2D


func _process(_delta):
	rotate( - get_parent().rotation)
