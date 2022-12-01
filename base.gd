class_name Base

var node

func _init(base_node):
	node = base_node

#Generic function for creating a popup at the given location
func create_popup(items, funcs, x=null, y=null):
	if x == null or y == null:
		var pos = node.get_viewport().get_mouse_position()
		x = pos.x
		y = pos.y
	
	var popup = PopupMenu.new()
	node.add_child(popup)
	
	popup.visible = true
	popup.position.x = x
	popup.position.y = y
	
	for item in items:
		if item == "":
			popup.add_separator()
		else:
			popup.add_item(item)
	popup.reset_size()
	
	popup.connect("index_pressed", (func(index, funcs): 
		if index < len(funcs) and funcs[index] != null:
			funcs[index].call()
		).bind(funcs)
	)
