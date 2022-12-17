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
					"skills": LintObject.Type.Choice(skills),
					"level": LintObject.Type.Value()
				})).bind(skills),
		}
		return LintObject.Type.List(LintObject.Type.Option(signals))
		

func declare_defaults():
	var animations = ["idle", "talk", "interact", "walk", "run", "sleep"]
	var skills = [
		"impulse", "backbone", "finesse", "cool", "cursed",
		"chronicler", "savvy", "artificer", "earthling", "blood",
		"strange", "sharp", "dramaturgy", "domination", "empath"
	]
	var speakers = ["Narrator", "You"]
	speakers.append_array(skills)
	speakers.append_array([
		"Billy Vassiliou", "Beast", "Dad", "Mum", "Eddie Green", 
		"Adrian Lu", "Donna Wright-Gorrie", "Sasha Pavic",
		"Carter Mason", "Danny Burke", "Deborah Smith", "Dr Kimani", "Farah Saleh", "Lachlan King", "Riley King", "Lyndon Reed",
		"Tatiana Cat", "Jinjer Cat", "Jan Bradbury", "Joseph Long", "Kit Demir", "Luke Keller", "Mo Subramani", "Patrick Murray",
		"Jimmy Gallagher", "Karen Nash-Perry",
		"Benjie Tambo", "Chloe Lyon", "Gabriela Torres", "Hugo Torres", "Javonte Ford", "Liam Thompson", "Mickey",
		"Donald Duffy", "Sam Mackenzie",
		"Gary Lowe", "Ian Davies", "Irene Weber", "Kristie Wallace",
		"Anne Bishop", "Kev Munro", "Nina Kraviz", "Takuya Ito", "Tom Rogers",
		"Townie", 
	])
	speakers.sort()
	
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
		"homecoming",
		"the beast"
	]
	quests.sort()
	
	var sounds = [
		"sfx_car_turn_on",
		"sfx_car_horn",
		"sfx_car_breaks",
		"sfx_car_accelerate",
		"sfx_car_blinker",
		"sfx_car_turn_off",
		"sfx_car_door_use",
		"sfx_magpie_caw",
		"ambient_town",
		"ambient_car",
		"sfx_door_use",
		"sfx_dog_bark",
		"sfx_cat_meow",
		"sfx_crossing_press",
		"sfx_crossing_pending",
		"sfx_crossing_go",
		"sfx_inventory_gain",
		"sfx_inventory_loss",
		"sfx_health_gain",
		"sfx_health_loss",
		"sfx_quest_new",
		"sfx_quest_progress"
	]
	sounds.sort()
	
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
				"signals": LintObject.Type.Signals(items, quests, skills, sounds),
			}))
		})
	)
