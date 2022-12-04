class_name LintObject

enum TypeId {
	Value,
	Line,
	Choice,
	Option,
	List,
	Struct,
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
			"none": null,
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

func declare_defaults():
	var animations = ["idle", "talk"]
	var speakers = ["bean1", "bean2"]
	
	declare_line_type("default", 
		LintObject.Type.Struct({
			"text": LintObject.Type.Value(),
			"speaker": LintObject.Type.Choice(speakers),
			"animation": LintObject.Type.Choice(animations),
			"signals": LintObject.Type.List(LintObject.Type.Value()),
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
			"text": LintObject.Type.Value(),
			"choices": LintObject.Type.List(LintObject.Type.Struct({
				"signals": LintObject.Type.List(LintObject.Type.Value()),
				"go_to_line": LintObject.Type.Line(),
				"show_condition": LintObject.Type.Condition()
			}))
		})
	)
