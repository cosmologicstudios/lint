extends Control

var base
var values
var tree
var panel
var conversations

func _ready():
	var container = $ColorRect/MarginContainer/HSplitContainer
	var tree_path = container.get_node("Side/Tree")
	var panel_path = container.get_node("Main/GraphEdit")
	var root_node = get_tree().root
	
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\nLint is powering up...")
	conversations = Serialisation.load_data()
	
	base = Base.new(root_node)
	values = LintObject.new()
	tree = LintTree.new(base, tree_path, conversations)
	panel = LintPanel.new(base, panel_path, values, conversations)
	print("Power up complete. Hello, Lint!\n")
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>\n")
	
	randomize()
