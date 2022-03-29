extends Node2D

var target_length
onready var rect_calculator = $TextRect/RectCalculator
onready var tween = $Tween
onready var rect_line = $RectLine
onready var text = $TextRect/Text
onready var text_tween = $TextRect/Text/Tween

func show_rect_stripe(length, text_to_show):
	self._set_stripe_length(length)
	show_stripe()
	show_text(text_to_show)

func hide_rect_stripe():
	hide_stripe()
	hide_text()

func hide_rect_stripe_without_tween():
	self.tween.remove_all()
	self.text_tween.remove_all()
	self.text.visible_characters = 0
	self.text.modulate.a = 0
	self._set_line_point(Vector2(0, 0))

func _set_stripe_length(length):
	self.target_length = length

func show_stripe(): animate_stripe(true)
func hide_stripe(): animate_stripe(false)

func _set_line_point(new_vector: Vector2):
	self.rect_line.set_point_position(1, new_vector)

func animate_stripe(show):
	self.tween.remove_all()
	if (show):
		self.tween.interpolate_method(self, "_set_line_point", Vector2(0, 0), Vector2(self.target_length, 0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	else:
		self.tween.interpolate_method(self, "_set_line_point", Vector2(self.rect_line.points[1].x, 0), Vector2(0, 0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	self.tween.start()

func show_text(text_to_show: String):
	self.text_tween.remove_all()
	self.text.text = text_to_show
	self.text.modulate.a = 0
	self.text_tween.interpolate_property(self.text, "modulate:a", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1)
	self.text_tween.interpolate_property(self.text, "visible_characters", 0, text_to_show.length(), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1)
	self.text_tween.start()

func hide_text():
	self.text_tween.remove_all()
	self.text_tween.interpolate_property(self.text, "visible_characters", self.text.visible_characters, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	self.text_tween.interpolate_property(self.text, "modulate:a", self.text.modulate.a, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	self.text_tween.start()
