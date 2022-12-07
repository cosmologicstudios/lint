class_name LintPanel

const NODE_WIDTH = 700
const NODE_HEIGHT = 500
var graph_edit = null
var panel_path
var base_singleton

const identifiers = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var identifier
var values
var lines
var conversations
var conversation
var current_conversation_name
var project_data

func _init(base, path, lint_values, conversation_data, project):
	base_singleton = base
	panel_path = path
	values = lint_values
	lines = {}
	conversations = conversation_data
	project_data = project
	print("Panel initialised.")

func get_identifier():
	var letters = len(identifiers)
	var reps = floor(identifier/letters)
	var id = identifiers[identifier % letters]
	for i in reps:
		id += id
	
	identifier += 1
	return id

func clear_conversation_widgets():
	lines.clear()
	
	if graph_edit != null:
		graph_edit.free()
	graph_edit = GraphEdit.new()
	graph_edit.connect("popup_request", panel_right_clicked)
	
	panel_path.add_child(graph_edit)

#Sets the conversation with the given name
func set_conversation(conversation_name):
	identifier = 0
	
	clear_conversation_widgets()
	current_conversation_name = conversation_name
	if conversation_name not in conversations:
		conversations[conversation_name] = {
			"lines": {}
		}
	conversation = conversations[conversation_name]
	print("Selected conversation: " + conversation_name)
	
	var line_names = conversation["lines"].keys()
	var total = len(line_names)
	var str_identifiers = []
	for i in total:
		str_identifiers.append(register_line(line_names[i]))
	
	#Create conversation widgets
	for i in total:
		var id = line_names[i]
		var line = conversation["lines"][id]
		var data = project_data["lines"][id]
		create_line_node(Vector2(data["x"], data["y"]), line["type"], line, id, str_identifiers[i])

#Right click in panel to create context menu to create new node
func panel_right_clicked(pos):
	#Account for the panel's scroll position
	pos.x += graph_edit.scroll_offset.x
	pos.y += graph_edit.scroll_offset.y
	
	var prompts = []
	var funcs = []
	var line_types = values.get_line_types()
	for type in line_types.keys():
		prompts.append("Create " + type.capitalize())
		funcs.append(add_line_node.bind(pos, type))
	
	prompts.append("")
	prompts.append("Cancel")
	base_singleton.create_popup(prompts, funcs)

func create_line_node(pos, type, line, id, str_identifier):
	var graph_node = GraphNode.new()
	graph_edit.add_child(graph_node)
	
	graph_node.set_draggable(true)
	graph_node.set_resizable(true)
	graph_node.set_show_close_button(true)
	
	graph_node.connect("resize_request", (
		func(min_size, graph_node): graph_node.set_size(min_size)
	).bind(graph_node))
	graph_node.connect("close_request", base_singleton.create_popup.bind(
		["Delete", "Cancel"],
		[delete_node.bind(graph_node, id)],
	))
	graph_node.connect("mouse_entered", (
		func(graph_edit, graph_node): graph_edit.set_selected(graph_node)
	).bind(graph_edit, graph_node))
	graph_node.connect("position_offset_changed", (
		func(graph_node, id): 
			var offset = graph_node.get_position_offset()
			project_data["lines"][id]["x"] = offset.x
			project_data["lines"][id]["y"] = offset.y
	).bind(graph_node, id))
	
	graph_node.set_position_offset(pos)
	graph_node.set_size(Vector2(NODE_WIDTH, NODE_HEIGHT))
	
	graph_node.set_title(str_identifier + " | " + type + " | id: " + id)
	
	var type_data = values.get_line_types()[type]
	LintWidget.recurse_create_widgets(graph_node, line["data"], type_data, "", lines, conversation)
	print("Created new " + type + " line with ID: " + id)

#Create a node in the panel
func add_line_node(pos, type):
	var id = str(randi())
	
	var keys = lines.keys()
	while id in keys:
		id = str(randi())
	
	var line = {
		"type": type, 
		"data": { LintWidget.VALUE : null } 
	}
	conversation["lines"][id] = line
	project_data["lines"][id] = { "x": pos.x, "y": pos.y }
	
	var str_identifier = register_line(id)
	create_line_node(pos, type, line, id, str_identifier)

func register_line(id):
	var str_identifier = get_identifier()
	lines[id] = str_identifier
	return str_identifier
	
#Deletes a node
func delete_node(node, id):
	conversation["lines"].erase(id)
	project_data["lines"].erase(id)
	lines.erase(id)
	node.free()
	print("Deleted line: " + id)
