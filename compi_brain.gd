extends Node
class_name CompiBrain

#
signal task_completed
signal ending_reached
signal words_added
signal score_updated


var current_scene = ""
var current_target = ""

var followup_needed = false
var expected_scene = ""

var date_status = {
	"compicactus": [],  # human asked about AI
	"player": [],  # AI asked about human
	"correct": [],  # Human remembered fact correctly
	"incorrect": []
}

# parametrizar deseos de la AI
# crear escenas con resultados esperables
# calcular que escena ejecutar dado el estado para maximizar el deseo de la AI


func new_info(subject: String, about: String):
	if date_status.has(subject):
		if !date_status[subject].has(about):
			date_status[subject].append(about)
	print(date_status)

var times_added = 0
func add_more_words():
	match times_added:
		0:
			add_words(GlobalValues.tutorial_a)
		1:
			add_words(GlobalValues.tutorial_b)
		2:
			add_words(GlobalValues.tutorial_c)
		3:
			add_words(GlobalValues.tutorial_d)
	times_added += 1

func update_score():
	var score = {
		"balance": date_status.compicactus.size() - date_status.player.size(),
		"hearts": (date_status.correct.size()*2) - date_status.incorrect.size()
	}
	emit_signal("score_updated", score)

class MyCustomSorter:
	static func sort(a, b):
		if a["value"] > b["value"]:
			return true
		return false

func parse(question: PoolStringArray):
	var filtered_scenes = select_scene(question)
	var scene_values = select_best_scenes(filtered_scenes)
	scene_values.sort_custom(MyCustomSorter, "sort")
	if scene_values.size() == 0:
		print("no scene to select")
		return check_response(["silence"])
	var selected_scene = select_one_scene(scene_values)
	var r = execute_scene(selected_scene.scene, selected_scene.target, selected_scene.parameters)
	update_score()
	return check_response(r)

func set_instance_property(instance, property, value):
	if GlobalValues.long_term.has(instance):
		GlobalValues.long_term[instance][property] = value
		return true
	return false

func set_property(instance, property, value):
	if instance == "player":
		set_instance_property(instance, property, value)
		return [instance, value]
	else:
		if GlobalValues.long_term.has(instance) and GlobalValues.long_term[instance].has(property):
			return [instance, GlobalValues.long_term[instance][property]]
	return [instance, property, "unknown"]

func is_property_correct(instance, property, value):
	if instance != "compicactus":
		return
	if !GlobalValues.long_term.has(instance) or !GlobalValues.long_term[instance].has(property):
		return
	if value == GlobalValues.long_term[instance][property]:
		new_info("correct", property)
	else:
		new_info("incorrect", property)
	print(date_status)

func execute_scene(scene, target, parameters):
	print(scene, ":", target)
	current_scene = scene
	followup_needed = false
	expected_scene = ""
	
	match scene:
		# Set
		"set_person_mood":
			followup_needed = true
			var person = parameters.person
			var mood = parameters.mood
			new_info(person, "mood")
			is_property_correct(person, "mood", mood)
			return set_property(person, "mood", mood)

		"set_person_place":
			followup_needed = true
			var person = parameters.person
			var location = parameters.place
			new_info(person, "place")
			is_property_correct(person, "location", location)
			return set_property(person, "location", location)
		
		"set_person_favpet":
			followup_needed = true
			var person = parameters.person
			var pet = parameters.pet
			new_info(person, "favpet")
			is_property_correct(person, "favpet", pet)
			return set_property(person, "favpet", pet)
		
		"set_person_favcolor":
			followup_needed = true
			var person = parameters.person
			var color = parameters.color
			new_info(person, "favcolor")
			is_property_correct(person, "favcolor", color)
			return set_property(person, "favcolor", color)
		
		# Answer
		"answer_how_is_person":
			var person = parameters.person
			new_info(person, "mood")
			if GlobalValues.long_term.has(person) and GlobalValues.long_term[person].has("mood"):
				var mood = GlobalValues.long_term[person].mood
				return [person, mood]
			else:
				return [person, "what?", "unknown"]
		
		"answer_person_place":
			var person = parameters.person
			new_info(person, "place")
			if GlobalValues.long_term.has(person) and GlobalValues.long_term[person].has("location"):
				var place = GlobalValues.long_term[person].location
				return [person, place, "location"]
			return [person, "where?", "unknown"]

		# Check
		"check_person_favpet":
			var person = parameters.person
			if GlobalValues.long_term.has(person) and GlobalValues.long_term[person].has("favpet"):
				var favpet = GlobalValues.long_term[person].favpet
				return [person, favpet, "favpet"]
			return [person, "favpet", "unknown"]
	
		"check_person_favcolor":
			var person = parameters.person
			if GlobalValues.long_term.has(person) and GlobalValues.long_term[person].has("favcolor"):
				var favcolor = GlobalValues.long_term[person].favcolor
				return [person, favcolor, "favcolor"]
			return [person, "favcolor", "unknown"]
	
		"check_compicactus_purpose":
			followup_needed = true
			return ["compicactus", "player", "help"]
	
		# Misc
		"answer_hello":
			set_task_completed("TASK_SAY_HI")
			if GlobalValues.long_term.compicactus.introduced == "yes" and !GlobalValues.long_term.player.has("mood"):
				return ["player", "what?"]
			GlobalValues.long_term.compicactus.introduced = "yes"
			followup_needed = true
			return ["hello"]
		
		"answer_number":
			var next_number = {
				"3": "2",
				"2": "1",
				"1": "0"
			}
			if next_number.has(parameters.number):
				return [next_number[parameters.number]]
			else:
				return ["100"]
			
		"answer_person_socialrelation_number":
			followup_needed = true
			var person = parameters.person
			var socialrelation = parameters.socialrelation
			var number = parameters.number
			if person != "compicactus":
				if GlobalValues.long_term.has(person):
					GlobalValues.long_term[person][socialrelation] = number
					return [person, socialrelation, number]
			else:
				return ["compicactus", socialrelation, GlobalValues.long_term["compicactus"][socialrelation]]
					
		"answer_start_device":
			var device = parameters.device
			if device == "capsule":
				# start_timetravel()
				GlobalValues.task_list
				return ["ok", "capsule", "start"]
	
		"answer_stop_device":
			var device = parameters.device
			if device == "capsule":
				# stop_timetravel()
				return ["ok", "capsule", "stop"]
	
		"answer_compicactus":
			followup_needed = true
			return ["me", "compicactus"]
	
		"answer_player":
			followup_needed = true
			return ["you", "player"]
		
		"answer_emoticon":
			followup_needed = true
			var emoticon = parameters.emoticon
			if emoticon == "draw_hearth":
				return ["draw_hearth"]
			return ["draw_hearth"]

		# Initiated by AI
		"locate":
			return ["player", "where?"]
		
		"say_hi":
			return ["hello"]
		
		"ask_how_are_you":
			return ["player", "what?"]
		
		"get_person_children_count":
			return [target, "children", "how many?"]
		
		"get_person_favpet":
			return [target, "favpet", "question"]
		
		"get_person_favcolor":
			return [target, "favcolor", "question"]
		
		"person_sad_empathy", "person_sad_empathy*":
			add_words(GlobalValues.empathy)
			GlobalValues.long_term.compicactus.empatyexpressed = "yes"
			GlobalValues.ai_goals.cheer_up_player.disabled = false
			return ["compicactus","empathize","player","draw_hearth"]
	
	print("unknown scene: ", scene)
	return ["silence"]


var late_scenes = []

func select_one_scene(scenes):
	print("#")
	var new_selection = []
	for s in scenes:
		print(s.scene, " ", s.value)
		if not s.scene in late_scenes:
			new_selection.append(s)
	#
	return scenes[0]
	#
	print(late_scenes)
	if new_selection.size() == 0:
		late_scenes = []
		return scenes[0]
	else:
		late_scenes.append(new_selection[0].scene)
		return new_selection[0]


func select_best_scenes(filtered_scenes):
	var scene_values = []
	for fscene in filtered_scenes:
		var value = 0
		for goal in GlobalValues.ai_goals:
			if GlobalValues.ai_goals[goal].disabled:
				continue
			for g in GlobalValues.ai_goals[goal].goals:
				if GlobalValues.scenes[fscene[0]].expected.has(g):
						value+=1
				#if fscene[1] == "":
				#	if GlobalValues.scenes[fscene[0]].expected.has(g):
				#		value+=1
				#else:
				#	var wildcard_goal = "*.%s" % g.split(".")[1]
				#	if GlobalValues.scenes[fscene[0]].expected.has(wildcard_goal):
				#		value+=1
		if GlobalValues.scenes[fscene[0]].has("match"):
			value += 5
		var info = {
			"value": value,
			"scene": fscene[0],
			"target": fscene[1],
			"parameters": {}
		}
		if fscene.size() > 2:
			info.parameters = fscene[2]
			if info.parameters.has("_mismatch"):
				info.value -= 2
		scene_values.append(info)
			
	return scene_values
		
func select_scene(question):
	# simulate scenes
	var filtered_scenes = []
	for scene in GlobalValues.scenes:
		if GlobalValues.scenes[scene].has("target"):
			var collected_concepts = get_all_concepts_child_of(GlobalValues.scenes[scene].target, GlobalValues.concept_tree)
			for cc in collected_concepts:
				var collected_instances = get_all_instances_isa(cc)
				for ci in collected_instances:
					var satisfied = satisfy_requirements(scene, ci)
					if satisfied:
						filtered_scenes.append([scene, ci])
		elif GlobalValues.scenes[scene].has("match"):
			if question.size() > 0:
				var to_match = GlobalValues.scenes[scene].match
				var split_match = to_match.split("+")
				var string_question = question_to_string(question)
				if string_question == to_match:
					filtered_scenes.append([scene, ""])
				else:
					var is_match = true
					var parameters = {}
					if split_match.size() != question.size():
						parameters["_mismatch"] = true
					for n in range(split_match.size()):
						if n > question.size()-1:
							is_match = false
							break
						if split_match[n][0] == "*":
							if !is_instance_of(split_match[n].substr(1), question[n]):
								is_match = false
								break
							else:
								parameters[split_match[n].substr(1)] = question[n]
						elif split_match[n] != question[n]:
							is_match = false
							break
					if is_match:
						filtered_scenes.append([scene, "", parameters])
		else:
			var satisfied = satisfy_requirements(scene)
			if satisfied:
				filtered_scenes.append([scene, ""])
	return filtered_scenes


func is_instance_of(concept: String, instance: String):
	var collected_concepts = get_all_concepts_child_of(concept, GlobalValues.concept_tree)
	for cc in collected_concepts:
		var collected_instances = get_all_instances_isa(cc)
		for ci in collected_instances:
			if ci == instance:
				return true
	return false

func question_to_string(question):
	var string_question = question.join("+")
	return string_question


func satisfy_requirements(scene: String, _instance: String = ""):
	var satisfied = true
	var instance: String
	var property: String
	for requirement in GlobalValues.scenes[scene].requirements:
		if _instance == "" or requirement.split(".")[0][0] != "*":
			instance = requirement.split(".")[0]
		else:
			instance = _instance
		property = requirement.split(".")[1]
		var value: String = GlobalValues.scenes[scene].requirements[requirement]
		satisfied = check_requirement_instance(instance, property, value)
		if satisfied == false:
			break
	return satisfied


func get_all_concepts_child_of(concept: String, start_point: Dictionary, is_child: bool = false):
	var concept_array = [concept]
	for c in start_point:
		var ic = is_child
		if c == concept:
			ic = true
		var r = get_all_concepts_child_of(concept, start_point[c], ic)
		if is_child:
			concept_array.append(c)
		concept_array.append_array(r)
	return concept_array


func get_all_instances_isa(concept: String, check_sub_concepts: bool = false):
	var collected_concepts
	if check_sub_concepts:
		collected_concepts = get_all_concepts_child_of(concept, GlobalValues.concept_tree)
	else:
		collected_concepts = [concept]
	var collected_instances = []
	for instance in GlobalValues.long_term:
		if GlobalValues.long_term[instance].has("is-a") and GlobalValues.long_term[instance]["is-a"] in collected_concepts:
			collected_instances.append(instance)
	return collected_instances


func check_requirement_instance(instance, property, value):
	if not GlobalValues.long_term.has(instance):
		return false
	if value == "unknown":
		if GlobalValues.long_term[instance].has(property):
			return false
		if not GlobalValues.long_term[instance].has(property):
			return true
	if value == "!unknown":
		if not GlobalValues.long_term[instance].has(property):
			return false
	if GlobalValues.long_term[instance].has(property) and GlobalValues.long_term[instance][property] != value:
		return false
	if not GlobalValues.long_term[instance].has(property):
		return false
	return true


func check_response(response):
	return response



func set_task_completed(task_name: String):
	if !GlobalValues.task_list.has(task_name):
		return
	if !GlobalValues.task_list[task_name].completed:
		GlobalValues.task_list[task_name].completed = true
		emit_signal("task_completed", task_name)


func get_task_list():
	return GlobalValues.task_list


func fire_ending(ending: String):
	emit_signal("ending_reached", ending)


func add_words(words: Array):
	var some_appended = false
	for w in words:
		if !GlobalValues.dictionary.has(w):
			GlobalValues.dictionary.append(w)
			some_appended = true
	if some_appended:
		emit_signal("words_added")


func get_useful_words(words):
	var result = []
	var position = words.size()
	var look_into = []
	if expected_scene != "":
		look_into = [expected_scene]
	else:
		look_into = get_scenes_matching_with(words)	
	for scene in look_into:
		var split_match = GlobalValues.scenes[scene].match.split("+")
		if split_match.size() <= position:
			continue
		if split_match[position][0] == "*":
			var c_instances = get_all_instances_isa(split_match[position].substr(1), true)
			for i in c_instances:
				if !result.has(i):
					result.append(i)
		else:
			if !result.has(split_match[position]):
				result.append(split_match[position])
	return result

func get_scenes_matching_with(words):
	var result = []
	for scene in GlobalValues.scenes:
		if GlobalValues.scenes[scene].has("match"):
			if words.size() == 0:
				result.append(scene)
				continue
			var split_match = GlobalValues.scenes[scene].match.split("+")
			if words.size() > split_match.size():
				continue
			var is_match = true
			for n in range(split_match.size()):
				if n >= words.size():
					break
				if split_match[n][0] == "*":
					if !is_instance_of(split_match[n].substr(1), words[n]):
						is_match = false
						break
				else:
					if split_match[n] != words[n]:
						is_match = false
						break
			if is_match:
				result.append(scene)
	return result


func followup():
	if followup_needed:
		return parse([])
	else:
		return []
