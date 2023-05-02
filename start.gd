extends Control

# Called when the node enters the scene tree for the first time.
func _ready():	
	#Update version
	$ColorRect/CenterContainer/logo/version.set_text(Global.VERSION)
	Global.debug_log("Starting project, version: {}.", [Global.VERSION])
	
	#Set up buttons
	var buttons = $Left/MarginContainer/VBoxContainer
	buttons.get_node("New").connect("pressed", new_project)
	buttons.get_node("Open").connect("pressed", open_project)
	buttons.get_node("GitHub").connect("pressed", func(): OS.shell_open("https://github.com/cosmologicstudios/lint"))
	
	#Display recent files
	display_recent_files()

func display_recent_files():
	var config = Serialisation.load_config()
	if !config.is_none():
		config = config.unwrap()
		#We may delete entries so we iterate over a copy
		var entries = config["recent"].duplicate()
		
		var recent_files = $Right/Right/VBoxContainer/ScrollContainer/VBoxContainer
		for file_name in entries:
			#Remove this from our config if file does not exist
			if FileAccess.file_exists(file_name):
				var but = Button.new()
				recent_files.add_child(but)
				but.text_overrun_behavior = TextServer.OverrunBehavior.OVERRUN_TRIM_ELLIPSIS
				var file = file_name.get_file()
				but.set_text(file.trim_suffix(".lnt"))
				but.connect("pressed", load_project.bind(file_name))
			else:
				Global.debug_log("File {} was not found. Removing from recent files.", [file_name])
				config["recent"].erase(file_name)
		
		#Save the config - we may have deleted some recent files
		Serialisation.save_config(config)

func new_project():
	Global.create_file_dialogue(
		"",
		FileDialog.FILE_MODE_SAVE_FILE, 
		Global.FilterType.Lint,
		func(save_path):
			Global.project_data = Global.blank_project()
			if Serialisation.path_is_valid(save_path):
				Global.project_data["save_path"] = save_path
				Serialisation.save_to_json(Global.project_data, save_path)
				get_tree().change_scene_to_file("res://main.tscn")
	)

func open_project():
	Global.create_file_dialogue(
		"",
		FileDialog.FILE_MODE_OPEN_FILE, 
		Global.FilterType.Lint,
		func(save_path):
			load_project(save_path)
	)

func load_project(save_path):
	if Serialisation.path_is_valid(save_path):
		var data = Serialisation.load_from_json(save_path)
		if data.is_none():
			Global.debug_log("File at path '{}' is invalid and could not be loaded.", [save_path])
		else:
			Global.project_data = data.unwrap()
			get_tree().change_scene_to_file("res://main.tscn")
	else:
		Global.debug_log("Open NOT successful. Attempted path: " + save_path)
