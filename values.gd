class_name LintObject

enum TypeId {
	Value,
	Line,
	Choice,
	Option,
	List,
	Struct,
	Condition
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
	
	static func Choice(choices):
		return {
			"type": TypeId.Choice,
			"choices": choices
		}
	
	static func Option(options):
		return {
			"type": TypeId.Option,
			"options": options
		}
	
	static func List(contains):
		return {
			"type": TypeId.List,
			"contains": contains
		}
	
	static func Struct(fields):
		return {
			"type": TypeId.Struct,
			"fields": fields
		}
	
	static func Condition():
		return { "type": TypeId.Condition }

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
