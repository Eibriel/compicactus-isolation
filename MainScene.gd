extends Control

var concept_theme = load("res://themes/concept_button.tres")
var compi_brain = load("res://compi_brain.gd").new()

onready var intro_animation: AnimationPlayer = $LogoStart/AnimationPlayer

onready var logostart: Node2D = $LogoStart
onready var ok_button: Button = $OkButton
onready var intro_text: Label = $IntroText
onready var shader_animation: AnimationPlayer = $CanvasLayer/AnimationPlayer
onready var compicactus_animation: AnimationPlayer = $Compicactus/AnimationPlayer
onready var compicactus: Node2D = $Compicactus

onready var concept_tree: Tree = $Tree
onready var send_button: Button = $SendButton
onready var chat_text: RichTextLabel = $ChatTextLabel
onready var message_text: RichTextLabel = $MessageTextLabel
onready var answer_progress: ProgressBar = $AnswerProgressBar
onready var message_animation: AnimationPlayer = $AnswerProgressBar/AnimationPlayer

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

var human_concepts: PoolStringArray = []
var robot_concepts: PoolStringArray = []
var robot_concepts_b: PoolStringArray = []

var show_text_time = 0
var showing_text = false
var show_text_chars = 0

var languages: Array = [
	["en", "English"],
	["es", "Español"]
]

func _ready():
	send_button.visible = false
	tasks_button.visible = false
	help_button.visible = false
	concept_tree.visible = false
	message_text.visible = false
	chat_text.visible = false
	answer_progress.visible = false
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
	ok_button.connect("button_up", self, "_on_Ok_button_up", [])
	# tasks.visible = true
	intro_text.visible = true
	ok_button.visible = true
	tasks_button.visible = true
	help_button.visible = true

var prerecorded = [
	["hello"],
	["player", "happy"],
	["player", "home"]
]

func show_game():
	send_button.visible = true
	tasks_button.visible = true
	help_button.visible = true
	concept_tree.visible = true
	message_text.visible = true
	chat_text.visible = true
	answer_progress.visible = true
	concept_tree.connect("cell_selected", self, "_on_Tree_cell_selected", [])
	fill_keyboard()
	robot_concepts = compi_brain.parse([])
	robot_answer()
	for pr in prerecorded:
		robot_concepts = compi_brain.parse(pr)
		robot_answer()
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


func _on_Tree_cell_selected():
	var current_concept = concept_tree.get_selected().get_metadata(0)
	if !tutorial_completed and tutorial_level == 1 and current_concept != "-":
		set_tutorial("tutorial_2")
		tutorial_level = 2
	human_concepts.append(current_concept)
	message_text.bbcode_text = ""
	for c in human_concepts:
		message_text.bbcode_text += tr("WORD_%s" % c) + " "
	filter_tree()


func _on_Ok_button_up():
	ok_button.visible = false
	intro_text.visible = false
	logostart.visible = false
	show_game()


func _on_TaskCompleted(task_name: String):
	refresh_tasks()


func _on_SendButton_button_up():
	print(human_concepts)
	robot_concepts = compi_brain.parse(human_concepts)
	robot_concepts_b = compi_brain.parse([])
	add_to_chat(human_concepts, "Human")
	message_text.bbcode_text = ""
	human_concepts = []
	filter_tree()
	robot_answer()


func filter_tree():
	var useful_words = compi_brain.get_useful_words(human_concepts)
	var child = concept_tree.get_root().get_children()
	while child != null:
		var meta = child.get_metadata(0)
		child.set_selectable(0, true)
		child.deselect(0)
		child.clear_custom_color(0)
		if !useful_words.has(meta):
			print("disable ", meta)
			child.set_selectable(0, false)
			child.set_custom_color(0, Color(0.1,0.1, 0.1))
		child = child.get_next()


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


func robot_answer():
	add_to_chat(robot_concepts, "Compicactus")
	if robot_concepts_b != robot_concepts and robot_concepts_b.size() > 0:
		add_to_chat(robot_concepts_b, "Compicactus")
	robot_concepts = []


func add_to_chat(main: PoolStringArray, from: String):
	var color = "white"
	if from == "Human":
		color = "grey"
	var message = from[0] + ": "
	for c in main:
		message += tr("WORD_%s" % c) + " "
	chat_text.bbcode_text += "\n\n[color=" + color + "]" + message + "[/color]"
	if from != "Human":
		show_text(message.length()+2)

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

func show_text(chars: int):
	if showing_text:
		var max_time = show_text_chars * 0.05
		var chars_to_delete = show_text_chars - (show_text_chars * (show_text_time/max_time))
		show_text_chars = chars + chars_to_delete
		show_text_time = 0
	else:
		show_text_time = 0
		showing_text = true
		show_text_chars = chars

func _process(delta):
	if showing_text:
		show_text_time += delta
		var max_time = show_text_chars * 0.05
		if show_text_time > max_time:
			show_text_time = max_time
			showing_text = false
		var chars_to_delete = show_text_chars - (show_text_chars * (show_text_time/max_time))
		chat_text.visible_characters = chat_text.get_total_character_count() - chars_to_delete
		
