extends Node
class_name CompiBrain

# The earth is in a nuclear winter
# you must go to the future to find a time
# where the planet is habitable again
# The AI Compicactus will asist you in the journey
# Good luck!

# Tasks:
# Enter capsule
# Start time travel
# Wait until the conditions are good
# Stop time travel
# * Keep moving forward
# * Shut down Compicactus
# * Go back to your time
# * Stay
# Send date to the past
# * Leave capsule

# If player stops travel early the date will be wrong
# Player can keep moving forward, or go back in time
# - 
# If player waits for conditions to be good the time machine will fail
# The player can stay with Compicactus (and future humans), or let Compicactus sacrify itself so the person can go back
# -
# If the player keeps going forward the player will find another nuclear winter
# Compicactus will run out of energy


signal task_completed
signal date_updated
signal word_added

var timelapse = false
var timelapse_time = 0
var timelapse_completed = false


var task_list: Dictionary = {
	"TASK_ENTER_CAPSULE": {"visible": true, "completed": true},
	"TASK_START_TIMETRAVEL": {"visible": true, "completed": false},
	"TASK_FIND_GOOD_CONDITIONS": {"visible": true, "completed": false},
	"TASK_STOP_TIMETRAVEL": {"visible": true, "completed": false},
	"TASK_KEEP_MOVING_FORWARD": {"visible": true, "completed": false},
	"TASK_SHUT_DOWN_COMPICACTUS": {"visible": true, "completed": false},
	"TASK_GO_BACK_IN_TIME": {"visible": true, "completed": false},
	"TASK_STAY_IN_FUTURE": {"visible": true, "completed": false},
	"TASK_SEND_DATA_PAST": {"visible": true, "completed": false},
	"TASK_LEAVE_CAPSULE": {"visible": true, "completed": false},
	#
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
			"place": {
				"device-place": {}
			},
			"device": {
				"device-place": {},
				"ai": {}
			}
		},
		"number":{},
		"mood":{}
	}
}

var long_term = {
	"compicactus": {
		"is-a": "ai",
		"location": "time-machine",
		"introduced": "no",
		"mood": "happy",
		"enabled": "true"
	},
	"presentworld": {
		"is-a": "place",
		"conditions": "bad"
	},
	"capsule": {
		"is-a": "device-place",
		"fuel-level": 100,
		"traveling": "no",
		"direction": "future"
	},
	
	"happy": {
		"is-a": "mood"
	},
	"sad": {
		"is-a": "mood"
	},
	"good": {
		"is-a": "mood"
	},
	"bad": {
		"is-a": "mood"
	},
	"player": {
		"is-a": "human"
	},
	"pastworld": {
		"is-a": "place",
	},
	"futureworld": {
		"is-a": "place",
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
	"answer_person_mood": {
		"match": "*person+*mood",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_start_device": {
		"match": "*device+start",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_stop_device": {
		"match": "*device+stop",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_compicactus": {
		"match": "compicactus",
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
	var filtered_scenes = select_scene(question, grounding)
	var scene_values = select_best_scenes(filtered_scenes)
	scene_values.sort_custom(MyCustomSorter, "sort")
	var selected_scene = select_one_scene(scene_values)
	var r = execute_scene(selected_scene.scene, selected_scene.target, selected_scene.parameters)
	return check_response(r)


func execute_scene(scene, target, parameters):
	print(scene, ":", target)
	current_scene = scene
	if scene == "answer_how_is_person":
		var person = parameters.person
		if long_term.has(person) and long_term[person].has("mood"):
			var mood = long_term[person].mood
			return [[person, mood], []]
		else:
			return [[person, "unknown"], []]
	
	elif scene == "answer_hello":
		return [["hello"], []]
		
	elif scene == "answer_number":
		var next_number = {
			"3": "2",
			"2": "1",
			"1": "0"
		}
		if next_number.has(parameters.number):
			return [[next_number[parameters.number]], []]
		else:
			return [["100"], []]
	
	elif scene == "answer_person_mood":
		var person = parameters.person
		var mood = parameters.mood
		if person != "compicactus":
			if long_term.has(person):
				long_term[person].mood = mood
				return [[person, mood], []]
		else:
			return [["compicactus", long_term["compicactus"].mood], []]
	
	elif scene == "answer_start_device":
		var device = parameters.device
		if device == "capsule":
			start_timetravel()
			task_list
			return [["ok"], []]
	
	elif scene == "answer_stop_device":
		var device = parameters.device
		if device == "capsule":
			stop_timetravel()
			return [["ok"], []]
	
	elif scene == "answer_compicactus":
		return [["what?"], []]
	
	# Initiated by AI
	elif scene == "locate":
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
		var info = {
			"value": value,
			"scene": fscene[0],
			"target": fscene[1],
			"parameters": {}
		}
		if fscene.size() > 2:
			info.parameters = fscene[2]
		scene_values.append(info)
			
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
			if question.size() > 0:
				var to_match = scenes[scene].match
				var split_match = to_match.split("+")
				var string_question = question_to_string(question, grounding)
				if string_question == to_match:
					filtered_scenes.append([scene, ""])
				else:
					var is_match = true
					var parameters = {}
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



func set_task_completed(task_name: String):
	if !task_list[task_name].completed:
		emit_signal("task_completed", task_name)
	task_list[task_name].completed = true


func get_task_list():
	return task_list


#func _process(delta):
#	update_date(delta)


func start_timetravel():
	timelapse = true


func stop_timetravel():
	timelapse = false


func update_date(delta: float):
	# var date: String = ""
	var time_dict = Time.get_datetime_dict_from_system()
	if timelapse:
		timelapse_time += delta
	# var exponential_timelapse_time = pow(timelapse_time, timelapse_time/10)
	var exponential_timelapse_time = timelapse_time*10000
	time_dict.year += int(exponential_timelapse_time/30/12)
	time_dict.month += int(exponential_timelapse_time/30) % 12
	if time_dict.month > 12:
		time_dict.month -= 12
	time_dict.day += int(exponential_timelapse_time) % 30
	if time_dict.day > 30:
		time_dict.day -= 30
	# if time_dict.year >= 3022:
	# 	timelapse_completed = true
	# 	timelapse = false
	#if timelapse_completed:
	#	time_dict.year += 1000
	# var date_format: String = "{year}/{month}/{day} {hour}:{minute}:{second}"
	var date_format: String = "{year}/{month}/{day}"
	var date_text = date_format.format({
		"year": time_dict.year,
		"month": "%02d" % time_dict.month,
		"day": "%02d" % time_dict.day,
		"hour": "%02d" % time_dict.hour,
		"minute": "%02d" % time_dict.minute,
		"second": "%02d" % time_dict.second,
	})
	emit_signal("date_updated", date_text)
