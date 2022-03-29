extends "res://scripts/expandable_diamond_polygon.gd"

signal animation_completed

class_name ExpandableDiamond

func _ready():
	self.shrink(0.0)

func shrink(duration: float = 0.7):
	for i in len(self.polygon):
		$Tween.interpolate_method(self, "resize_polygon" + str(i), self.polygon[i], Vector2(0, 0), duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.interpolate_method($Portrait, "resize_polygon" + str(i), $Portrait.polygon[i], Vector2(0, 0), duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.interpolate_method($Border, "resize_polygon" + str(i), $Border.points[i], Vector2(0, 0), duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		if i == 0:
			$Tween.interpolate_method($Border, "resize_polygon4", $Border.points[4], Vector2(0, 0), duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.connect("tween_all_completed", self, "_hide_after_tween", [], CONNECT_ONESHOT)
	$Tween.start()

func expand(duration: float = 0.7):
	self.visible = true
	for i in len(self.polygon):
		$Tween.interpolate_method(self, "resize_polygon" + str(i), self.polygon[i], self.initial_vectors[i], duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.interpolate_method($Portrait, "resize_polygon" + str(i), $Portrait.polygon[i], $Portrait.initial_vectors[i], duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$Tween.interpolate_method($Border, "resize_polygon" + str(i), $Border.points[i], $Border.initial_vectors[i], duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		if i == 0:
			$Tween.interpolate_method($Border, "resize_polygon4", $Border.points[4], $Border.initial_vectors[4], duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

func _hide_after_tween():
	self.visible = false

func _on_tween_all_completed():
	emit_signal("animation_completed")
