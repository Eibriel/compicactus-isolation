extends Node

var color_palette = {
	"logo_main_1": Color(1, 0, 0),
	"logo_secondary_1": Color(1, 1, 1)
}

var dictionary = {
	"past" : {
		"draw":[
			["circle", [0, 0], 20, 0],
			["circle", [-10, 0], 6, 1]
		]
	},
	"future" : {
		"draw":[
			["circle", [0, 0], 20, 0],
			["circle", [10, 0], 6, 1]
		]
	},
	"now" : {
		"draw":[
			["circle", [0, 0], 20, 0],
			["circle", [0, 10], 6, 1]
		]
	},
	"me" : {
		"draw":[
			["circle", [0, 0], 20, 0],
			["circle", [0, 0], 8, 1]
		]
	},
	"you": {
		"draw": [
			["circle", [0, 0], 20, 1],
			["circle", [0, 0], 8, 0]
		]
	},
	"happy": {
		"draw": [
			["circle", [0, 0], 20, 1],
			["circle", [0, -2], 19, 0]
		]
	},
	"sad": {
		"draw": [
			["circle", [0, -2], 20, 1],
			["circle", [0, 0], 19, 0]
		]
	}
}
