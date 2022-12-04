extends Control

var save_path
var root_node
var conversations = {}

enum MenuIndex {
	Open,
	Save,
	SaveAs
}

func _ready():
	randomize()
	
	root_node = get_tree().root
	
	var menu_bar = $MenuBar/File
	menu_bar.add_item("Open")
	menu_bar.add_item("Save")
	menu_bar.add_item("Save As")
	menu_bar.connect("index_pressed", menu_select)
	
	setup_lint()

func setup_lint():
	var container = $ColorRect/MarginContainer/HSplitContainer
	var tree_path = container.get_node("Side/Tree")
	var panel_path = container.get_node("Main")
	
	var base = Base.new(root_node)
	var values = LintObject.new()
	var panel = LintPanel.new(base, panel_path, values, conversations)
	var _tree = LintTree.new(base, tree_path, conversations, panel)

func menu_select(index):
	match index:
		MenuIndex.Open:
			create_file_dialogue(FileDialog.FILE_MODE_OPEN_FILE, 
				func(path):
					if path_is_valid(path):
						save_path = path
						conversations = Serialisation.load_from_json(path)
			)
		MenuIndex.Save:
			if save_path == null:
				menu_select(MenuIndex.SaveAs)
			else:
				Serialisation.save_to_json(conversations, save_path)
		MenuIndex.SaveAs:
			create_file_dialogue(FileDialog.FILE_MODE_SAVE_FILE, 
				func(path):
					if path_is_valid(path):
						save_path = path
						Serialisation.save_to_json(conversations, path)
			)

func path_is_valid(path):
	return path != null and path != ""

func create_file_dialogue(mode, callback):
	var file_dialogue = FileDialog.new()
	root_node.call_deferred("add_child", file_dialogue)
	file_dialogue.set_filters(PackedStringArray(["*.json ; JSON File"]))
	file_dialogue.set_mode(mode)
	file_dialogue.set_access(FileDialog.ACCESS_FILESYSTEM)
	file_dialogue.call_deferred("popup_centered")
	file_dialogue.set_flag(Window.FLAG_POPUP, true)
	file_dialogue.min_size = Vector2(800, 500)
	file_dialogue.visible = true
	file_dialogue.set_current_dir("Users")
	file_dialogue.mode_overrides_title = false
	file_dialogue.title = "Select File Path"
	if callback != null:
		file_dialogue.connect("file_selected", callback)
