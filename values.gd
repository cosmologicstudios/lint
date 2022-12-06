class_name LintObject

enum TypeId {
	Value,
	Line,
	Choice,
	Option,
	List,
	Struct,
	Signals,
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
	
	static func Signals(items, quests, skills):
		var signals = {
			"add_health": (func(): 
				return LintObject.Type.Value()
				),
			"advance_quest": (func(quests): 
				return LintObject.Type.Struct({
					"quest": LintObject.Type.Choice(quests),
					"stage": LintObject.Type.Value()
				})).bind(quests),
			"set_object_variable": (func(): 
				return LintObject.Type.Struct({
					"object": LintObject.Type.Value(),
					"variable": LintObject.Type.Value()
				})),
			"add_object_variable": (func(): 
				return LintObject.Type.Struct({
					"object": LintObject.Type.Value(),
					"variable": LintObject.Type.Value()
				})),
			"create_object": (func(): 
				return LintObject.Type.Value()
				),
			"delete_object": (func(): 
				return LintObject.Type.Value()
				),
			"add_item": (func(items): 
				return LintObject.Type.Struct({
					"item": LintObject.Type.Choice(items),
					"number": LintObject.Type.Value()
				})).bind(items), 
			"add_skill_level": (func(skills): 
				return LintObject.Type.Struct({
					"skills": LintObject.Type.Choice(skills),
					"level": LintObject.Type.Value()
				})).bind(skills),
		}
		return LintObject.Type.List(LintObject.Type.Option(signals))
		

func declare_defaults():
	var animations = ["idle", "talk", "interact", "walk", "run", "sleep"]
	var speakers = [
		"Billy Vassiliou", "Beast", "Dad", "Mum", "Eddie Green", 
		"Adrian Lu", "Donna Wright-Gorrie", "Sasha Pavic",
		"Carter Mason", "Danny Burke", "Deborah Smith", "Dr Kimani", "Farah Saleh", "Lachlan King", "Riley King", "Lyndon Reed",
		"Tatiana Cat", "Jinjer Cat", "Jan Bradbury", "Joseph Long", "Kit Demir", "Luke Keller", "Mo Subramani", "Patrick Murray",
		"Jimmy Gallagher", "Karen Nash-Perry",
		"Benjie Tambo", "Chloe Lyon", "Gabriela Torres", "Hugo Torres", "Javonte Ford", "Liam Thompson", "Mickey",
		"Donald Duffy", "Sam Mackenzie",
		"Gary Lowe", "Ian Davies", "Irene Weber", "Kristie Wallace",
		"Anne Bishop", "Kev Munro", "Nina Kraviz", "Takuya Ito", "Tom Rogers",
	]
	speakers.sort()
	speakers.insert(0, "Narrator")
	
	var items = [
		"watch",
		"ute keys",
		"backpack",
		"handheld radio",
		"torch",
		"gloves",
		"multi tool",
		"harmonica",
		"binoculars",
		"lockpick",
		"rope",
		"gun"
	]
	items.sort()
	
	var quests = [
		"find bean", 
	]
	quests.sort()
	
	var skills = [
		"impulse", "backbone", "finesse", "cool", "cursed",
		"chronicler", "savvy", "tech", "earthling", "blood",
		"strange", "sharp", "dramaturgy", "domination", "empath"
	]
	
	declare_line_type("default", 
		LintObject.Type.Struct({
			"text": LintObject.Type.Value(),
			"speaker": LintObject.Type.Choice(speakers),
			"animation": LintObject.Type.Choice(animations),
			"signals": LintObject.Type.Signals(items, quests, skills),
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
			"choices": LintObject.Type.List(LintObject.Type.Struct({
				"text": LintObject.Type.Value(),
				"go_to_line": LintObject.Type.Line(),
				"show_condition": LintObject.Type.Condition(),
				"signals": LintObject.Type.Signals(items, quests, skills),
			}))
		})
	)
