extends Control

var concept_theme = load("res://themes/concept_button.tres")
var compi_brain = load("res://compi_brain.gd").new()

onready var intro_animation: AnimationPlayer = $LogoStart/AnimationPlayer

onready var description_label: Label = $GeneratedTextNode2D/GeneratedLabel2
onready var logostart: Node2D = $LogoStart
onready var ok_button: Area2D = $OkArea2D
onready var date_text: Label = $DateText
onready var intro_text: Label = $IntroText
onready var shader_animation: AnimationPlayer = $CanvasLayer/AnimationPlayer
onready var compicactus_animation: AnimationPlayer = $Compicactus/AnimationPlayer
onready var compicactus: Node2D = $Compicactus

onready var robot_dialogue: VBoxContainer = $RobotDialogue
onready var grounding_dialogue: VBoxContainer = $Grounding
onready var human_dialogue: VBoxContainer = $HumanDialogue
onready var concept_tree: Tree = $Tree
onready var send_button: Button = $SendButton

onready var tasks: Control = $Tasks
onready var tasks_button: Button = $TasksButton
onready var help: Control = $Help
onready var help_button: Button = $HelpButton
onready var help_text: RichTextLabel = $Help/HelpText
onready var language_container: VBoxContainer = $Languages

var timelapse = false
var timelapse_time = 0
var timelapse_completed = false

var quick_start = true

var current_concept: String = "-"

var human_concepts: PoolStringArray = []
var human_buttons = []

var grounding_concepts: PoolStringArray = []
var grounding_buttons = []

var robot_buttons = []

var languages = [
	["en", "English"],
	["es", "Español"]
]

func _ready():
	description_label.text = ""
	send_button.visible = false
	tasks_button.visible = false
	help_button.visible = false
	for lang in languages:
		var b = Button.new()
		b.theme = concept_theme
		b.text = lang[1]
		language_container.add_child(b)
		b.connect("button_up", self, "_on_LanguageButton_button_up", [lang[0]])


func _on_LanguageButton_button_up(lang: String):
	TranslationServer.set_locale(lang)
	language_container.visible = false
	start_game()


func start_game():
	send_button.connect("button_up", self, "_on_SendButton_button_up", [])
	tasks_button.connect("button_up", self, "_on_TasksHelpButton_button_up", ["Tasks"])
	help_button.connect("button_up", self, "_on_TasksHelpButton_button_up", ["Help"])
	tasks.connect("gui_input", self, "_on_TasksHelp_gui_input", ["Tasks"])
	help.connect("gui_input", self, "_on_TasksHelp_gui_input", ["Help"])
	if not quick_start:
		intro_animation.play("Intro")
		var anim = compicactus_animation.get_animation("IdleHappy")
		anim.set_loop(true)
	else:
		ok_button.visible = false
		intro_text.visible = false
		logostart.visible = false
		timelapse_completed = true
		compicactus.modulate = Color(1, 1, 1, 1)
		show_game()
	compicactus_animation.play("IdleHappy")
	set_language()
	

func set_language():
	tasks_button.text = tr("TASKS")
	help_text.bbcode_text = tr("HELP_TEXT")
	intro_text.text = tr("INTRO_TEXT")
	send_button.text = tr("SEND")


func activate_ok_button():
	ok_button.connect("input_event", self, "_on_Ok_input_event", [])
	tasks.visible = true
	tasks_button.visible = true
	help_button.visible = true


func show_game():
	send_button.visible = true
	tasks_button.visible = true
	help_button.visible = true
	# Add buttons to chat
	robot_dialogue.add_child(HSeparator.new())
	human_dialogue.add_child(HSeparator.new())
	grounding_dialogue.add_child(HSeparator.new())
	for n in range(8):
		# Robot
		var b = Button.new()
		b.text = "-"
		b.flat = true
		b.theme = concept_theme
		robot_dialogue.add_child(b)
		robot_dialogue.add_child(HSeparator.new())
		robot_buttons.append(b)
		
		# Human
		b = Button.new()
		b.text = "-"
		b.flat = true
		b.theme = concept_theme
		b.connect("button_up", self, "_on_HumanButton_button_up", [n])
		human_dialogue.add_child(b)
		human_dialogue.add_child(HSeparator.new())
		human_buttons.append(b)
		human_concepts.append("-")
		
		# Grounding
		b = Button.new()
		b.flat = true
		b.theme = concept_theme
		if n==0:
			b.text = "#1"
			b.disabled = true
		elif n == 4:
			b.text = "#2"
			b.disabled = true
		else:
			b.text = "-"
			grounding_buttons.append(b)
			grounding_concepts.append("-")
			b.connect("button_up", self, "_on_GroundingButton_button_up", [grounding_buttons.size()-1])
		grounding_dialogue.add_child(b)
		grounding_dialogue.add_child(HSeparator.new())
		
	# Fill Keyboard
	concept_tree.theme = concept_theme
	var root_concept = concept_tree.create_item()
	concept_tree.set_hide_root(true)
	
	concept_tree.connect("cell_selected", self, "_on_Tree_cell_selected", [])
	
	# var n: int = 0
	for c in GlobalValues.dictionary:
		var concept_item = concept_tree.create_item(root_concept)
		concept_item.set_text(0, tr("WORD_%s" % c))
		concept_item.set_metadata(0, c)


func _on_Tree_cell_selected():
	current_concept = concept_tree.get_selected().get_metadata(0) #.get_text(0)
	description_label.text = tr("WORD_%s_DES" % current_concept) # GlobalValues.dictionary[current_concept].description


func _on_HumanButton_button_up(button_id: int):
	if button_id > 0 and human_concepts[button_id-1] == "-":
		return
	human_concepts[button_id] = current_concept
	var button: Button = human_buttons[button_id]
	button.text = tr("WORD_%s" % current_concept)


func _on_GroundingButton_button_up(button_id: int):
	if button_id > 0 and grounding_concepts[button_id-1] == "-":
		return
	grounding_concepts[button_id] = current_concept
	var button: Button = grounding_buttons[button_id]
	button.text = tr("WORD_%s" % current_concept)


func _on_Ok_input_event(_viewport, event, _node_idx):
	if event is InputEventScreenTouch and event.is_pressed():
		ok_button.visible = false
		intro_text.visible = false
		logostart.visible = false
		timelapse = true
		shader_animation.play("Timelapse")


func _process(delta: float):
	update_date(delta)


func update_date(delta: float):
	# var date: String = ""
	var time_dict = Time.get_datetime_dict_from_system()
	if timelapse:
		timelapse_time += delta
		var exponential_timelapse_time = pow(timelapse_time, timelapse_time/2)
		time_dict.year += int(exponential_timelapse_time/30/12)
		time_dict.month += int(exponential_timelapse_time/30) % 12
		if time_dict.month > 12:
			time_dict.month -= 12
		time_dict.day += int(exponential_timelapse_time) % 30
		if time_dict.day > 30:
			time_dict.day -= 30
		if time_dict.year >= 3022:
			timelapse_completed = true
			timelapse = false
	if timelapse_completed:
		time_dict.year += 1000
	# var date_format: String = "{year}/{month}/{day} {hour}:{minute}:{second}"
	var date_format: String = "{year}/{month}/{day}"
	date_text.text = date_format.format({
		"year": time_dict.year,
		"month": "%02d" % time_dict.month,
		"day": "%02d" % time_dict.day,
		"hour": "%02d" % time_dict.hour,
		"minute": "%02d" % time_dict.minute,
		"second": "%02d" % time_dict.second,
	})
	

func _on_SendButton_button_up():
	print(human_concepts)
	print(grounding_concepts)
	for b in human_buttons:
		b.text = "-"
	var r = compi_brain.parse(clean_array(human_concepts), clean_array(grounding_concepts))
	robot_answer(r[0], r[1])
	# if clean_array(human_concepts) == PoolStringArray(["you", "who?"]):
	# 	robot_answer(["me", "ai", "me", "you", "help"], [])
	# robot_answer(human_concepts, grounding_concepts)


func _on_TasksHelpButton_button_up(m: String):
	if m == "Tasks":
		tasks.visible = true
	elif m == "Help":
		help.visible = true


func _on_TasksHelp_gui_input(event, m: String):
	if event is InputEventMouseButton:
		if not event.is_pressed():
			if m == "Tasks":
				tasks.visible = false
			elif m == "Help":
				help.visible = false


func robot_answer(main: PoolStringArray, grounding: PoolStringArray):
	for n in range(robot_buttons.size()):
		if n >= main.size():
			robot_buttons[n].text = "-"
		else:
			robot_buttons[n].text = tr("WORD_%s" % main[n])
	
	for n in range(grounding_buttons.size()):
		if n >= grounding.size():
			grounding_buttons[n].text = "-"
		else:
			grounding_buttons[n].text = tr("WORD_%s" % grounding[n])


func clean_array(a: PoolStringArray):
	var r: PoolStringArray = []
	for i in a:
		if i != "-":
			r.append(i)
	return r
