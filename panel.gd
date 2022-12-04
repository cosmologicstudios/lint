class_name LintPanel

const NODE_WIDTH = 700
const NODE_HEIGHT = 500
var graph_edit = null
var panel_path
var base_singleton

var values
var lines
var conversations
var conversation

func _init(base, path, lint_values, conversation_data):
	base_singleton = base
	panel_path = path
	values = lint_values
	lines = []
	conversations = conversation_data
	print("Panel initialised.")

func clear_conversation_widgets():
	#Wipe the current nodes
	lines.clear()
	
	if graph_edit != null:
		graph_edit.free()
	graph_edit = GraphEdit.new()
	graph_edit.connect("popup_request", panel_right_clicked)
	
	panel_path.add_child(graph_edit)

func set_conversation(conversation_name):
	clear_conversation_widgets()
	
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
		
		create_line_node(Vector2(x_pos, y_pos), line["type"], line)

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
	base_singleton.create_popup(prompts, funcs)

#Create a node in the panel
func create_line_node(pos, type, line=null):
	var id = str(randi())
	lines.append(id)
	
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
		[delete_node.bind(graph_node)],
	))
	graph_node.position_offset = pos
	graph_node.set_size(Vector2(NODE_WIDTH, NODE_HEIGHT))
	graph_node.title = type + " | id: " + id
	
	var type_data = values.get_line_types()[type]
	LintWidget.recurse_create_widgets(graph_node, line["data"], type_data, "", lines)
	print("Created new " + type + " line with ID: " + id)

func delete_node(node):
	node.free()
	print("Deleted line.")
