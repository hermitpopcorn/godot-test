extends Node

class_name BaseScene

func _input(event):
	# toggle Fullscreen
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func _center_window():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

func enable_cursor():
	if (get_node_or_null("CursorLayer") == null): return
	$CursorLayer.enable()

func disable_cursor():
	if (get_node_or_null("CursorLayer") == null): return
	$CursorLayer.disable()

func get_cursor_status():
	if (get_node_or_null("CursorLayer") == null): return false
	return $CursorLayer.active

func check_event_processor_active():
	return self.get_node("EventProcessor").active
