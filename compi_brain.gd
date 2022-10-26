extends Node
class_name CompiBrain


# Where I am?
# Who are you?
# Why would you do that?
# Do you have family
# I want to see my family again!
# Send me to the future!
# I don't want to be here
# I don't want to answer questions

var concept_tree = {
	"root": {
		"object": {
			"person": {
				"ai": {},
				"human": {}
			}
		}
	}
}

var long_term = {
	"ai": {
		"is-a": "ai",
		"children_count": 2,
		# "location": "unknown",
		"safety": 0.1,
	},
	#"human": {
	#	"is-a": "human"
	#}
}

var current_scene = ""
var current_sub_scene = ""

var ai_goals = {
	"return_home": {
		"goals": [
			{"ai.location": "home"}
		]
	},
	"improve_safety": {
		"goals": [
			{"ai.safety": "+"}
		]
	},
}

var scenes = {
	"locate": {
		"requirements": {
			"ai.location": "unknown"
		},
		"expected": {
			# "ai.location": "!unknown",
			"ai.safety": "+"
		}
	},
	"get_person_children_count": {
		"target": "person",
		"requirements": {
			"*.children_count": "unknown",
			"*.confort": "high"
		},
		"expect": {
			"*.trust": "+"
		}
	}
}

# parametrizar deseos de la AI

# crear escenas con resultados esperables

# calcular que escena ejecutar dado el estado para maximizar el deseo de la AI



func parse(question: PoolStringArray, grounding: PoolStringArray):
	select_scene()
	return [[],[]]
	"""
	var answer:PoolStringArray = []
	var next_grounding: PoolStringArray = []
	if should_ignore():
		return ask_question()
	if is_empty_question(question):
		return [answer, next_grounding]
	if is_who_question(question):
		var target: String = get_who_target(question)
		return check_response(short_description(target))
	#
	return check_response([
		answer,
		next_grounding
	])"""


func select_scene():
	# simulate scenes
	for scene in scenes:
		if scenes[scene].has("target"):
			var collected_concepts = get_all_concepts_child_of(scenes[scene].target, concept_tree)
			for cc in collected_concepts:
				var collected_instances = get_all_instances_isa(cc)
				for ci in collected_instances:
					var satisfied = satisfy_requirements(scene, ci)
					print("scene: ", scene, " target: ", ci, " -> ", satisfied)
		else:
			var satisfied = satisfy_requirements(scene)
			print("scene: ", scene, " -> ", satisfied)

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
