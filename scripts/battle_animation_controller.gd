extends Node

var gui: Node

onready var shake_tween: Tween = $ShakeTween
var current_shake_priority: int = 0

func set_gui(new_gui: Node):
	self.gui = new_gui

# shake

func _move_gui(vector):
	self.gui.rect_position = Vector2(rand_range(-vector.x, vector.x), rand_range(-vector.y, vector.y))

func gui_shake(shake_length, shake_power, shake_priority):
	if shake_priority > self.current_shake_priority:
		self.current_shake_priority = shake_priority
		self.shake_tween.interpolate_method(self, "_move_gui", Vector2(shake_power, shake_power), Vector2(0, 0), shake_length, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
		self.shake_tween.start()

func _on_ShakeTween_tween_completed(object, key):
	self.current_shake_priority = 0
	self.gui.rect_position = Vector2(0, 0)

# damage flash

onready var damage_flash_tween: Tween = $DamageFlashTween
onready var damage_flash_rect: TextureRect = $ControlContainer/DamageFlashRect
var active_damage_flashes = {}

func _test():
	var flash_rect = self.damage_flash_rect.duplicate()
	flash_rect.modulate.a = 0
	flash_rect.visible = true
	self.add_child(flash_rect)
	self.move_child(flash_rect, 0)
	print(self.get_children())
	self.damage_flash_tween.interpolate_property(flash_rect, "modulate:a", 0.0, 1.0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	self.damage_flash_tween.start()

func flash_damage_on_party_member(member_status: Node):
	var flash_rect = self.damage_flash_rect.duplicate()
	member_status.add_child(flash_rect)
	member_status.move_child(flash_rect, 0)
	flash_rect.modulate.a = 0
	flash_rect.set_anchors_preset(Control.PRESET_WIDE)
	flash_rect.visible = true
	print(member_status.get_children())
	self.active_damage_flashes[flash_rect] = 0
	self.damage_flash_tween.interpolate_property(flash_rect, "modulate:a", 0.0, 1.0, 0.2, Tween.TRANS_QUART, Tween.EASE_OUT)
	self.damage_flash_tween.interpolate_property(flash_rect, "modulate:a", 1.0, 0.0, 0.3, Tween.TRANS_QUART, Tween.EASE_IN, 0.2)
	self.damage_flash_tween.start()

func _on_DamageFlashTween_tween_completed(object, key):
	self.active_damage_flashes[object] += 1
	if (self.active_damage_flashes[object] >= 2):
		self.active_damage_flashes.erase(object)
		print(object.get_parent().get_children())
		object.queue_free()
