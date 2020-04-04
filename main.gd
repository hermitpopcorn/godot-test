extends Control

var message_box

func _ready():
	# Center window on screen
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	
	self.message_box = get_node("MessageBox")
	self.message_box.show_text("First message to display.")

func _process(delta):
	pass

func _on_MessageBox_next():
	message_box.show_text("Loop! Again and again!")
