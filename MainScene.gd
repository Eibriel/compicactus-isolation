extends Control

var LogoGram := load("res://LogoGram.tscn")

var GridDot := load("res://GridDot.tscn")

onready var keyboard: Node2D = $Keyboard
onready var grid: Node2D = $Grid
onready var keyboard_animation: AnimationPlayer = $Keyboard/AnimationPlayer
onready var intro_animation: AnimationPlayer = $LogoStart/AnimationPlayer

onready var logogram_label: Label = $FocusedLogoGramNode2D/FocusedLogoGramLabel
onready var generated_label: Label = $GeneratedTextNode2D/GeneratedLabel2
onready var logostart: Node2D = $LogoStart
onready var ok_button: Area2D = $OkArea2D
onready var date_text: Label = $DateText
onready var intro_text: Label = $IntroText
onready var shader_animation: AnimationPlayer = $CanvasLayer/AnimationPlayer
onready var compicactus_animation: AnimationPlayer = $Compicactus/AnimationPlayer

var showing_keyboard = false

var position_to_place: Vector2 = Vector2()

var lock_click = false
var clicking = false

var timelapse = false
var timelapse_time = 0
var timelapse_completed = false

func _ready():
	logogram_label.text = ""
	generated_label.text = ""
	keyboard.scale = Vector2()
	if true:
		intro_animation.play("Intro")
		var anim = compicactus_animation.get_animation("IdleHappy")
		anim.set_loop(true)
	else:
		ok_button.visible = false
		intro_text.visible = false
		logostart.visible = false
		timelapse_completed = true
		$Compicactus.modulate = Color(1, 1, 1, 1)
		show_game()
	compicactus_animation.play("IdleHappy")
	

func activate_ok_button():
	ok_button.connect("input_event", self, "_on_Ok_input_event", [])


func show_game():
	# Fill Grid
	for x in range(9):
		for y in range(5):
			var dot = GridDot.instance()
			dot.position.x = x * 70
			dot.position.y = y * 70
			dot.connect("input_event", self, "_on_Dot_input_event", [dot])
			grid.add_child(dot)
	
	# Fill Keyboard
	var n: int = 0
	for c in GlobalValues.dictionary:
		print("c ", c)
		var icon = LogoGram.instance()
		icon.set_logogram(c)
		var angle = ((PI*2) / GlobalValues.dictionary.keys().size()) * n
		icon.position.x = sin(angle)*60
		icon.position.y = cos(angle)*60
		icon.scale = Vector2(2, 2)
		icon.connect("input_event", self, "_on_Icon_input_event", [icon])
		icon.connect("mouse_entered", self, "_on_Icon_mouse_entered", [icon, true])
		keyboard.add_child(icon)
		n += 1

func _on_Icon_input_event(viewport, event, node_idx, icon: LogoGram):
	if event is InputEventMouseButton:
		if not event.pressed:
			print(icon.current_logogram)
			add_logogram(icon)

func _on_Icon_mouse_entered(icon: LogoGram, skip_check: bool):
	if not skip_check and showing_keyboard: return
	logogram_label.text = icon.current_logogram


func _on_Dot_input_event(_viewport, event, _node_idx, dot: GridDot):
	if not lock_click:
		if event is InputEventScreenTouch and event.is_pressed():
			var touchPos = dot.global_position
			show_keyboard(touchPos)
		if event is InputEventScreenTouch and not event.is_pressed():
			hide_keyboard()
	else:
		if event is InputEventScreenTouch and event.is_pressed():
			if not clicking:
				var touchPos = event.get_position()
				show_keyboard(touchPos)
				clicking = true
			else:
				hide_keyboard()
				clicking = false


func _input(event):
	if not lock_click:
		#if event is InputEventScreenTouch and event.is_pressed():
		#	var touchPos = event.get_position()
		#	show_keyboard(touchPos)
		if event is InputEventScreenTouch and not event.is_pressed():
			if showing_keyboard:
				hide_keyboard()
	else:
		if event is InputEventScreenTouch and event.is_pressed():
			if not clicking:
				pass
			#	var touchPos = event.get_position()
			#	show_keyboard(touchPos)
			#	clicking = true
			elif showing_keyboard:
				hide_keyboard()
				clicking = false


func show_keyboard(touchPos):
	keyboard.position = touchPos
	position_to_place = touchPos
	keyboard_animation.play("ShowKeyboard")
	showing_keyboard = true


func hide_keyboard():
	keyboard_animation.play("HideKeyboard")
	showing_keyboard = false


func add_logogram(clicked_icon: LogoGram):
	var icon = LogoGram.instance()
	icon.set_logogram(clicked_icon.current_logogram)
	icon.position = position_to_place
	icon.scale = Vector2(2, 2)
	icon.connect("mouse_entered", self, "_on_Icon_mouse_entered", [icon, false])
	add_child(icon)


func _on_Ok_input_event(_viewport, event, _node_idx):
	if event is InputEventScreenTouch and event.is_pressed():
		ok_button.visible = false
		intro_text.visible = false
		logostart.visible = false
		timelapse = true
		shader_animation.play("Timelapse")
		

func _process(delta):
	var date: String = ""
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
			# print(timelapse_time) # 11
			# show_game()
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
	
