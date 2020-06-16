extends Node

export var event_id: String
export var area_name: String

func _ready():
	var root = self.find_parent("Scene*") 
	self.connect("input_event", root, "_on_area_click", [event_id])
	
	var cursor_layer = root.find_node("CursorLayer")
	self.connect("mouse_entered", cursor_layer, "_on_hover", [event_id, area_name])
	self.connect("mouse_exited", cursor_layer, "_off_hover", [event_id, area_name])
