extends Node2D

export var size: float = 36.512 # size of the diamonds
export var fade_speed: float = 0.01 # speed of diamond fade. smaller = faster

func show_diamond_stripe(length, text):
	create_stripe(length)
	show_stripe()
	show_text(text)

func hide_diamond_stripe():
	hide_stripe()
	hide_text()

func create_diamond_node():
	var node: Sprite = Sprite.new()
	node.texture = load("res://images/ui/diamond.png")
	node.scale = Vector2(0.14, 0.14)
	node.modulate.a = 0
	return node

func create_stripe(length):
	for child in $Diamonds.get_children():
		child.queue_free()

	length = max(length, 3)
	var current_column = 1
	var column_x: float
	var diamond_node: Sprite

	while current_column <= length:
		column_x = (current_column - 1) * self.size
		if ((current_column % 2) == 1):
			diamond_node = create_diamond_node()
			$Diamonds.add_child(diamond_node)
			diamond_node.position.x = column_x
			diamond_node.position.y = self.size * -1

			diamond_node = create_diamond_node()
			$Diamonds.add_child(diamond_node)
			diamond_node.position.x = column_x
			diamond_node.position.y = self.size * 1
		else:
			diamond_node = create_diamond_node()
			$Diamonds.add_child(diamond_node)
			diamond_node.set_position(Vector2(column_x, 0))
		current_column += 1

func show_stripe(): animate_stripe(true)
func hide_stripe(): animate_stripe(false)

func animate_stripe(show):
	$Tween.stop_all()
	$Tween.remove_all()
	var c = 0
	for child in $Diamonds.get_children():
		if (show):
			$Tween.interpolate_property(child, "modulate:a", child.modulate.a, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, self.fade_speed * c)
		else:
			$Tween.interpolate_property(child, "modulate:a", child.modulate.a, 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN, self.fade_speed * c)
		c += 1
	$Tween.start()

func show_text(text: String):
	if ($TextRect/Text/Tween.is_active()):
		$TextRect/Text/Tween.stop_all()
	$TextRect/Text.text = text
	$TextRect/Text.modulate.a = 0
	$TextRect/Text/Tween.interpolate_property($TextRect/Text, "modulate:a", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.2)
	$TextRect/Text/Tween.interpolate_property($TextRect/Text, "visible_characters", 0, text.length(), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.2)
	$TextRect/Text/Tween.start()

func hide_text():
	$TextRect/Text/Tween.stop_all()
	$TextRect/Text/Tween.interpolate_property($TextRect/Text, "modulate:a", $TextRect/Text.modulate.a, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$TextRect/Text/Tween.start()

func _tween_finished():
	for child in $Diamonds.get_children():
		if (child.modulate.a == 0): child.queue_free()
