
func _init():
	var animations = ["idle", "talk", "interact", "walk", "run", "sleep"]
	var skills = [
		"impulse", "backbone", "finesse", "cool", "cursed",
		"chronicler", "savvy", "artificer", "earthling", "blood",
		"strange", "sharp", "dramaturgy", "domination", "empath"
	]
	var speakers = ["Narrator", "You"]
	speakers.append_array(skills)
	var npcs = [
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
	]
	npcs.sort()
	speakers.append_array(npcs)
	
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
		"sfx_footsteps_approach",
		"sfx_footsteps_leave",
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
	
