extends Node

var color_palette = {
	"logo_main_1": Color(1, 0, 0),
	"logo_secondary_1": Color(1, 1, 1)
}

var dictionary = [
	"hello"
]

var tutorial_a = [
	"player",
	"happy",
	"sad",
	"good",
	"bad",
]

var tutorial_b = [
	"workplace",
	"home"
]

var tutorial_c = [
	"compicactus",
	"children",
	"question",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
]

var more = [
	"-",
	#"#1",
	#"#2",
	"compicactus",
	"player",
	# "me",
	# "you",
	# Questions
	#"question",
	#"start",
	#"stop",
	"capsule",
	"purpose",
	#"set",
	#"forward",
	#"backward",
	"what?",
	"hello",
	#"who?",
	# Yes/no
	#"yes",
	#"no",
	#"unknown",
	# Time
	#"past",
	#"future",
	#"now",
	#"year",
	# Adjetives
	"happy",
	"sad",
	"good",
	"bad",
	# Verbs
	#"help",
	# Adverb?
	#"must",
	# Things
	# Concepts
	#"ai",
	#"human",
	# Numbers
]


var task_list: Dictionary = {
	"TASK_ENTER_CAPSULE": {"visible": true, "completed": true},
	"TASK_SAY_HI": {"visible": true, "completed": false},
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
		"mood":{},
		"quality": {},
		"socialrelation":{}
	}
}

var long_term = {
	# Characters
	"compicactus": {
		"is-a": "ai",
		"location": "computer",
		"children": 0,
		
		"introduced": "no",
		"mood": "happy",
		"enabled": "true"
	},
	"player": {
		"is-a": "human"
	},
	
	# Location
	"computer": {
		"is-a": "device-place",
		"fuel-level": "high",
		"traveling": "no",
		"direction": "forward"
	},
	
	# Places
	"workplace": {
		"is-a": "place",
	},
	"home": {
		"is-a": "place",
	},
	
	"purpose": {
		"is-a": "quality"
	},
	
	# Social Relation
	"children": {
		"is-a": "socialrelation"
	},
	
	# Moods
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
	
	# Numbers
	"0": {"is-a": "number"},
	"1": {"is-a": "number"},
	"2": {"is-a": "number"},
	"3": {"is-a": "number"},
	"4": {"is-a": "number"},
	"5": {"is-a": "number"},
	"6": {"is-a": "number"},
	"7": {"is-a": "number"},
	"8": {"is-a": "number"},
	"9": {"is-a": "number"},
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
	"complete_task": {
		"goals": [
			"compicactus.knowledge:+"
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
	"answer_person_place": {
		"match": "*person+*place",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_person_socialrelation_number": {
		"match": "*person+*socialrelation+*number",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_person_socialrelation_question": {
		"match": "*person+*socialrelation+question",
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
		"match": "*person+*device+start",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_stop_device": {
		"match": "*person+*device+stop",
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
	"answer_player": {
		"match": "player",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_capsule": {
		"match": "capsule",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_compicactus_purpose": {
		"match": "compicactus+purpose",
		"expected": [
			"player.trust:+"
		]
	},
	
	# Self prompted
	
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
			"player.location": "unknown"
		},
		"expected": [
			"compicactus.knowledge:+"
		]
	},
	"get_person_children_count": {
		"target": "person",
		"requirements": {
			"*.children": "unknown",
			"*.confort": "high"
		},
		"expected": [
			"compicactus.knowledge:+"
		]
	}
}
