extends Node2D

var heart_texture = load("res://images/heart.png")

var hearts = []

var amount = 0

func _ready():
	for n in range(10):
		var s = Sprite.new()
		s.texture = heart_texture
		# s.scale = Vector2(0.1, 0.1)
		s.scale = Vector2(0, 0)
		s. position.x = n * 20
		add_child(s)
		hearts.append(s)

func set_hearts(new_amount: int):
	if new_amount == amount:
		return
	if new_amount < 0:
		new_amount = 0
	$Label.text = "Hearts: %s" % new_amount
	
	var diff = new_amount - amount

	if diff > 0:
		for n in range(diff):
			var h = n + amount
			var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(hearts[h], "scale", Vector2(0.1, 0.1), 1.0)
	if diff < 0:
		for n in range(-diff):
			var h = amount - n -1
			var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
			tween.tween_property(hearts[h], "scale", Vector2(0.0, 0.0), 1.0)
			
	amount = new_amount
