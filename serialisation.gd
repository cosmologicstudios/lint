class_name Serialisation

# Saves a dictionary to the given full path
static func save_to_json(dict, path) -> void:
	var data = JSON.stringify(dict, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)

# Loads a dictionary from the given full path
static func load_from_json(path) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	var data = JSON.parse_string(text)
	return data
