extends Node2D

func update_balance(balance: int):
	$Planc/Me.text = tr("WORD_me")
	$Planc/You.text = tr("WORD_you")
	
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Planc, "rotation", balance * -0.1, 2.0)
