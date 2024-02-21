class_name LintObject

enum TypeId {
	Value,
	Line,
	Choice,
	Option,
	List,
	Struct,
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
		

func declare_defaults():
	declare_line_type("default", 
		LintObject.Type.Struct({
			"text": LintObject.Type.Value(),
			"speaker": LintObject.Type.Choice(["A", "B"]),
		})
	)
	declare_line_type("choice", 
		LintObject.Type.Struct({
			"choices": LintObject.Type.List(
				LintObject.Type.Struct({
					"text": LintObject.Type.Value(),
					"speaker": LintObject.Type.Choice(["A", "B"]),
				})
			)
		})
	)
