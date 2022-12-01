extends Control

var base
var values
var tree
var panel

func _ready():
	var container = $ColorRect/MarginContainer/HSplitContainer
	var tree_path = container.get_node("Side/Tree")
	var panel_path = container.get_node("Main/GraphEdit")
	var root_node = get_tree().root
	
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\nLint is powering up...")
	base = Base.new(root_node)
	values = LintObject.new()
	tree = LintTree.new(base, tree_path)
	panel = LintPanel.new(base, panel_path, values)
	print("Power up complete. Hello, Lint!\n")
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>\n")
