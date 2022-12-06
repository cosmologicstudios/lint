extends Control

var export_path = null
var save_path = null
var root_node
var conversations = {}

var base
var values
var panel
var tree

enum FilterType {
	Lint,
	Json
}

enum MenuIndex {
	Open,
	Save,
	SaveAs,
	Export
}

func _ready():
	randomize()
	
	root_node = get_tree().root
	
	var menu_bar = $MenuBar/File
	menu_bar.add_item("Open")
	menu_bar.add_item("Save")
	menu_bar.add_item("Save As")
	menu_bar.add_item("Export")
	menu_bar.connect("index_pressed", menu_select)
	
	base = Base.new(root_node)
	values = LintObject.new()
	setup_lint()

func setup_lint():
	var container = $ColorRect/MarginContainer/HSplitContainer
	var tree_path = container.get_node("Side")
	var panel_path = container.get_node("Main")
	
	#If we have already initialised, we need to delete old data
	var panel_children = panel_path.get_children()
	for child in panel_children:
		panel_path.remove_child(child)
		print("Removed panel.")
	var tree_children = tree_path.get_children()
	for child in tree_children:
		tree_path.remove_child(child)
		print("Removed tree.")
	
	#If we are refreshing, the old references will be dropped
	panel = LintPanel.new(base, panel_path, values, conversations)
	tree = LintTree.new(base, tree_path, conversations, panel)

func menu_select(index):
	match index:
		MenuIndex.Open:
			create_file_dialogue(
				FileDialog.FILE_MODE_OPEN_FILE, 
				FilterType.Json,
				func(path):
					if path_is_valid(path):
						save_path = path
						conversations = Serialisation.load_from_json(path)
						setup_lint()
			)
		MenuIndex.Save:
			if save_path == null:
				menu_select(MenuIndex.SaveAs)
			else: 
				Serialisation.save_to_json(conversations, save_path)
		MenuIndex.SaveAs:
			create_file_dialogue(
				FileDialog.FILE_MODE_SAVE_FILE, 
				FilterType.Lint,
				func(path):
					if path_is_valid(path):
						save_path = path
						Serialisation.save_to_json(conversations, path)
			)
		
		MenuIndex.Export:
			if export_path == null:
				create_file_dialogue(
					FileDialog.FILE_MODE_SAVE_FILE, 
					FilterType.Json,
					func(path):
						if path_is_valid(path):
							export_path = path
							menu_select(MenuIndex.Export)
				)
			else:
				var serialised_data = serialise(conversations.duplicate(true))
				Serialisation.save_to_json(serialised_data, export_path)
				print("Exported to " + export_path + ".")

#Serialising involves flattening conversations to remove LintWidget.VALUE nesting
func serialise(data):
	match typeof(data):
		TYPE_STRING:
			return data
		TYPE_ARRAY:
			for i in len(data):
				data[i] = serialise(data[i])
			return data
		TYPE_DICTIONARY:
			var keys = data.keys()
			for value in keys:
				if value == LintWidget.VALUE:
					data = serialise(data[value])
					break
				else:
					data[value] = serialise(data[value])
			return data
		TYPE_NIL:
			return data
		_:
			print("Attempted to serialise data of unknown type: " + str(typeof(data)) + ":")
			print(data)

func path_is_valid(path):
	return path != null and path != ""

func create_file_dialogue(mode, filter_type, callback):
	if filter_type == FilterType.Json:
		filter_type = ["*.json ; JSON File"]
	else:
		filter_type = ["*.lnt ; Lint File"]
	
	var file_dialogue = FileDialog.new()
	root_node.call_deferred("add_child", file_dialogue)
	file_dialogue.set_filters(PackedStringArray(filter_type))
	file_dialogue.set_file_mode(mode)
	file_dialogue.set_access(FileDialog.ACCESS_FILESYSTEM)
	file_dialogue.call_deferred("popup_centered")
	file_dialogue.set_flag(Window.FLAG_POPUP, true)
	file_dialogue.min_size = Vector2(800, 500)
	file_dialogue.visible = true
	var dialogue_path = save_path
	if save_path == null:
		dialogue_path = "/"
	else:
		file_dialogue.set_current_file(dialogue_path)
		file_dialogue.set_current_path(dialogue_path)
	
	file_dialogue.set_current_dir(dialogue_path)
	
	file_dialogue.mode_overrides_title = false
	file_dialogue.title = "Select File Path"
	if callback != null:
		file_dialogue.connect("file_selected", callback)
