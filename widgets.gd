class_name LintWidget

const VALUE = "__lint_value"

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
		print("Deleted entry.")
	).bind(box, list, entry_data))
	
	box.add_child(delete)

static func setup_line_items(choices, lines, line_data):
	var keys = lines.keys()
	choices.clear()
	
	#First entry is clear
	choices.add_item("")
	
	for i in len(keys):
		var id = keys[i]
		choices.add_item("Line " + lines[id])
		#Skipped first entry as it is clear
		choices.set_item_metadata(i+1, id)
	
	#Select our old index
	var selected_idx = -1
	if line_data[VALUE] != null:
		for idx in choices.item_count:
			var metadata = choices.get_item_metadata(idx)
			if metadata == line_data[VALUE]:
				selected_idx = idx
				break
	choices.select(selected_idx)

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
			
			if line_data[VALUE] == null:
				line_data[VALUE] = ""
			text.set_text(line_data[VALUE])
			
			text.connect("text_changed", (
				func(line_data, text): line_data[VALUE] = text.get_text() 
			).bind(line_data, text))
			
			box.add_child(label)
			box.add_child(text)
		
		LintObject.TypeId.Line:
			var box = create_h_marginbox(node)
			var label = Label.new()
			label.text = data_name
			var choices = OptionButton.new()
			choices.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			
			choices.connect("item_selected", (
				func(index, line_data, choices): 
					print(index)
					var data = null
					if index > 0:
						data = choices.get_item_metadata(index)
					line_data[VALUE] = data
			).bind(line_data, choices))
			
			choices.connect("pressed", (
				func(choices, lines, line_data): setup_line_items(choices, lines, line_data)
			).bind(choices, lines, line_data))
			
			node.add_child(label)
			node.add_child(choices)
			
			if line_data[VALUE] != null:
				for i in choices.item_count:
					if line_data[VALUE] == choices.get_item_metadata(i):
						choices.call_deferred("select", i)
						choices.call_deferred("emit_signal", "pressed")
						choices.call_deferred("emit_signal", "item_selected", i)
						break
			
		LintObject.TypeId.Choice:
			var box = create_h_marginbox(node)
			var label = Label.new()
			label.text = data_name
			var choices = OptionButton.new()
			choices.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			
			choices.add_item("")
			for i in len(type_data["choices"]):
				var choice = type_data["choices"][i]
				choices.add_item(choice)
				#We skip the first one as it is clear
				choices.set_item_metadata(i+1, choice)
			
			choices.connect("item_selected", (
				func(index, line_data, option_button): 
					print(index)
					var data = null
					if index > 0:
						data = option_button.get_item_metadata(index)
					line_data[VALUE] = data
			).bind(line_data, choices))
			
			box.add_child(label)
			box.add_child(choices)
			
			if line_data[VALUE] != null:
				for i in len(type_data["choices"]):
					if type_data["choices"][i] == line_data[VALUE]:
						choices.call_deferred("select", i)
						choices.call_deferred("emit_signal", "item_selected", i)
						break
		
		LintObject.TypeId.Struct:
			var fields = type_data["fields"]
			var type_fields = fields.keys()
			
			if line_data[VALUE] == null:
				line_data[VALUE] = {}
			var data = line_data[VALUE]
			
			if data_name != "":
				var label = Label.new()
				label.text = data_name
				node.add_child(label)
			
			var box = create_v_marginbox(node)
			var panel = PanelContainer.new()
			box.add_child(panel)
			
			for field_name in type_fields:
				if field_name not in data:
					data[field_name] = { VALUE: null }
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
				
				if index <= 0:
					print(index)
					line_data[VALUE] = null
				else:
					var metadata = options.get_item_metadata(index)
					if metadata != null:
						metadata = metadata.call()
						var option_name = options.get_item_text(index)
						if line_data[VALUE] == null or line_data[VALUE].keys()[0] != option_name:
							line_data[VALUE] = {
								option_name: { VALUE: null }
							}
						recurse_create_widgets(field_box, line_data[VALUE][option_name], metadata, "", lines, conversation)
			
			var option_strings = type_data["options"].keys()
			
			var label = Label.new()
			label.text = data_name
			var options = OptionButton.new()
			options.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			
			options.add_item("")
			for i in len(option_strings):
				var choice = option_strings[i]
				options.add_item(choice)
			
			container.add_child(label)
			container.add_child(options)
			
			var field_box = create_v_marginbox(box)
			field_box.name = "fields"
			options.connect("item_selected", select_option.bind(options, field_box, line_data))
			
			var i = 1
			while i < options.item_count:
				var option_name = option_strings[i-1]
				var option_func = type_data["options"][option_name]
				#We skip the first entry as it is clear
				options.set_item_metadata(i, option_func)
				i += 1
			
			#Have we already got a selection?
			if line_data[VALUE] != null:
				var keys = line_data[VALUE].keys()
				var option_name = keys[0]
				var options_keys = type_data["options"].keys()
				var index = options_keys.find(option_name)
				options.call_deferred("select", index)
				options.call_deferred("emit_signal", "item_selected", index)
		
		LintObject.TypeId.List:
			if line_data[VALUE] == null:
				line_data[VALUE] = []
			
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
				var entry_data = { VALUE: null }
				line_data[VALUE].append(entry_data)
				create_list_entry(node, line_data[VALUE], entry_data, type_data, item, lines, conversation)
			
			add_button.connect("pressed", add_list_entry.bind(items, line_data, item_type_data, "", lines, conversation))
			
			#(node, line_data, type_data, data_name, lines)
			for entry_data in line_data[VALUE]:
				create_list_entry(items, line_data[VALUE], entry_data, item_type_data, "", lines, conversation)
