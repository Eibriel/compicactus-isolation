extends Area2D
class_name LogoGram

export var current_logogram: String
var dirty = false

# var icon: Node2D

onready var icon = $IconNode2D


func _ready():
	# icon = Node2D.new()
	# add_child(icon)
	# set_logogram("me")
	pass


func set_logogram(logogram: String):
	print("set ", logogram)
	current_logogram = logogram
	dirty = true


func _process(delta):
	if not dirty: return
	dirty = false
	for c in icon.get_children():
		icon.remove_child(c)
	print("cc ", current_logogram)
	$Label.text = current_logogram
	return
	for shape in GlobalValues.dictionary[current_logogram]["draw"]:
		if shape[0] == "circle":
			var center = Vector2(shape[1][0], shape[1][1])
			var radious = shape[2]
			# var col = Color(shape[3][0], shape[3][1], shape[3][2])
			var circle: AntialiasedRegularPolygon2D = AntialiasedRegularPolygon2D.new()
			circle.size = Vector2(shape[2], shape[2])
			circle.stroke_width = 0
			circle.antialiased = true
			if shape[3] == 0:
				circle.color = Color(0.3, 0.3, 0.3)
			else:
				circle.color = Color.white
			circle.position = center
			icon.add_child(circle)
