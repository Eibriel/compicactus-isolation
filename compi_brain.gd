extends Node
class_name CompiBrain

#
signal task_completed
# signal word_added
signal ending_reached
signal words_added


var current_scene = ""
var current_target = ""

# parametrizar deseos de la AI

# crear escenas con resultados esperables

# calcular que escena ejecutar dado el estado para maximizar el deseo de la AI

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
		return check_response(["unknown"])
	var selected_scene = select_one_scene(scene_values)
	var r = execute_scene(selected_scene.scene, selected_scene.target, selected_scene.parameters)
	return check_response(r)


func execute_scene(scene, target, parameters):
	print(scene, ":", target)
	current_scene = scene
	
	match scene:
		"answer_how_is_person":
			var person = parameters.person
			if GlobalValues.long_term.has(person) and GlobalValues.long_term[person].has("mood"):
				var mood = GlobalValues.long_term[person].mood
				return [person, mood]
			else:
				return [person, "unknown"]
	
		"answer_hello":
			set_task_completed("TASK_SAY_HI")
			if GlobalValues.long_term.compicactus.introduced == "yes" and !GlobalValues.long_term.player.has("mood"):
				return ["hello"]
			GlobalValues.long_term.compicactus.introduced = "yes"
			add_words(GlobalValues.tutorial_a)
			return ["player", "what?"]
		
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
	
		"answer_person_mood":
			var person = parameters.person
			var mood = parameters.mood
			if person != "compicactus":
				if GlobalValues.long_term.has(person):
					GlobalValues.long_term[person].mood = mood
					return [person, mood]
			else:
				return ["compicactus", GlobalValues.long_term["compicactus"].mood]
	
		"answer_person_place":
			var person = parameters.person
			var place = parameters.place
			if person != "compicactus":
				if GlobalValues.long_term.has(person):
					GlobalValues.long_term[person].location = place
					return [person, place]
			else:
				return ["compicactus", GlobalValues.long_term["compicactus"].location]
	
		"answer_person_socialrelation_number":
			var person = parameters.person
			var socialrelation = parameters.socialrelation
			var number = parameters.number
			if person != "compicactus":
				if GlobalValues.long_term.has(person):
					GlobalValues.long_term[person][socialrelation] = number
					return [person, socialrelation, number]
			else:
				return ["compicactus", socialrelation, GlobalValues.long_term["compicactus"][socialrelation]]
	
		"answer_person_socialrelation_question":
			var person = parameters.person
			var socialrelation = parameters.socialrelation
			if GlobalValues.long_term.has(person):
				if GlobalValues.long_term[person].has(socialrelation):
					var value = GlobalValues.long_term[person][socialrelation]
					return [person, socialrelation, value]
			else:
				return [person, socialrelation, "unknown"]
					
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
			return ["me", "compicactus"]
	
		"answer_player":
			return ["you", "player"]
	
		"answer_compicactus_purpose":
			return ["compicactus", "player", "help"]
	
	
		# Initiated by AI
		#"ask_to_time_travel":
		#	add_words(GlobalValues.tutorial_b)
		#	return ["compicactus", "capsule", "start", "?"]
	
		"locate":
			add_words(GlobalValues.tutorial_b)
			return ["player", "where?"]
		
		"say_hi":
			# long_term.compicactus.introduced = "yes"
			return ["hello"]
		
		"ask_how_are_you":
			return ["player", "what?"]
		
		"get_person_children_count":
			add_words(GlobalValues.tutorial_c)
			return ["player", "children", "how many?"]
	return ["unknown"]

func select_one_scene(scenes):
	return scenes[0]


func select_best_scenes(filtered_scenes):
	var scene_values = []
	for fscene in filtered_scenes:
		var value = 0
		for goal in GlobalValues.ai_goals:
			for g in GlobalValues.ai_goals[goal].goals:
				if fscene[1] == "":
					if GlobalValues.scenes[fscene[0]].expected.has(g):
						value+=1
				else:
					var wildcard_goal = "*.%s" % g.split(".")[1]
					if GlobalValues.scenes[fscene[0]].expected.has(wildcard_goal):
						value+=1
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
		if _instance == "":
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
	if value == "!unknown":
		if not GlobalValues.long_term[instance].has(property):
			return false
	if GlobalValues.long_term[instance].has(property) and GlobalValues.long_term[instance][property] != value:
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
	for scene in get_scenes_matching_with(words):
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
