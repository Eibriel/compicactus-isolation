extends Node
class_name CompiBrain

var task_list: Dictionary = {
	"TASK_START_TIMETRAVEL": {"visible": true, "completed": true},
	"TASK_SAY_HI": {"visible": true, "completed": false},
	"TASK_COUNTDOWN": {"visible": true, "completed": false},
	"TASK_ARE_YOU_ALIVE": {"visible": true, "completed": false},
}

var concept_tree = {
	"root": {
		"object": {
			"person": {
				"ai": {},
				"human": {}
			},
			"place": {},
			"device": {}
		},
		"number":{}
	}
}

var long_term = {
	"compicactus": {
		"is-a": "ai",
		"location": "time-machine",
		"introduced": "no",
	},
	"player": {
		"is-a": "human"
	},
	"futureworld": {
		"is-a": "place",
	},
	"time-machine": {
		"is-a": "device"
	},
	"1": {
		"is-a": "number"
	},
	"2": {
		"is-a": "number"
	},
	"3": {
		"is-a": "number"
	}
}

var ai_goals = {
	#"return_home": {
	#	"goals": [
	#		"compicactus.location:home"
	#	]
	#},
	"improve_safety": {
		"goals": [
			"compicactus.safety:+"
		]
	},
	"improve_trust": {
		"goals": [
			"player.trust:+"
		]
	},
}

var scenes = {
	"answer_how_is_person": {
		"match": "*person+what?",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_hello": {
		"match": "hello",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_number": {
		"match": "*number",
		"expected": [
			"player.trust:+"
		]
	},
	
	"say_hi": {
		"requirements": {
			"compicactus.introduced": "no"
		},
		"expected": [
			"player.trust:+"
		]
	},
	"ask_how_are_you": {
		"requirements": {
			"player.mood": "unknown"
		},
		"expected": [
			"player.trust:+"
		]
	},
	"locate": {
		"requirements": {
			"compicactus.location": "unknown"
		},
		"expected": [
			"compicactus.safety:+"
		]
	},
	"get_person_children_count": {
		"target": "person",
		"requirements": {
			"*.children_count": "unknown",
			"*.confort": "high"
		},
		"expected": [
			"*.trust:+"
		]
	}
}



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

func parse(question: PoolStringArray, grounding: PoolStringArray):
	#
	#var answer = parse_input(question, grounding)
	#if answer.direct_answer:
	#	return check_response(answer.answer)
	#
	var filtered_scenes = select_scene(question, grounding)
	var scene_values = select_best_scenes(filtered_scenes)
	scene_values.sort_custom(MyCustomSorter, "sort")
	# print (scene_values)
	var selected_scene = select_one_scene(scene_values)
	var r = execute_scene(selected_scene.scene, selected_scene.target)
	return check_response(r)


func execute_scene(scene, target):
	print(scene, ":", target)
	current_scene = scene
	if scene == "locate":
		return [["compicactus", "where?"], []]
	if scene == "say_hi":
		long_term.compicactus.introduced = "yes"
		return [["hello"], []]
	if scene == "ask_how_are_you":
		return [["player", "what?"], []]
	return [["unknown"], []]

func select_one_scene(scenes):
	return scenes[0]


func select_best_scenes(filtered_scenes):
	var scene_values = []
	for fscene in filtered_scenes:
		var value = 0
		for goal in ai_goals:
			for g in ai_goals[goal].goals:
				if fscene[1] == "":
					if scenes[fscene[0]].expected.has(g):
						value+=1
				else:
					var wildcard_goal = "*.%s" % g.split(".")[1]
					if scenes[fscene[0]].expected.has(wildcard_goal):
						value+=1
		if scenes[fscene[0]].has("match"):
			value += 5
		scene_values.append({
			"value": value,
			"scene": fscene[0],
			"target": fscene[1]
		})
	return scene_values
		
func select_scene(question, grounding):
	# simulate scenes
	var filtered_scenes = []
	for scene in scenes:
		if scenes[scene].has("target"):
			var collected_concepts = get_all_concepts_child_of(scenes[scene].target, concept_tree)
			for cc in collected_concepts:
				var collected_instances = get_all_instances_isa(cc)
				for ci in collected_instances:
					var satisfied = satisfy_requirements(scene, ci)
					if satisfied:
						filtered_scenes.append([scene, ci])
		elif scenes[scene].has("match"):
			var to_match = scenes[scene].match
			var split_match = to_match.split("+")
			var string_question = question_to_string(question, grounding)
			if string_question == to_match:
				filtered_scenes.append([scene, ""])
			elif question.size() > 0:
				var is_match = true
				for n in range(split_match.size()):
					if split_match[n][0] == "*":
						if !is_instance_of(split_match[n].substr(1), question[n]):
							is_match = false
							break
					elif split_match[n] != question[n]:
						is_match = false
						break
				if is_match:
					filtered_scenes.append([scene, ""])
		else:
			var satisfied = satisfy_requirements(scene)
			if satisfied:
				filtered_scenes.append([scene, ""])
	return filtered_scenes


func is_instance_of(concept: String, instance: String):
	var collected_concepts = get_all_concepts_child_of(concept, concept_tree)
	for cc in collected_concepts:
		var collected_instances = get_all_instances_isa(cc)
		for ci in collected_instances:
			if ci == instance:
				return true
	return false

func question_to_string(question, grounding):
	var string_question = question.join("+")
	return string_question


func satisfy_requirements(scene: String, _instance: String = ""):
	var satisfied = true
	var instance: String
	var property: String
	for requirement in scenes[scene].requirements:
		if _instance == "":
			instance = requirement.split(".")[0]
		else:
			instance = _instance
		property = requirement.split(".")[1]
		var value: String = scenes[scene].requirements[requirement]
		satisfied = check_requirement_instance(instance, property, value)
		if satisfied == false:
			break
	return satisfied


func get_all_concepts_child_of(concept: String, start_point: Dictionary, is_child: bool = false):
	var concept_array = []
	for c in start_point:
		var ic = is_child
		if c == concept:
			ic = true
		var r = get_all_concepts_child_of(concept, start_point[c], ic)
		if is_child:
			concept_array.append(c)
		concept_array.append_array(r)
	return concept_array


func get_all_instances_isa(concept: String):
	var collected_instances = []
	for instance in long_term:
		if long_term[instance].has("is-a") and long_term[instance]["is-a"] == concept:
			collected_instances.append(instance)
	return collected_instances


func check_requirement_instance(instance, property, value):
	if not long_term.has(instance):
		return false
	if value == "unknown":
		if long_term[instance].has(property):
			return false
	if value == "!unknown":
		if not long_term[instance].has(property):
			return false
	if long_term[instance].has(property) and long_term[instance][property] != value:
		return false
	return true


func check_response(response):
	return response


# Parse input

var answers = {
	"compicactus+what?": {"answer": [["compicactus","good"], []]},
	"hello": {"answer": [["hello"], []], "complete_task": "TASK_SAY_HI"},
	"3": {"answer": [["2"], []]},
	"2": {"answer": [["1"], []]},
	"1": {"answer": [["0"], []]},
	
	"player+good": {"set": {"player":{"mood":"good"}}}
}

func parse_input(question, grounding):
	var string_question = question.join("+")
	var result = {
		"direct_answer": false,
		"answer": []
	}	
	if answers.has(string_question):
		if answers[string_question].has("answer"):
			result.direct_answer = true
			result.answer = answers[string_question].answer
		if answers[string_question].has("set"):
			for instance in answers[string_question].set:
				for property in answers[string_question].set[instance]:
					long_term[instance][property] = answers[string_question].set[instance][property]
		if answers[string_question].has("complete_task"):
			task_list[answers[string_question].complete_task].completed = true
	return result


func get_task_list():
	return task_list


# OLD

func is_empty_question(question: PoolStringArray):
	return question.size() == 0


func is_who_question(question):
	return question.size() > 1 and question[question.size()-1] == "who?"


func get_who_target(question):
	var target_word = question[question.size()-2]
	
	var mapping = {
		"ai": "ai",
		"you": "ai",
		"human": "human",
		"me": "human"
	}
	
	if mapping.has(target_word):
		return mapping[target_word]
	else:
		return target_word


func short_description(target):
	var answer:PoolStringArray = []
	var next_grounding: PoolStringArray = []
	
	if target == "ai":
		answer.append("me")
	elif target == "human":
		answer.append("you")
	else:
		answer.append(target)
		
	if in_longterm(target):
		var prop = long_term[target]["is-a"][0]
		answer.append(prop)
	else:
		answer.append("unknown")
		
	return check_response([
		answer,
		next_grounding
	])


func in_longterm(target):
	return long_term.has(target)


func should_ignore():
	return true


func ask_question():
	return check_response([
		["you", "who?"],
		[]
	])
