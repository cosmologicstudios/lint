extends Node

const VERSION = "1.1.0"

enum FilterType {
	Lint,
	Json
}

#Persistent data
var debug_list := []
var unsaved_changes := false
var project_data := {}

func _ready():
	project_data = blank_project()

func blank_project():
	return {
		"save_path": "",
		"export_path": "",
		"lines": {},
		"conversations": {},
		"version": VERSION
	}

#Generic function for creating a popup at the given location
func create_popup(items, funcs, x=null, y=null):
	var node = get_tree().root
	if x == null or y == null:
		var pos = node.get_viewport().get_mouse_position()
		x = pos.x
		y = pos.y
	
	var popup = PopupMenu.new()
	node.add_child(popup)
	
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

func create_file_dialogue(base_path, mode, filter_type, callback):
	if filter_type == Global.FilterType.Json:
		filter_type = ["*.json ; JSON File"]
	else:
		filter_type = ["*.lnt ; Lint File"]
	
	var file_dialogue = FileDialog.new()
	get_tree().root.call_deferred("add_child", file_dialogue)
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

func debug_log(msg: String, args: Array = []):
	msg = str(Time.get_ticks_msec()) + ": " + msg.format(args, "{}")
	print(msg)
	debug_list.push_back(msg)
	Save.save_to_json(debug_list, "user://log.json")
