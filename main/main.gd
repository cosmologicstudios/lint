extends Control

const NOTIF_COUNTDOWN_MAX = 360

var lint_panel
var lint_tree
var notification_node
var notif_countdown

enum MenuIndex {
	MainMenu=0,
	Save=2,
	SaveAs=3,
	Export=5,
	ExportAs=6,
}

func _enter_tree():
	randomize()
	
	notif_countdown = 0
	notification_node = get_node("Notification")
	
	setup_menu_bar()
	
	var values = LintObject.new()
	var container = get_node("ColorRect/MarginContainer/TabContainer/Lines")
	var tree_node = container.get_node("Side")
	var panel_node = container.get_node("Main")
	
	lint_panel = LintPanel.new(panel_node, values)
	lint_tree = LintTree.new(tree_node, lint_panel)
	
	Global.unsaved_changes = false
	
	#Check our config
	var config = Save.load_config()
	if config["version"] != Global.VERSION:
		Global.debug_log("Config is version {} but project is version {}", [config["version"], Global.VERSION])
	
	#Put it at the front of recent files
	if Global.project_data["save_path"] in config["recent"]:
		config["recent"].erase(Global.project_data["save_path"])
	config["recent"].push_front(Global.project_data["save_path"])
	
	Save.save_config(config)

func _process(_delta):
	handle_notifications()

func handle_notifications():
	if notification_node.visible:
		notif_countdown -= 1
		if notif_countdown < 0:
			var notif_mod = notification_node.get_modulate()
			notif_mod[3] -= 0.02
			notification_node.set_modulate(notif_mod)
			
			if notif_mod[3] <= 0:
				notification_node.visible = false
	
func create_notification(string, args=null):
	if args != null:
		string = string.format(args, "{}")
	
	notification_node.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
	var button = notification_node.get_node("Button")
	button.connect("pressed", func(): notif_countdown = 0)
	notif_countdown = NOTIF_COUNTDOWN_MAX
	if not notification_node.visible:
		notification_node.visible = true
		button.text = string
	else:
		button.text += "\n" + string

func setup_menu_bar():
	var menu_bar = get_node("MenuBar/HBoxContainer")
	var file = menu_bar.get_node("File").get_popup()
	file.add_item("Main Menu")
	file.add_separator()
	file.add_item("Save")
	file.add_item("Save As")
	file.add_separator()
	file.add_item("Export")
	file.add_item("Export As")
	file.connect("index_pressed", menu_select)
	
	var options = menu_bar.get_node("Options").get_popup()
	options.add_item("Preferences (todo)")
	
	var help = menu_bar.get_node("Help").get_popup()
	help.add_item("Documentation")
	help.add_item("Report Bug")
	help.add_item("Feature Request")
	help.connect("index_pressed", 
		func(index): 
			match index:
				0:
					OS.shell_open("https://github.com/cosmologicstudios/lint/wiki")
				1, 2:
					OS.shell_open("https://github.com/cosmologicstudios/lint/issues/new/choose")
				_:
					OS.shell_open("https://github.com/cosmologicstudios/lint")
	)

func menu_select(index):
	match index:
		MenuIndex.MainMenu:
			get_tree().change_scene_to_file("res://start.tscn")
		
		MenuIndex.Save:
			save_project(Global.project_data["save_path"])
		
		MenuIndex.SaveAs:
			Global.create_file_dialogue(
				Global.project_data["save_path"],
				FileDialog.FILE_MODE_SAVE_FILE, 
				Global.FilterType.Lint,
				save_project
			)
		
		MenuIndex.Export:
			if Global.project_data["export_path"] == null:
				menu_select(MenuIndex.ExportAs)
			else:
				var serialised_data = serialise(Global.project_data["conversations"].duplicate(true))
				var saved = Save.save_to_json(serialised_data, Global.project_data["export_path"])
				create_notification(
					("Exported to: " if saved else "Could not export to: ") 
					+ Global.project_data["export_path"]
				)
		
		MenuIndex.ExportAs:
			Global.create_file_dialogue(
				Global.project_data["export_path"],
				FileDialog.FILE_MODE_SAVE_FILE, 
				Global.FilterType.Json,
				func(path):
					if Save.path_is_valid(path):
						Global.project_data["export_path"] = path
						menu_select(MenuIndex.Export)
			)
		_:
			Global.debug_log("Unknown menu index: {}", [str(index)])

func save_project(path):
	var saved = false
	if Save.path_is_valid(path):
		saved = Save.save_to_json(Global.project_data, path)
	
	if saved:
		Global.unsaved_changes = false
		create_notification("Saved to: " + path)
	else:
		create_notification("Save NOT successful. Attempted path: " + path)
	
	get_tree().reload_current_scene()

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
			var error_msg = "Attempted to serialise data of unknown type: {}" + str(typeof(data)) + ":"
			Global.debug_log(error_msg, [data])
			create_notification(error_msg)