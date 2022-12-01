class_name LintTree

var tree
var root
var base

func _init(base_node, node):
	base = base_node
	tree = node

	root = tree.create_item()
	root.set_text(0, "Conversations")
	
	tree.connect("item_mouse_selected", tree_clicked)
	tree.connect("empty_clicked", tree_clicked)
	#note: confusingly, "item_activated" is actually when the label is double clicked
	tree.connect("item_activated", rename_selected_conversation)
	tree.connect("item_edited", validate_item_edited)
	
	print("Tree intialised.")

### Tree Signals
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
	convo.set_text(0, "new")
	tree.set_selected(convo, 0)
	
	#We defer the call as the position of the TreeItem has not been updated yet
	tree.call_deferred("edit_selected")
	convo.call_deferred("set_editable", 0, false)
	print("Creating conversation...")

#Ensures no empty strings
func validate_item_edited():
	var item = tree.get_edited()
	var text = item.get_text(0)
	if text == "":
		text = "unnamed"
		item.set_text(0, text)
	
	print("Named conversation: " + text)

#Renames the selected TreeItem
func rename_selected_conversation():
	var selected = tree.get_selected()
	selected.set_editable(0, true)
	tree.edit_selected()
	selected.set_editable(0, false)
	
	print("Renaming conversation...")

#Deletes the selected TreeItem
func delete_selected_conversation():
	var selected = tree.get_selected()
	if selected != null and selected != root:
		selected.free()
		print("Deleted conversation: " + selected.get_text(0))
