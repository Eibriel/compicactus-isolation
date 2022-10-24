extends Control

onready var intro_animation: AnimationPlayer = $LogoStart/AnimationPlayer

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
	generated_label.text = ""
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
	# Add buttons to chat
	
	# Fill Keyboard
	var n: int = 0
	for c in GlobalValues.dictionary:
		print("c ", c)


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
	
