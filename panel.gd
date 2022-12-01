class_name LintPanel

var panel
var base
var values

func _init(base_node, node, lint_values):
	base = base_node
	panel = node
	values = lint_values
	panel.connect("popup_request", panel_right_clicked)
	print("Panel initialised.")

#Right click in panel to create context menu to create new node
func panel_right_clicked(pos):
	var prompts = []
	var funcs = []
	var line_types = values.get_line_types()
	for type in line_types.keys():
		prompts.append("Create " + type.capitalize())
		funcs.append(create_node.bind(pos, type))
	
	prompts.append("")
	prompts.append("Cancel")
	base.create_popup(prompts, funcs)

#Create a node in the panel
func create_node(pos, type):
	print("Created new " + type + " line.")
	
	var node = GraphNode.new()
	panel.add_child(node)
	
	node.set_draggable(true)
	node.resizable = true
	node.show_close = true
	node.connect("close_request", base.create_popup.bind(
		["Delete", "Cancel"],
		[delete_node.bind(node)],
	))
	node.position_offset = pos
	node.set_size(Vector2(500, 500))
	
	var line_types = values.get_line_types()
	LintWidget.recurse_create_widgets(node, line_types[type], type)

func delete_node(node):
	node.free()
	print("Deleted line.")
