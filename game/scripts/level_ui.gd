class_name HUDController
extends CanvasLayer

@export var life_container: BoxContainer
@export var ring_container: BoxContainer
@export var score_label: Label

var life_nodes: Array[Node] = []
var ring_nodes: Array[Node] = []

var life_img = preload("res://scenes/UI/life_img.tscn")
var ring_img = preload("res://scenes/UI/ring_img.tscn")


func update_score(new_score: int):

	score_label.text = "%07d" % new_score

func set_lives(num: int):

	life_nodes.clear()
	for n in life_container.get_children():
		life_container.remove_child(n)

	for i in num:
		add_life()

func add_life():
	var new_life = life_img.instantiate()
	life_nodes.append(new_life)
	life_container.add_child(new_life)

func remove_life():

	var last_life = life_nodes.pop_back()
	life_container.remove_child(last_life)


func set_rings(num: int):

	ring_nodes.clear()
	for n in ring_container.get_children():
		ring_container.remove_child(n)

	for i in num:
		add_ring()

func add_ring():
	var new_ring = ring_img.instantiate()
	ring_nodes.append(new_ring)
	ring_container.add_child(new_ring)

func remove_ring():
	var last_ring = ring_nodes.pop_back()
	ring_container.remove_child(last_ring)
