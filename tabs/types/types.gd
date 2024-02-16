class_name LintObject

enum TypeId {
	Value,
	Line,
	Choice,
	Option,
	List,
	Struct,
	Signals,
	None,
	Total
}

var line_types = {}

func _init():
	declare_defaults()
	print("Declared default line types.")

func declare_line_type(name_string, struct):
	line_types[name_string] = struct

func get_line_types():
	return line_types

class Type:
	static func None():
		return { "type": TypeId.None }
	static func Value():
		return { "type": TypeId.Value }
	
	static func Line():
		return { "type": TypeId.Line }
	
	static func Choice(choices: Array):
		return {
			"type": TypeId.Choice,
			"choices": choices
		}
	
	static func Option(options: Dictionary):
		return {
			"type": TypeId.Option,
			"options": options
		}
	
	static func List(contains):
		return {
			"type": TypeId.List,
			"contains": contains
		}
	
	static func Struct(fields: Dictionary):
		return {
			"type": TypeId.Struct,
			"fields": fields
		}
	
	#Condition is actually just a pre-made Option
	static func Condition():
		var conditions = {
			"none": func(): return LintObject.Type.None(),
			"equals": (func(): 
				return LintObject.Type.Struct({
					"value1": LintObject.Type.Value(),
					"value2": LintObject.Type.Value()
				})), 
			"greater_than": (func(): 
				return LintObject.Type.Struct({
					"value1": LintObject.Type.Value(),
					"value2": LintObject.Type.Value()
				})), 
			"less_than": (func(): 
				return LintObject.Type.Struct({
					"value1": LintObject.Type.Value(),
					"value2": LintObject.Type.Value()
				})), 
			"not": (func(): 
				return LintObject.Type.Struct({
				"condition": LintObject.Type.Condition()
				})),
			"or": (func(): 
				return LintObject.Type.Struct({
				"conditions": LintObject.Type.List(LintObject.Type.Condition())
				})),
			"and": (func(): 
				return LintObject.Type.Struct({
				"conditions": LintObject.Type.List(LintObject.Type.Condition())
				})), 
		}
		var option = LintObject.Type.Option(conditions)
		return option
	
	static func Signals(items, quests, skills, sounds):
		var signals = {
			"fade": (func():
				return LintObject.Type.Choice(["In", "Out"])
				),
			"play_sound": (func(sounds): 
				return LintObject.Type.Choice(sounds)
				).bind(sounds),
			"play_music": (func(sounds): 
				return LintObject.Type.Choice(sounds)
				).bind(sounds),
			"stop_music": (func(sounds): 
				return LintObject.Type.Choice(sounds)
				).bind(sounds),
			"advance_quest": (func(quests): 
				return LintObject.Type.Struct({
					"quest": LintObject.Type.Choice(quests),
					"stage": LintObject.Type.Value()
				})).bind(quests),
			"set_object_variable": (func(): 
				return LintObject.Type.Struct({
					"object": LintObject.Type.Value(),
					"variable": LintObject.Type.Value(),
					"value": LintObject.Type.Value()
				})),
			"change_object_variable": (func(): 
				return LintObject.Type.Struct({
					"object": LintObject.Type.Value(),
					"variable": LintObject.Type.Value(),
					"value": LintObject.Type.Value()
				})),
			"create_object": (func(): 
				return LintObject.Type.Struct({
					"object": LintObject.Type.Value(),
					"relative_x": LintObject.Type.Value(),
					"relative_y": LintObject.Type.Value(),
					"number": LintObject.Type.Value(),
				})),
			"delete_object": (func(): 
				return LintObject.Type.Value()
				),
			"change_item_count": (func(items): 
				return LintObject.Type.Struct({
					"item": LintObject.Type.Choice(items),
					"number": LintObject.Type.Value()
				})).bind(items), 
			"change_skill_level": (func(skills): 
				return LintObject.Type.Struct({
					"skill": LintObject.Type.Choice(skills),
					"level": LintObject.Type.Value()
				})).bind(skills),
		}
		return LintObject.Type.List(LintObject.Type.Option(signals))
		

func declare_defaults():
	declare_line_type("default", 
		LintObject.Type.Struct({
			"first_line": LintObject.Type.Choice(["False", "True"]),
			"text": LintObject.Type.Value(),
			"speaker": LintObject.Type.Choice(speakers),
			"animation": LintObject.Type.Choice(animations),
			"signals": LintObject.Type.Signals(items, quests, skills, sounds),
			"go_to_line": LintObject.Type.List(
				LintObject.Type.Struct({
					"line_id": LintObject.Type.Line(),
					"condition": LintObject.Type.Condition()
				})
			)
		})
	)
	declare_line_type("choice", 
		LintObject.Type.Struct({
			"first_line": LintObject.Type.Choice(["False", "True"]),
			"choices": LintObject.Type.List(LintObject.Type.Struct({
				"text": LintObject.Type.Value(),
				"speaker": LintObject.Type.Choice(speakers),
				"go_to_line": LintObject.Type.Line(),
				"show_condition": LintObject.Type.Condition(),
			}))
		})
	)
