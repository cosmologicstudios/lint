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

func _init(base, path, lint_values, conversation_data):
	base_singleton = base
	panel_path = path
	values = lint_values
	lines = {}
	conversations = conversation_data
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
			"name": conversation_name,
			"lines": {}
		}
	conversation = conversations[conversation_name]
	print("Selected conversation: " + conversation_name)
	
	#Create conversation widgets
	var line_names = conversation["lines"].keys()
	for i in len(line_names):
		var id = line_names[i]
		var line = conversation["lines"][id]
		
		var sep = 50
		var x_pos = sep + ((i % 2) * (NODE_WIDTH + sep))
		var y_pos = sep + (floor(i / 2) * (NODE_HEIGHT + sep))
		
		if i % 2 == 1:
			y_pos = y_pos + sep
		
		create_line_node(Vector2(x_pos, y_pos), line["type"], line, id)

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
		funcs.append(create_line_node.bind(pos, type))
	
	prompts.append("")
	prompts.append("Cancel")
	base_singleton.create_popup(prompts, funcs)

#Create a node in the panel
func create_line_node(pos, type, line=null, id=null):
	if id == null:
		id = str(randi())
	
	var keys = lines.keys()
	while id in keys:
		id = str(randi())
	
	var str_identifier = get_identifier()
	lines[id] = str_identifier
	
	if(line == null):
		line = {
			"type": type, 
			"data": { "value": null } 
		}
		conversation["lines"][id] = line
	
	var graph_node = GraphNode.new()
	graph_edit.add_child(graph_node)
	
	graph_node.set_draggable(true)
	graph_node.resizable = true
	graph_node.show_close = true
	
	graph_node.connect("close_request", base_singleton.create_popup.bind(
		["Delete", "Cancel"],
		[delete_node.bind(graph_node, id)],
	))
	graph_node.position_offset = pos
	graph_node.set_size(Vector2(NODE_WIDTH, NODE_HEIGHT))
	
	graph_node.title = str_identifier + " | " + type + " | id: " + id
	
	var type_data = values.get_line_types()[type]
	LintWidget.recurse_create_widgets(graph_node, line["data"], type_data, "", lines, conversation)
	print("Created new " + type + " line with ID: " + id)
	
#Deletes a node
func delete_node(node, id):
	conversation["lines"].erase(id)
	lines.erase(id)
	node.free()
	print("Deleted line: " + id)
