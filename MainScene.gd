extends Control

var concept_theme = load("res://themes/concept_button.tres")
var compi_brain = load("res://compi_brain.gd").new()

onready var intro_animation: AnimationPlayer = $LogoStart/AnimationPlayer

onready var logostart: Node2D = $LogoStart
onready var ok_button: Area2D = $OkArea2D
onready var intro_text: Label = $IntroText
onready var shader_animation: AnimationPlayer = $CanvasLayer/AnimationPlayer
onready var compicactus_animation: AnimationPlayer = $Compicactus/AnimationPlayer
onready var compicactus: Node2D = $Compicactus

onready var concept_tree: Tree = $Tree
onready var send_button: Button = $SendButton

onready var tasks: Control = $Tasks
onready var tasks_button: Button = $TasksButton
onready var tasks_text: RichTextLabel = $Tasks/TasksText
onready var help: Control = $Help
onready var help_button: Button = $HelpButton
onready var help_text: RichTextLabel = $Help/HelpText
onready var ending: Control = $Ending
onready var ending_text: RichTextLabel = $Ending/EndingText
onready var language_container: VBoxContainer = $Languages

onready var tutorial_1: Node2D = $Tutorial/Tutorial1
onready var tutorial_1_text: Label = $Tutorial/Tutorial1/TutorialText1
onready var tutorial_2: Node2D = $Tutorial/Tutorial2
onready var tutorial_2_text: Label = $Tutorial/Tutorial2/TutorialText2
onready var tutorial_3: Node2D = $Tutorial/Tutorial3
onready var tutorial_3_text: Label = $Tutorial/Tutorial3/TutorialText3

var quick_start = true

var tutorial_completed: bool = false
var tutorial_level: int = 1

var current_concept: String = "-"

var human_concepts: PoolStringArray = []
var human_buttons = []

var robot_concepts: PoolStringArray = []
var robot_buttons = []

var languages: Array = [
	["en", "English"],
	["es", "Español"]
]

func _ready():
	send_button.visible = false
	tasks_button.visible = false
	help_button.visible = false
	ending.visible = false
	tutorial_1.visible = false
	tutorial_2.visible = false
	tutorial_3.visible = false
	for lang in languages:
		var b = Button.new()
		b.theme = concept_theme
		b.text = lang[1]
		language_container.add_child(b)
		b.connect("button_up", self, "_on_LanguageButton_button_up", [lang[0]])
	compi_brain.connect("task_completed", self, "_on_TaskCompleted", [])
	compi_brain.connect("ending_reached", self, "_on_EndingReached", [])
	compi_brain.connect("words_added", self, "_on_WordsAdded", [])


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
		# timelapse_completed = true
		compicactus.modulate = Color(1, 1, 1, 1)
		show_game()
	compicactus_animation.play("IdleHappy")
	set_language()
	refresh_tasks()
	

func set_language():
	tasks_button.text = tr("TASKS")
	help_text.bbcode_text = tr("HELP_TEXT")
	intro_text.text = tr("INTRO_TEXT")
	send_button.text = tr("SEND")
	tutorial_1_text.text = tr("TUTORIAL_1")
	tutorial_2_text.text = tr("TUTORIAL_2")
	tutorial_3_text.text = tr("TUTORIAL_3")


func activate_ok_button():
	ok_button.connect("input_event", self, "_on_Ok_input_event", [])
	# tasks.visible = true
	tasks_button.visible = true
	help_button.visible = true


func show_game():
	send_button.visible = true
	tasks_button.visible = true
	help_button.visible = true
	concept_tree.connect("cell_selected", self, "_on_Tree_cell_selected", [])

	fill_keyboard()
	var r = compi_brain.parse([])
	robot_answer(r)
	set_tutorial("tutorial_1")


func fill_keyboard():
	concept_tree.clear()
	concept_tree.theme = concept_theme
	var root_concept = concept_tree.create_item()
	concept_tree.set_hide_root(true)
	
	# var n: int = 0
	for c in GlobalValues.dictionary:
		var concept_item = concept_tree.create_item(root_concept)
		concept_item.set_text(0, tr("WORD_%s" % c))
		concept_item.set_metadata(0, c)


var word_number = 0

func _on_Tree_cell_selected():
	current_concept = concept_tree.get_selected().get_metadata(0)
	if !tutorial_completed and tutorial_level == 1 and current_concept != "-":
		set_tutorial("tutorial_2")
		tutorial_level = 2
	# Add world directly
	if word_number <= 8:
		# _on_HumanButton_button_up(word_number)
		word_number += 1


func _on_Ok_input_event(_viewport, event, _node_idx):
	if event is InputEventScreenTouch and event.is_pressed():
		ok_button.visible = false
		intro_text.visible = false
		logostart.visible = false
		# shader_animation.play("Timelapse")
		show_game()


func _on_TaskCompleted(task_name: String):
	refresh_tasks()


func _on_SendButton_button_up():
	print(human_concepts)
	for b in human_buttons:
		b.text = "-"
	var r = compi_brain.parse(clean_array(human_concepts))
	robot_answer(r)
	human_concepts = []
	word_number = 0
	if tutorial_level == 3:
		set_tutorial("")
		tutorial_completed = true


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


func robot_answer(main: PoolStringArray):
	robot_concepts = []
	# robot_buttons[n].text = tr("WORD_%s" % main[n])
	# grounding_buttons[n].text = tr("WORD_%s" % grounding[n])


func clean_array(a: PoolStringArray):
	var r: PoolStringArray = []
	for i in a:
		if i != "-":
			r.append(i)
	return r


func refresh_tasks():
	var text = "[b]%s[/b]\n" % tr("TASKS_TITLE")
	var task_list = compi_brain.get_task_list()
	for t in task_list:
		if task_list[t].visible:
			if task_list[t].completed:
				text += "- [color=gray][s]%s[/s] (%s)[/color]\n" % [tr(t), tr("TASK_DONE")]
			else:
				text += "- %s\n" % tr(t)
	tasks_text.bbcode_text = text


func _on_EndingReached(ending_type: String):
	ending_text.bbcode_text = tr("ENDING_%s" % ending_type)
	ending.visible = true

func _on_WordsAdded():
	fill_keyboard()

func set_tutorial(name: String):
	tutorial_1.visible = false
	tutorial_2.visible = false
	tutorial_3.visible = false
	match name:
		"tutorial_1":
			tutorial_1.visible = true
		"tutorial_2":
			tutorial_2.visible = true
		"tutorial_3":
			tutorial_3.visible = true
