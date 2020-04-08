extends Node

class_name BaseScene

func _input(event):
	if (!$CanvasLayer/PausedIndicator.visible):
		if event.is_action_pressed("ui_cancel"):
			get_tree().paused = true
			$CanvasLayer/PausedIndicator.visible = true

func center_window():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
