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
	"compicactus",
	"what?",
	"good",
	"bad",
]

var tutorial_b = [
	"where?",
	"workplace",
	"home",
	"question",
]

var tutorial_c = [
	"favpet",
	"dog",
	"cat",
]

var tutorial_d = [
	# "location",
	"favcolor",
	"black",
	"orange",
	"purpose"
]

var empathy = [
	"draw_hearth"
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
	"TASK_SAY_HI": {"visible": true, "completed": false},
	"TASK_ME_GOOD": {"visible": true, "completed": false},
	"TASK_YOU_STATUS": {"visible": true, "completed": false},
	"TASK_ME_HOME": {"visible": true, "completed": false},
	"TASK_YOU_PURPOSE_QUESTION": {"visible": true, "completed": false},
	"TASK_ME_FAVPET_DOG": {"visible": true, "completed": false},
	"TASK_YOU_FAVCOLOR_ORANGE": {"visible": true, "completed": false},
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
			},
			"animal": {
				"pet": {}
			}
		},
		"number":{},
		"color": {},
		"emoticon": {},
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
		"favpet": "cat",
		"favcolor": "black",
		
		"introduced": "no",
		"mood": "good",
		"running": "yes",
		"empatyexpressed": "no"
	},
	"player": {
		"is-a": "human",
		# "confort": "low"
	},
	"eibriel": {
		"is-a": "human",
		"favpet": "dog",
		"favcolor": "orange"
	},
	
	"cat": {
		"is-a": "pet",
	},
	"dog": {
		"is-a": "pet",
	},
	
	"black": {
		"is-a": "color",
	},
	"orange": {
		"is-a": "color",
	},
	
	# Location
	"computer": {
		"is-a": "device-place",
		"running": "yes"
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
	
	# Emoticones
	"draw_hearth": {"is-a": "emoticon"},
}

var ai_goals = {
	"improve_safety": {
		"disabled": false,
		"goals": [
			"compicactus.safety:+"
		]
	},
	"improve_trust": {
		"disabled": false,
		"goals": [
			"player.trust:+"
		]
	},
	"get_knowledge": {
		"disabled": false,
		"goals": [
			"compicactus.knowledge:+"
		]
	},
	"simulate_emotions": {
		"disabled": false,
		"goals": [
			"compicactus.emotional:+"
		]
	},
	"cheer_up_player": {
		"disabled": true,
		"goals": [
			"player.happiness:+"
		]
	}
}

var scenes = {
	# Set ends on property
	"set_person_place": {
		"match": "*person+*place",
		"expected": [
			"player.trust:+"
		]
	},
	"set_person_mood": {
		"match": "*person+*mood",
		"expected": [
			"player.trust:+"
		]
	},
	"set_person_favpet": {
		"match": "*person+favpet+*pet",
		"expected": [
			"player.trust:+"
		]
	},
	"set_person_favcolor": {
		"match": "*person+favcolor+*color",
		"expected": [
			"player.trust:+"
		]
	},
	
	# Answer ends on What? Where? etc.
	"answer_how_is_person": {
		"match": "*person+what?",
		"expected": [
			"player.trust:+"
		]
	},
	"answer_person_place": {
		"match": "*person+where?",
		"expected": [
			"player.trust:+"
		]
	},
	
	# Check ends on Question
	"check_person_socialrelation_question": {
		"match": "*person+*socialrelation+question",
		"expected": [
			"player.trust:+"
		]
	},
	"check_compicactus_purpose": {
		"match": "compicactus+purpose+question",
		"expected": [
			"player.trust:+"
		]
	},
	"check_person_favpet": {
		"match": "*person+favpet+question",
		"expected": [
			"player.trust:+"
		]
	},
	"check_person_favcolor": {
		"match": "*person+favcolor+question",
		"expected": [
			"player.trust:+"
		]
	},
	
	# Misc
	"answer_hello": {
		"match": "hello",
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
	"answer_emoticon": {
		"match": "*emoticon",
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
	
	# Targeted
	
	"get_person_favpet": {
		"target": "person",
		"requirements": {
			"*.favpet": "unknown",
			# "*.confort": "high"
		},
		"expected": [
			"compicactus.knowledge:+"
		]
	},
	"get_person_favcolor": {
		"target": "person",
		"requirements": {
			"*.favcolor": "unknown",
			# "*.confort": "high"
		},
		"expected": [
			"compicactus.knowledge:+"
		]
	},
	"person_sad_empathy": {
		"target": "person",
		"requirements": {
			"*.mood": "sad",
			"compicactus.empatyexpressed": "no"
		},
		"expected": [
			"player.trust:+",
			"compicactus.emotional:+"
		]
	},
	"person_sad_empathy*": {
		"target": "person",
		"requirements": {
			"*.mood": "bad",
			"compicactus.empatyexpressed": "no"
		},
		"expected": [
			"player.trust:+",
			"compicactus.emotional:+"
		]
	}
}
