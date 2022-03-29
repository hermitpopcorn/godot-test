extends Node

onready var pause_tween = $PauseTween
var prepaused_mouse_mode

func _process(delta):
	if ($PauseTween.is_active()): return
	
	if Input.is_action_just_pressed("pause"):
		if (self.visible):
			self.unpause()
		else:
			self.pause()

func pause():
	self.pause_tween.remove_all()
	self.visible = true
	self.modulate.a = 1
	self.prepaused_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func unpause():
	self.pause_tween.remove_all()
	self.pause_tween.interpolate_property(self, "modulate:a", 1, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	self.pause_tween.start()

func _on_tween_all_completed():
	Input.set_mouse_mode(self.prepaused_mouse_mode)
	self.visible = false
	get_tree().paused = false
