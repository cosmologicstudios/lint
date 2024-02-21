class_name LintPanel

const NODE_WIDTH = 1
const NODE_HEIGHT = 1

var values
var panel_node
var lines

const identifiers = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var identifier
var graph_edit = null
var conversation = null
var current_conversation_name = ""

func _init(node, lint_values):
	panel_node = node
	values = lint_values
	lines = {}
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
	graph_edit.connect("connection_request", connection_request)
	graph_edit.right_disconnects = true
	
	panel_node.add_child(graph_edit)

func connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	graph_edit.connect_node(from_node, from_port, to_node, to_port)

#Sets the conversation with the given name
func set_conversation(conversation_name):
	identifier = 0
	
	clear_conversation_widgets()
	current_conversation_name = conversation_name
	if conversation_name not in Global.project_data["conversations"]:
		Global.project_data["conversations"][conversation_name] = {}
	conversation = Global.project_data["conversations"][conversation_name]
	print("Selected conversation: " + conversation_name)
	
	var line_names = conversation.keys()
	var total = len(line_names)
	var str_identifiers = []
	for i in total:
		str_identifiers.append(register_line(line_names[i]))
	
	#Create conversation widgets
	for i in total:
		var id = line_names[i]
		var line = conversation[id]
		var data = Global.project_data["lines"][id]
		create_line_node(
			Vector2(data["x"], data["y"]), 
			line["type"], line, id, str_identifiers[i], 
			Vector2(data["width"], data["height"])
		)

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
	Global.create_popup(prompts, funcs)

func create_line_node(pos, type, line, id, str_identifier, size):
	Global.unsaved_changes = true
	
	var graph_node = GraphNode.new()
	graph_edit.add_child(graph_node)
	
	graph_node.set_draggable(true)
	graph_node.set_resizable(true)
	
	graph_node.connect("resize_request", (
		func(min_size, graph_node, id): 
			graph_node.set_size(min_size)
			Global.project_data["lines"][id]["width"] = min_size.x
			Global.project_data["lines"][id]["height"] = min_size.y
	).bind(graph_node, id))
	graph_node.connect("close_request", Global.create_popup.bind(
		["Delete", "Cancel"],
		[delete_node.bind(graph_node, id)],
	))
	graph_node.connect("mouse_entered", func(): graph_edit.set_selected(graph_node))
	graph_node.connect("position_offset_changed", (
		func(graph_node, id): 
			var offset = graph_node.get_position_offset()
			Global.project_data["lines"][id]["x"] = offset.x
			Global.project_data["lines"][id]["y"] = offset.y
	).bind(graph_node, id))
	
	graph_node.set_position_offset(pos)
	if size == null:
		graph_node.set_size(Vector2(NODE_WIDTH, NODE_HEIGHT))
		
		#Pop in the defaults
		Global.project_data["lines"][id]["x"] = pos.x
		Global.project_data["lines"][id]["y"] = pos.y
		Global.project_data["lines"][id]["width"] = NODE_WIDTH
		Global.project_data["lines"][id]["height"] = NODE_HEIGHT
	else:
		graph_node.set_size(size)
	
	graph_node.set_title(str_identifier + " | " + type + " | id: " + id)
	
	match type:
		"default":
			graph_node.set_slot(0, true, 0, Color.AZURE, true, 0, Color.AZURE)
		"choice":
			graph_node.set_slot(0, true, 0, Color.AZURE, false, 0, Color.AZURE)
		_:
			print("Unknown type: " + type)
	
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
		"data": { LintWidget.BOX : null } 
	}
	conversation[id] = line
	Global.project_data["lines"][id] = { "x": pos.x, "y": pos.y }
	
	var str_identifier = register_line(id)
	create_line_node(pos, type, line, id, str_identifier, null)

func register_line(id):
	var str_identifier = get_identifier()
	lines[id] = str_identifier
	return str_identifier
	
#Deletes a node
func delete_node(node, id):
	Global.unsaved_changes = true
	
	conversation.erase(id)
	Global.project_data["lines"].erase(id)
	lines.erase(id)
	node.free()
	print("Deleted line: " + id)
