class_name LintPanel

var panel
var base
var values
var lines
var conversations

func _init(base_node, node, lint_values, conversation_data):
	base = base_node
	panel = node
	values = lint_values
	lines = []
	conversations = conversation_data
	
	panel.connect("popup_request", panel_right_clicked)
	print("Panel initialised.")

#Right click in panel to create context menu to create new node
func panel_right_clicked(pos):
	var prompts = []
	var funcs = []
	var line_types = values.get_line_types()
	for type in line_types.keys():
		prompts.append("Create " + type.capitalize())
		funcs.append(create_line_node.bind(pos, type))
	
	prompts.append("")
	prompts.append("Cancel")
	base.create_popup(prompts, funcs)

#Create a node in the panel
func create_line_node(pos, type):
	var id = str(randi())
	lines.append(id)
	print("Created new " + type + " line with ID: " + id)
	
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
	node.set_size(Vector2(700, 500))
	node.title = type + " | id: " + id
	
	var type_data = values.get_line_types()[type]
	
	LintWidget.recurse_create_widgets(node, conversations, type_data, "", lines)

func delete_node(node):
	node.free()
	print("Deleted line.")
