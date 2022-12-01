extends Control
var tree
var panel
var root
var conversations
var line_types

# Called when the node enters the scene tree for the first time.
func _ready():
	var base = $ColorRect/MarginContainer/HSplitContainer
	tree = base.get_node("Side/Tree")
	panel = base.get_node("Main/GraphEdit")
	
	line_types = {
		"default": {
			"text": "value",
			"speaker": "value",
			"animation": {"choice": ["value"]},
			"signals": ["value"],
			"Go to line": [{
				"line_id": "line",
				"condition_type": ["choice"],
			}]
		}
	}
	
	setup_tree()
	setup_main_panel()

#Sets up the main panel graph node and hooks up signals
func setup_main_panel():
	panel.connect("popup_request", panel_right_clicked)

func panel_right_clicked(position):
	var prompts = []
	var funcs = []
	for type in line_types.keys():
		prompts.append("Create " + type.capitalize())
		funcs.append(create_node.bind(position, type))
	
	create_popup(prompts, funcs)

func create_node(position, type):
	var node = GraphNode.new()
	panel.add_child(node)
	
	node.set_draggable(true)
	node.resizable = true
	node.show_close = true
	node.connect("close_request", create_popup.bind(
		["Delete", "Cancel"],
		[(func(node): node.free()).bind(node)],
	))
	node.position_offset = position
	
	var parameters = line_types[type]
	for param in parameters:
		pass

#Sets up the conversation tree and signals
func setup_tree():
	root = tree.create_item()
	root.set_text(0, "Conversations")
	
	tree.connect("item_mouse_selected", tree_clicked)
	tree.connect("empty_clicked", tree_clicked)
	#note: confusingly, "item_activated" is actually when the label is double clicked
	tree.connect("item_activated", rename_selected_conversation)
	tree.connect("item_edited", validate_item_edited)

#Generic function for creating a popup at the given location
func create_popup(items, funcs, x=null, y=null):
	if x == null or y == null:
		var pos = get_viewport().get_mouse_position()
		x = pos.x
		y = pos.y
	
	var popup = PopupMenu.new()
	add_child(popup)
	
	popup.visible = true
	popup.position.x = x
	popup.position.y = y
	
	for item in items:
		if item == "":
			popup.add_separator()
		else:
			popup.add_item(item)
	popup.reset_size()
	
	popup.connect("index_pressed", (func(index, funcs): 
		if index < len(funcs) and funcs[index] != null:
			funcs[index].call()
		).bind(funcs)
	)

### Tree Signals
func tree_clicked(pos, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		create_popup(
			["Create New", "Rename", "Delete", "", "Cancel"],
			[create_conversation, rename_selected_conversation, delete_selected_conversation],
			pos.x, pos.y,
		)

###Conversations
func create_conversation():
	var convo = tree.create_item(root)
	convo.set_editable(0, true)
	convo.set_text(0, "new")
	tree.scroll_to_item(convo, true)
	tree.set_selected(convo, 0)
	
	#We defer the call as the position of the TreeItem has not been updated yet
	tree.call_deferred("edit_selected")
	convo.call_deferred("set_editable", 0, false)

#Ensures no empty strings
func validate_item_edited():
	var item = tree.get_edited()
	var text = item.get_text(0)
	if text == "":
		item.set_text(0, "unnamed")

#Renames the selected TreeItem
func rename_selected_conversation():
	var selected = tree.get_selected()
	selected.set_editable(0, true)
	tree.edit_selected()
	selected.set_editable(0, false)

#Deletes the selected TreeItem
func delete_selected_conversation():
	var selected = tree.get_selected()
	if selected != null and selected != root:
		selected.free()
