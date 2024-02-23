class_name LintWidget

const BOX = "__box"

static func create_margin(_node):
	var margin = MarginContainer.new()
	margin.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_node.add_child(margin)
	return margin

static func create_v_marginbox(_node):
	var margin = create_margin(_node)
	var box = VBoxContainer.new()
	box.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	margin.add_child(box)
	return box

static func create_h_marginbox(_node):
	var margin = create_margin(_node)
	var box = HBoxContainer.new()
	box.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	margin.add_child(box)
	return box

static func create_list_entry(graph_node, _node, _list, _entry_data, _type_data, _item, _conversation):
	var panel = PanelContainer.new()
	_node.add_child(panel)
	
	var box = HBoxContainer.new()
	panel.add_child(box)
	var fields_box = HBoxContainer.new()
	fields_box.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	box.add_child(fields_box)
	
	recurse_create_widgets(graph_node, fields_box, _entry_data, _type_data, _item, _conversation)
	
	var delete = Button.new()
	delete.text = " X "
	
	delete.connect("pressed", (func(_box, _list, _entry_data): 
		_list.erase(_entry_data)
		_box.queue_free()
		Global.debug_log("Deleted entry from widget")
	).bind(box, _list, _entry_data))
	
	box.add_child(delete)

static func recurse_create_widgets(graph_node, node, line_data, type_data, data_name, conversation):
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
			var next_line = TextEdit.new()
			next_line.editable = false
			next_line.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			if line_data[BOX] != null:
				next_line.text = line_data[BOX]
			
			var idx = graph_node.get_output_port_count()
			print(idx)
			graph_node.set_slot(
				idx, 
				graph_node.is_slot_enabled_left(idx), 0, Color.AZURE, 
				true, 0, Color.AZURE
			)
			#Slots will not show unless child Control objs per slot are added
			var slot_label = Label.new()
			#slot_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			#slot_label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
			#slot_label.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
			#slot_label.text = str(idx)
			graph_node.add_child(slot_label)
			
			#node.add_child(label)
			#node.add_child(next_line)
			
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
				func(index, _line_data, _option_button): 
					var data = null
					if index != -1:
						data = _option_button.get_item_metadata(index)
					_line_data[BOX] = data
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
				recurse_create_widgets(graph_node, box, data[field_name], fields[field_name], field_name, conversation)
		
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
						recurse_create_widgets(graph_node, field_box, line_data[BOX][option_name], metadata, "", conversation)
			
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
			
			var add_list_entry = func(node, line_data, type_data, item, conversation):
			#static func add_list_entry(node, line_data, type_data, item):
				var entry_data = { BOX: null }
				line_data[BOX].append(entry_data)
				create_list_entry(graph_node, node, line_data[BOX], entry_data, type_data, item, conversation)
			
			add_button.connect("pressed", add_list_entry.bind(items, line_data, item_type_data, "", conversation))
			
			#(node, line_data, type_data, data_name, lines)
			for entry_data in line_data[BOX]:
				create_list_entry(graph_node, items, line_data[BOX], entry_data, item_type_data, "", conversation)
