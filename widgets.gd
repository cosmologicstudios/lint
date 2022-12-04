class_name LintWidget

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

static func create_choice(node, data, data_name):
	var label = Label.new()
	label.text = data_name
	var choices = OptionButton.new()
	choices.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	for choice in data:
		choices.add_item(choice)
	
	node.add_child(label)
	node.add_child(choices)
	return choices

static func recurse_create_widgets(node, conversation_data, type_data, data_name, lines):
	match type_data["type"]:
		LintObject.TypeId.Value:
			var box = create_h_marginbox(node)
			var label = Label.new()
			label.text = data_name
			var text = TextEdit.new()
			text.set_line_wrapping_mode(TextEdit.LINE_WRAPPING_BOUNDARY)
			text.set_fit_content_height_enabled(true)
			text.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			
			box.add_child(label)
			box.add_child(text)
		
		LintObject.TypeId.Line:
			var box = create_h_marginbox(node)
			create_choice(box, lines, data_name)
		
		LintObject.TypeId.Choice:
			var box = create_h_marginbox(node)
			create_choice(box, type_data["choices"], data_name)
		
		LintObject.TypeId.Struct:
			if data_name != "":
				var label = Label.new()
				label.text = data_name
				node.add_child(label)
			
			var box = create_v_marginbox(node)
			var panel = PanelContainer.new()
			box.add_child(panel)
			
			for field in type_data["fields"]:
				recurse_create_widgets(box, conversation_data, type_data["fields"][field], field, lines)
		
		LintObject.TypeId.Option:
			var box = create_v_marginbox(node)
			var container = HBoxContainer.new()
			container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			box.add_child(container)
			
			var select_option = func(index, options, fields):
				var options_name = options.get_item_text(index)
				var metadata = options.get_item_metadata(index)
				var children = fields.get_children()
				for child in children:
					fields.remove_child(child)
				
				if metadata != null:
					metadata = metadata.call()
					recurse_create_widgets(fields, conversation_data, metadata, "", lines)
			
			var option_strings = type_data["options"].keys()
			var options = create_choice(container, option_strings, data_name)
			
			var field_box = create_v_marginbox(box)
			field_box.name = "fields"
			options.connect("item_selected", select_option.bind(options, field_box))
			
			var option_names = type_data["options"].keys()
			for i in options.item_count:
				var option_name = option_names[i]
				var option_func = type_data["options"][option_name]
				var item = option_func
				options.set_item_metadata(i, item)
		
		LintObject.TypeId.List:
			var delete_list_entry = func(node):
				node.queue_free()
				print("Deleted entry.")
			
			var add_list_entry = func(node, conversation_data, type_data, item, lines):
				var panel = PanelContainer.new()
				node.add_child(panel)
				
				var box = HBoxContainer.new()
				panel.add_child(box)
				var fields_box = HBoxContainer.new()
				fields_box.set_h_size_flags(Control.SIZE_EXPAND_FILL)
				box.add_child(fields_box)
				recurse_create_widgets(fields_box, conversation_data, type_data, item, lines)
				
				var delete = Button.new()
				delete.text = " X "
				delete.connect("pressed", delete_list_entry.bind(box))
				
				box.add_child(delete)
				print("Added entry.")
			
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
			
			conversation_data = []
			var callable = add_list_entry.bind(items, conversation_data, item_type_data, "", lines)
			add_button.connect("pressed", callable)
			
			for item in conversation_data:
				add_list_entry.call(items, conversation_data, item_type_data, item, lines)
