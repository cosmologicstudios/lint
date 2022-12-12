extends Control

var root_node
var conversations = {}
var project_data = {
	"save_path": null,
	"export_path": null,
	"lines": {}
}

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
	Export,
	ExportAs
}

func _ready():
	randomize()
	
	root_node = get_tree().root
	
	var menu_bar = $MenuBar/File.get_popup()
	menu_bar.add_item("Open")
	menu_bar.add_item("Save")
	menu_bar.add_item("Save As")
	menu_bar.add_item("Export")
	menu_bar.add_item("Export As")
	menu_bar.connect("index_pressed", menu_select)
	base = Base.new(root_node)
	values = LintObject.new()
	
	var config = Serialisation.load_config()
	if config != null:
		var data = Serialisation.load_from_json(config["path"])
		conversations = data["conversations"]
		project_data = data["project_data"]
	
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
	panel = LintPanel.new(base, panel_path, values, conversations, project_data)
	tree = LintTree.new(base, tree_path, conversations, panel, project_data)

func menu_select(index):
	match index:
		MenuIndex.Open:
			create_file_dialogue(
				project_data["save_path"],
				FileDialog.FILE_MODE_OPEN_FILE, 
				FilterType.Lint,
				func(selected_path):
					if path_is_valid(selected_path):
						project_data["save_path"] = selected_path
						var data = Serialisation.load_from_json(selected_path)
						conversations = data["conversations"]
						project_data = data["project_data"]
						Serialisation.save_config(selected_path)
						setup_lint()
			)
		
		MenuIndex.Save:
			if project_data["save_path"] == null:
				menu_select(MenuIndex.SaveAs)
			else: 
				Serialisation.save_to_json({
					"conversations": conversations,
					"project_data": project_data
				}, project_data["save_path"])
		
		MenuIndex.SaveAs:
			create_file_dialogue(
				project_data["save_path"],
				FileDialog.FILE_MODE_SAVE_FILE, 
				FilterType.Lint,
				func(selected_path):
					if path_is_valid(selected_path):
						project_data["save_path"] = selected_path
						Serialisation.save_to_json({
							"conversations": conversations,
							"project_data": project_data
						}, selected_path)
						Serialisation.save_config(selected_path)
			)
		
		MenuIndex.Export:
			if project_data["export_path"] == null:
				menu_select(MenuIndex.ExportAs)
			else:
				var serialised_data = serialise(conversations.duplicate(true))
				Serialisation.save_to_json(serialised_data, project_data["export_path"])
				print("Exported to " + project_data["export_path"] + ".")
		
		MenuIndex.ExportAs:
			create_file_dialogue(
				project_data["export_path"],
				FileDialog.FILE_MODE_SAVE_FILE, 
				FilterType.Json,
				func(path):
					if path_is_valid(path):
						project_data["export_path"] = path
						menu_select(MenuIndex.Export)
			)

#Serialising involves flattening conversations to remove LintWidget.BOX nesting
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
				if value == LintWidget.BOX:
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

func create_file_dialogue(base_path, mode, filter_type, callback):
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
	if base_path == null:
		base_path = "/"
	else:
		file_dialogue.set_current_file(base_path)
		file_dialogue.set_current_path(base_path)
	
	file_dialogue.set_current_dir(base_path)
	
	file_dialogue.mode_overrides_title = false
	file_dialogue.title = "Select File Path"
	if callback != null:
		file_dialogue.connect("file_selected", callback)
