class_name Serialisation

const CONFIG_PATH = "config.json"

# Saves a dictionary to the given full path
static func save_to_json(dict, path) -> bool:
	var data = JSON.stringify(dict, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	var valid = file != null and data != null
	if valid:
		file.store_string(data)
	
	file = null
	return valid

# Loads a dictionary from the given full path
static func load_from_json(path) -> Option:
	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		var text = file.get_as_text()
		file = null
		
		if text != null:
			var data = JSON.parse_string(text)
			return Option.Some(data)
	
	return Option.None()

static func save_config(path) -> bool:
	return save_to_json({ "path": path }, CONFIG_PATH)

static func load_config() -> Option:
	if FileAccess.file_exists(CONFIG_PATH):
		var data = load_from_json(CONFIG_PATH)
		if data.is_none():
			return data
		else:
			data = data.unwrap()
			if "path" not in data or data["path"] == null:
				return Option.None()
			else:
				return Option.Some(data)
	else: 
		print("No CONFIG file found.")
		return Option.None()
