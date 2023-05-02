class_name LintTree

var tree
var root
var panel
var current_conversation = ""
var _rename = null

func _init(tree_node, lint_panel):
	panel = lint_panel
	
	tree = Tree.new()
	tree.set_allow_rmb_select(true)
	tree.set_column_titles_visible(true)
	tree.set_column_title(0, "Conversations")
	tree.set_drop_mode_flags(Tree.DROP_MODE_ON_ITEM)
	tree.set_hide_root(true)
	
	tree_node.add_child(tree)
	root = tree.create_item()
	
	tree.connect("gui_input", _gui_input)
	#note: confusingly, "item_activated" is actually when the label is double clicked
	tree.connect("item_edited", validate_item_edited)
	tree.connect("cell_selected", item_selected)
	
	for conversation in Global.project_data["conversations"].keys():
		create_conversation(conversation)
	
	print("Tree intialised.")

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			Global.create_popup(
				["Create New", "Rename", "Delete", "", "Cancel"],
				[create_conversation, rename_selected_conversation, delete_selected_conversation],
			)

### Tree Signals
func item_selected():
	var selected = tree.get_selected()
	var selected_name = selected.get_text(0)
	if selected_name != current_conversation and selected != root:
		print("current: " + current_conversation + " , setting: " + selected_name)
		current_conversation = selected_name
		panel.set_conversation(current_conversation)

###Conversations
func create_conversation(conversation=""):
	Global.unsaved_changes = true
	
	var convo = tree.create_item(root)
	
	#If this is a 'new' conversation, we want to edit the name
	if conversation == "":
		tree.set_selected(convo, 0)
		convo.set_editable(0, true)
		convo.set_text(0, generate_name("new"))
		
		#We defer the call as the position of the TreeItem has not been updated yet
		tree.call_deferred("edit_selected")
		convo.call_deferred("set_editable", 0, false)
		print("Creating conversation...")
	else: 
		convo.set_text(0, conversation)
		print("Added conversation '" + conversation + "' to tree.")

#Returns true if the tree contains the given item string
func tree_has_item(item) -> bool:
	for child in root.get_children():
		if child.get_text(0) == item:
			return true
	return false

#Adds numbers to string to make it unique
func generate_name(text) -> String:
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
	elif _rename in Global.project_data["conversations"]:
		var old = Global.project_data["conversations"][_rename] 
		Global.project_data["conversations"][text] = old
		Global.project_data["conversations"].erase(_rename)
	
	Global.unsaved_changes = true
	
	_rename = null
	print("Named conversation: " + text)
	panel.set_conversation(text)

#Renames the selected TreeItem
func rename_selected_conversation():
	var selected = tree.get_selected()
	if selected != null:
		_rename = selected.get_text(0)
		
		selected.set_editable(0, true)
		tree.edit_selected()
		selected.set_editable(0, false)
		
		print("Renaming conversation...")

#Deletes the selected TreeItem
func delete_selected_conversation():
	var selected = tree.get_selected()
	if selected != null and selected != root:
		Global.unsaved_changes = true
		
		var text = selected.get_text(0)
		selected.free()
		for line in Global.project_data["conversations"][text]:
			Global.project_data["lines"].erase(line)
		Global.project_data["conversations"].erase(text)
		print("Deleted conversation: " + text)
		
		panel.clear_conversation_widgets()
