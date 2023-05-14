class_name Serialisation

const CONFIG_PATH = "config.json"

# Saves a dictionary to the given full path
static func save_to_json(data, path) -> bool:
	var json = JSON.stringify(data, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	var valid = file != null and json != null
	if valid:
		file.store_string(json)
	
	file = null #Drops the file
	return valid

# Loads a dictionary from the given full path
static func load_from_json(path) -> Option:
	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		var json = file.get_as_text()
		file = null #Drops the file
		
		if json != null:
			var data = JSON.parse_string(json)
			return Option.Some(data)
	
	return Option.None()

static func save_config(config) -> bool:
	return save_to_json(config, CONFIG_PATH)

static func load_config() -> Dictionary:
	if FileAccess.file_exists(CONFIG_PATH):
		return load_from_json(CONFIG_PATH).unwrap()
	else: 
		print("No CONFIG file found, creating default.")
		return {
			"version": Global.VERSION,
			"recent": [],
			"settings": {}
		}

static func path_is_valid(path):
	return path != null and path != ""
