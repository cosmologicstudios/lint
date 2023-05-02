class_name LintWidget

const BOX = "__box"

static func create_margin(node):
	var margin = MarginContainer.new()
	margin.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	#margin.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	node.add_child(margin)
	return margin

static func create_v_marginbox(node):
	var margin = create_margin(node)
	var box = VBoxContainer.new()
	box.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	margin.add_child(box)
	return box

static func create_h_marginbox(node):
	var margin = create_margin(node)
	var box = HBoxContainer.new()
	box.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	margin.add_child(box)
	return box

static func create_list_entry(node, list, entry_data, type_data, item, lines, conversation):
	var panel = PanelContainer.new()
	node.add_child(panel)
	
	var box = HBoxContainer.new()
	panel.add_child(box)
	var fields_box = HBoxContainer.new()
	fields_box.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	box.add_child(fields_box)
	
	recurse_create_widgets(fields_box, entry_data, type_data, item, lines, conversation)
	
	var delete = Button.new()
	delete.text = " X "
	
	delete.connect("pressed", (func(box, list, entry_data): 
		list.erase(entry_data)
		box.queue_free()
		Global.debug_log("Deleted entry from widget")
	).bind(box, list, entry_data))
	
	box.add_child(delete)

static func setup_line_items(choices, lines, line_data):
	var keys = lines.keys()
	choices.clear()
	
	for i in len(keys):
		var id = keys[i]
		choices.add_item("Line " + lines[id])
		choices.set_item_metadata(i, id)
	choices.add_item("END", -1)
	
	#Select our old index
	var selected_idx = -1
	if line_data[BOX] != null:
		for idx in choices.item_count-1:
			var metadata = choices.get_item_metadata(idx)
			if metadata == line_data[BOX]:
				selected_idx = idx
				break
	choices.select(selected_idx)
	choices.emit_signal("item_selected", selected_idx)

static func recurse_create_widgets(node, line_data, type_data, data_name, lines, conversation):
	match type_data["type"]:
		LintObject.TypeId.Value:
			var box = create_h_marginbox(node)
			var label = Label.new()
			label.text = data_name
			
			var text = TextEdit.new()
			text.set_line_wrapping_mode(TextEdit.LINE_WRAPPING_BOUNDARY)
			text.set_fit_content_height_enabled(true)
			text.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			
			if line_data[BOX] == null:
				line_data[BOX] = ""
			text.set_text(line_data[BOX])
			
			text.connect("text_changed", (
				func(line_data, text): line_data[BOX] = text.get_text() 
			).bind(line_data, text))
			
			box.add_child(label)
			box.add_child(text)
		
		LintObject.TypeId.Line:
			var label = Label.new()
			label.text = data_name
			var choices = OptionButton.new()
			choices.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			
			choices.connect("item_selected", (
				func(index, line_data, choices): 
					var data = null
					if index != -1:
						data = choices.get_item_metadata(index)
					line_data[BOX] = data
			).bind(line_data, choices))
			
			choices.connect("pressed", (
				func(choices, lines, line_data): setup_line_items(choices, lines, line_data)
			).bind(choices, lines, line_data))
			
			node.add_child(label)
			node.add_child(choices)
			
			choices.call_deferred("emit_signal", "pressed")
			
		LintObject.TypeId.Choice:
			var box = create_h_marginbox(node)
			var label = Label.new()
			label.text = data_name
			var choices = OptionButton.new()
			choices.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			
			for i in len(type_data["choices"]):
				var choice = type_data["choices"][i]
				choices.add_item(choice)
				#We skip the first one as it is clear
				choices.set_item_metadata(i, choice)
			
			choices.connect("item_selected", (
				func(index, line_data, option_button): 
					var data = null
					if index != -1:
						data = option_button.get_item_metadata(index)
					line_data[BOX] = data
			).bind(line_data, choices))
			
			box.add_child(label)
			box.add_child(choices)
			
			var index = 0
			if line_data[BOX] != null:
				for i in len(type_data["choices"]):
					if type_data["choices"][i] == line_data[BOX]:
						index = i
						break
			choices.call_deferred("select", index)
			choices.call_deferred("emit_signal", "item_selected", index)
		
		LintObject.TypeId.Struct:
			var fields = type_data["fields"]
			var type_fields = fields.keys()
			
			if line_data[BOX] == null:
				line_data[BOX] = {}
			var data = line_data[BOX]
			
			if data_name != "":
				var label = Label.new()
				label.text = data_name
				node.add_child(label)
			
			var box = create_v_marginbox(node)
			var panel = PanelContainer.new()
			box.add_child(panel)
			
			for field_name in type_fields:
				if field_name not in data:
					data[field_name] = { BOX: null }
				recurse_create_widgets(box, data[field_name], fields[field_name], field_name, lines, conversation)
		
		LintObject.TypeId.Option:
			var box = create_v_marginbox(node)
			var container = HBoxContainer.new()
			container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			box.add_child(container)
			
			var select_option = func(index, options, field_box, line_data):
				var children = field_box.get_children()
				for child in children:
					field_box.remove_child(child)
				
				if index == -1:
					line_data[BOX] = null
				else:
					var metadata = options.get_item_metadata(index)
					if metadata != null:
						metadata = metadata.call()
						var option_name = options.get_item_text(index)
						if line_data[BOX] == null or line_data[BOX].keys()[0] != option_name:
							line_data[BOX] = {
								option_name: { BOX: null }
							}
						recurse_create_widgets(field_box, line_data[BOX][option_name], metadata, "", lines, conversation)
			
			var option_strings = type_data["options"].keys()
			
			var label = Label.new()
			label.text = data_name
			var options = OptionButton.new()
			options.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			
			for i in len(option_strings):
				var choice = option_strings[i]
				options.add_item(choice)
			
			container.add_child(label)
			container.add_child(options)
			
			var field_box = create_v_marginbox(box)
			field_box.name = "fields"
			options.connect("item_selected", select_option.bind(options, field_box, line_data))
			
			for i in options.item_count:
				var option_name = option_strings[i]
				var option_func = type_data["options"][option_name]
				#We skip the first entry as it is clear
				options.set_item_metadata(i, option_func)
			
			#Have we already got a selection?
			var index = 0
			if line_data[BOX] != null:
				var keys = line_data[BOX].keys()
				var option_name = keys[0]
				var options_keys = type_data["options"].keys()
				index = options_keys.find(option_name)
			
			options.call_deferred("select", index)
			options.call_deferred("emit_signal", "item_selected", index)
		
		LintObject.TypeId.List:
			if line_data[BOX] == null:
				line_data[BOX] = []
			
			node = create_v_marginbox(node)
			
			#Name and button
			var array = create_h_marginbox(node)
			var label = Label.new()
			label.text = data_name
			var add_button = Button.new()
			add_button.text = " + "
			
			array.add_child(label)
			array.add_child(add_button)
			
			#Contents
			var container = create_margin(node)
			var panel = PanelContainer.new()
			panel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			container.add_child(panel)
			
			var items = create_v_marginbox(panel)
			var item_type_data = type_data["contains"]
			
			var add_list_entry = func(node, line_data, type_data, item, lines, conversation):
			#static func add_list_entry(node, line_data, type_data, item, lines):
				var entry_data = { BOX: null }
				line_data[BOX].append(entry_data)
				create_list_entry(node, line_data[BOX], entry_data, type_data, item, lines, conversation)
			
			add_button.connect("pressed", add_list_entry.bind(items, line_data, item_type_data, "", lines, conversation))
			
			#(node, line_data, type_data, data_name, lines)
			for entry_data in line_data[BOX]:
				create_list_entry(items, line_data[BOX], entry_data, item_type_data, "", lines, conversation)
