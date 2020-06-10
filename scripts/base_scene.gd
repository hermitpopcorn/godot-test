extends Node

class_name BaseScene

func _input(event):
	# Toggle Fullscreen
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	# Pause
	if (!$PausedUILayer/PausedIndicator.visible):
		if event.is_action_pressed("ui_cancel"):
			get_tree().paused = true
			$PausedUILayer/PausedIndicator.visible = true

func _center_window():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

func _cursor_setup():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
