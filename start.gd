extends Control

@onready var recent_files = $Right/Right/VBoxContainer/ScrollContainer/VBoxContainer
@onready var version = $ColorRect/CenterContainer/logo/version
var Main = preload("res://main.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	var config = Serialisation.load_config()
	
	#Update version
	version.set_text(Base.VERSION)
	Global.Log("Starting project, version: {}.", [Base.VERSION])
	
	#Display recent files
	if !config.is_none():
		config = config.unwrap()
		#We may delete entries so we iterate over a copy
		var entries = config["recent"].duplicate()
		for file_name in entries:
			#Remove this from our config if file does not exist
			if FileAccess.file_exists(file_name):
				var but = Button.new()
				recent_files.add_child(but)
				but.text_overrun_behavior = TextServer.OverrunBehavior.OVERRUN_TRIM_ELLIPSIS
				var file = file_name.get_file()
				but.set_text(file.trim_suffix(".lnt"))
			else:
				Global.Log("File {} was not found. Removing from recent files.", [file_name])
				config["recent"].erase(file_name)
		
		#Save the config - we may have deleted some recent files
		Serialisation.save_config(config)

func new_project():
	get_tree().reload_current_scene()

func open_project():
	create_file_dialogue(
		"",
		FileDialog.FILE_MODE_OPEN_FILE, 
		FilterType.Lint,
		func(path):
			var result = load_project(Global.path)
			create_notification(
				"Open NOT successful. Attempted path: " + 
				path if result == null 
				else "Successfully opened project at: " + path
			)
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
