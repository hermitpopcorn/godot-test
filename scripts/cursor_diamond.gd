extends CanvasLayer

var active = false
var hovered_items: Array = []
var hovered_items_text: Dictionary = {}
var snapping: bool = false

onready var cursor_sprite = false # set to false to disable sprite cursor
onready var cursor_sprite_outside = $CursorSprite/CursorSpriteOutside
onready var cursor_sprite_inside = $CursorSprite/CursorSpriteInside

var enable_check_timer: Timer

signal show_info_text
signal hide_info_text

func _ready():
	self.enable_check_timer = Timer.new()
	self.enable_check_timer.wait_time = 0.2
	self.enable_check_timer.one_shot = true
	self.add_child(self.enable_check_timer)
	self.enable_check_timer.connect("timeout", self, "_enable_info")

func enable():
	if (self.cursor_sprite is Node):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	self.enable_check_timer.start()
	self.active = true
func _enable_info():
	if (self.hovered_items.size() > 0):
		self.emit_signal("show_info_text", self.hovered_items_text[self.hovered_items.back()])

func disable():
	if (self.cursor_sprite is Node):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.active = false
	self.emit_signal("hide_info_text", "*")

func _process(_delta):
	if (!self.active): return
	
	if (!(self.cursor_sprite is Node)):
		if (self.check_hovering()):
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		return
	
	if (self.cursor_sprite != false):
		# follow mouse
		var mouse_pos = get_viewport().get_mouse_position()
		if (mouse_pos.x != 0 && mouse_pos.y != 0):
			self.cursor_sprite.position = get_viewport().get_mouse_position()

		if (self.cursor_sprite_outside.rotation_degrees >= 360):
			self.cursor_sprite_outside.rotation_degrees -= 360
		if (self.cursor_sprite_inside.rotation_degrees <= -360):
			self.cursor_sprite_inside.rotation_degrees += 360

	if (!self.check_hovering()):
		# rotate a little
		self.cursor_sprite_outside.rotation_degrees += 0.5
		self.snapping = false
	else:
		# set to snap to nearest angle
		self.snapping = true

	if (self.snapping):
		# snap back to nearest angle (outside)
		var over_times = floor(abs(self.cursor_sprite_outside.rotation_degrees) / 90)
		var degrees_remaining = abs(self.cursor_sprite_outside.rotation_degrees) - (90 * over_times)
		if (degrees_remaining >= 45):
			self.cursor_sprite_outside.rotation_degrees += min(7, degrees_remaining)
		else:
			self.cursor_sprite_outside.rotation_degrees -= min(7, degrees_remaining)
		# shrink
		if (self.cursor_sprite.scale.x > 0.75):
			self.cursor_sprite.scale.x -= 0.05
			self.cursor_sprite.scale.y -= 0.05
		# hue shift
		self.cursor_sprite_outside.get_material().set_shader_param("shift_amount", 0.1)
		self.cursor_sprite_inside.get_material().set_shader_param("shift_amount", 0.1)
	else:
		# back to normal size
		if (self.cursor_sprite.scale.x < 1):
			self.cursor_sprite.scale.x += 0.05
			self.cursor_sprite.scale.y += 0.05
		# shift back hue
		self.cursor_sprite_outside.get_material().set_shader_param("shift_amount", 0)
		self.cursor_sprite_inside.get_material().set_shader_param("shift_amount", 0)

func check_hovering() -> bool:
	if (!self.active): return false
	
	if (self.hovered_items.size() == 0): return false

	# if event processor is active, restrict hovering only to message box
	if (self.get_parent().check_event_processor_active()):
		if (!self.hovered_items.has("MessageBox")): return false
	
	return true

func _on_hover(emitter, text = null):
	if (!self.active): return false
	
	if (!self.hovered_items.has(emitter)):
		self.hovered_items.append(emitter)
	if (text):
		self.hovered_items_text[emitter] = text
		self.emit_signal("show_info_text", text)

func _off_hover(emitter, text = null):
	if (!self.active): return false
	
	if (emitter == "*"):
		self.hovered_items.clear()
		self.hovered_items_text.clear()
		self.emit_signal("hide_info_text", "*")
	else:
		self.hovered_items.erase(emitter)
		self.hovered_items_text.erase(emitter)
		if (text):
			self.emit_signal("hide_info_text", text)
