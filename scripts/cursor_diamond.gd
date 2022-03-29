extends CanvasLayer

var hovered_items: Array = []
var snapping: bool = false

onready var cursor_sprite = $CursorSprite
onready var cursor_sprite_outside = $CursorSprite/CursorSpriteOutside
onready var cursor_sprite_inside = $CursorSprite/CursorSpriteInside

signal show_info_text
signal hide_info_text

func _process(_delta):
	# Follow mouse
	var mouse_pos = get_viewport().get_mouse_position()
	if (mouse_pos.x != 0 && mouse_pos.y != 0):
		self.cursor_sprite.position = get_viewport().get_mouse_position()

	if (self.cursor_sprite_outside.rotation_degrees >= 360):
		self.cursor_sprite_outside.rotation_degrees -= 360
	if (self.cursor_sprite_inside.rotation_degrees <= -360):
		self.cursor_sprite_inside.rotation_degrees += 360

	if (!self.check_hovering()):
		# Rotate a little
		self.cursor_sprite_outside.rotation_degrees += 0.5
		self.snapping = false
	else:
		# Set to snap to nearest angle
		self.snapping = true

	if (self.snapping):
		# Snap back to nearest angle (outside)
		var over_times = floor(abs(self.cursor_sprite_outside.rotation_degrees) / 90)
		var degrees_remaining = abs(self.cursor_sprite_outside.rotation_degrees) - (90 * over_times)
		if (degrees_remaining >= 45):
			self.cursor_sprite_outside.rotation_degrees += min(7, degrees_remaining)
		else:
			self.cursor_sprite_outside.rotation_degrees -= min(7, degrees_remaining)
		# Shrink
		if (self.cursor_sprite.scale.x > 0.75):
			self.cursor_sprite.scale.x -= 0.05
			self.cursor_sprite.scale.y -= 0.05
		# Hue shift
		self.cursor_sprite_outside.get_material().set_shader_param('shift_amount', 0.1)
		self.cursor_sprite_inside.get_material().set_shader_param('shift_amount', 0.1)
	else:
		# Back to normal size
		if (self.cursor_sprite.scale.x < 1):
			self.cursor_sprite.scale.x += 0.05
			self.cursor_sprite.scale.y += 0.05
		# Shift back hue
		self.cursor_sprite_outside.get_material().set_shader_param('shift_amount', 0)
		self.cursor_sprite_inside.get_material().set_shader_param('shift_amount', 0)

func check_hovering() -> bool:
	if (self.hovered_items.size() == 0): return false

	if (self.get_parent().check_event_processor_active()):
		if (!self.hovered_items.has('MessageBox')): return false

	return true

func _on_hover(emitter, text=null):
	if (!self.hovered_items.has(emitter)):
		self.hovered_items.append(emitter)
	if (text):
		self.emit_signal("show_info_text", text)

func _off_hover(emitter, text=null):
	if (emitter == "*"):
		self.hovered_items.clear()
		self.emit_signal("hide_info_text", "*")
	else:
		var index = self.hovered_items.find(emitter)
		if (index > -1):
			self.hovered_items.remove(index)
		if (text):
			self.emit_signal("hide_info_text", text)
