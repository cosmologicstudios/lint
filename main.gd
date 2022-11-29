extends Control
var tree
var main
var root

# Called when the node enters the scene tree for the first time.
func _ready():
	var base = $ColorRect/MarginContainer/HSplitContainer
	
	#Tree
	tree = base.get_node("Side/Tree")
	
	root = tree.create_item()
	var child1 = tree.create_item(root)
	child1.set_text(0, "child1")
	var child2 = tree.create_item(root)
	child2.set_text(0, "child2")
	var subchild1 = tree.create_item(child1)
	subchild1.set_text(0, "Subchild1")
	#Main

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
