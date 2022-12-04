class_name LintTree

const ROOT_TEXT = " Conversations "
var tree
var root
var base
var panel
var conversations
var current_conversation = ""
var _rename = null

func _init(base_node, node, conversation_data, main_panel):
	base = base_node
	tree = node
	conversations = conversation_data
	panel = main_panel

	root = tree.create_item()
	root.set_text(0, ROOT_TEXT)
	
	tree.connect("item_mouse_selected", tree_clicked)
	tree.connect("empty_clicked", tree_clicked)
	#note: confusingly, "item_activated" is actually when the label is double clicked
	tree.connect("item_activated", rename_selected_conversation)
	tree.connect("item_edited", validate_item_edited)
	tree.connect("cell_selected", item_selected)
	
	print("Tree intialised.")

### Tree Signals
func item_selected():
	var selected = tree.get_selected()
	var selected_name = selected.get_text(0)
	if selected_name != current_conversation and selected_name != ROOT_TEXT:
		print("current: " + current_conversation + " , setting: " + selected_name)
		current_conversation = selected_name
		panel.set_conversation(current_conversation)

func tree_clicked(pos, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		base.create_popup(
			["Create New", "Rename", "Delete", "", "Cancel"],
			[create_conversation, rename_selected_conversation, delete_selected_conversation],
			pos.x, pos.y,
		)

###Conversations
func create_conversation():
	var convo = tree.create_item(root)
	convo.set_editable(0, true)
	convo.set_text(0, generate_name("new"))
	tree.set_selected(convo, 0)
	
	#We defer the call as the position of the TreeItem has not been updated yet
	tree.call_deferred("edit_selected")
	convo.call_deferred("set_editable", 0, false)
	print("Creating conversation...")

func tree_has_item(item) -> bool:
	for child in root.get_children():
		if child.get_text(0) == item:
			return true
	return false

func generate_name(text):
	while tree_has_item(text):
		text += "1"
	return text

#Ensures no empty strings
func validate_item_edited():
	var item = tree.get_edited()
	var text = item.get_text(0)
	if text == "":
		text = generate_name(_rename)
		item.set_text(0, text)
	elif _rename in conversations:
		var old = conversations[_rename] 
		conversations[text] = old
		conversations.erase(_rename)
	
	_rename = null
	print("Named conversation: " + text)
	panel.set_conversation(text)

#Renames the selected TreeItem
func rename_selected_conversation():
	var selected = tree.get_selected()
	_rename = selected.get_text(0)
	
	selected.set_editable(0, true)
	tree.edit_selected()
	selected.set_editable(0, false)
	
	print("Renaming conversation...")

#Deletes the selected TreeItem
func delete_selected_conversation():
	var selected = tree.get_selected()
	if selected != null and selected != root:
		var text = selected.get_text(0)
		selected.free()
		print("Deleted conversation: " + text)
