class_name LintWidget

static func create_label_text(node, data_name):
	var label = Label.new()
	label.text = data_name
	var text = TextEdit.new()
	text.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	node.add_child(label)
	node.add_child(text)

static func create_margin(node):
	var margin = MarginContainer.new()
	margin.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	margin.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	node.add_child(margin)
	return margin

static func recurse_create_widgets(node, data, data_name):
	match data["type"]:
		LintObject.TypeId.Value:
			var margin = create_margin(node)
			var box = HBoxContainer.new()
			margin.add_child(box)
			
			create_label_text(box, data_name)
			
		LintObject.TypeId.Line:
			pass
		LintObject.TypeId.Choice:
			pass
		LintObject.TypeId.Option:
			pass
		LintObject.TypeId.List:
			pass
		LintObject.TypeId.Struct:
			#MarginContainer
			var margin = MarginContainer.new()
			node.add_child(margin)
			var box = VBoxContainer.new()
			margin.add_child(box)
			
			for field in data["fields"]:
				recurse_create_widgets(box, data["fields"][field], field)
			
		LintObject.TypeId.Condition:
			pass
