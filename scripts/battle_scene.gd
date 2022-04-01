extends Node

onready var gui: Node = $GUILayer/GUI

# shake

onready var shake_tween: Tween = $ShakeTween
var current_shake_priority: int = 0

func _move_gui(vector):
	self.gui.rect_position = Vector2(rand_range(-vector.x, vector.x), rand_range(-vector.y, vector.y))

func gui_shake(shake_length, shake_power, shake_priority):
	if shake_priority >= self.current_shake_priority:
		self.current_shake_priority = shake_priority
		self.shake_tween.interpolate_method(self, "_move_gui", Vector2(shake_power, shake_power), Vector2(0, 0), shake_length, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
		self.shake_tween.start()

func _on_ShakeTween_tween_completed(object, key):
	self.current_shake_priority = 0
	self.gui.rect_position = Vector2(0, 0)

# debug

func _ready():
	$GUILayer/GUI/PartyStatusContainer/MemberStatus.attach($"Test/Paul Kirigaya")

func _input(event):
	if (Input.is_physical_key_pressed(KEY_Q)):
		gui_shake(1, 50, 1)
	if (Input.is_physical_key_pressed(KEY_W)):
		$GUILayer/GUI/PartyStatusContainer/MemberStatus.damage(round(rand_range(-10.0, 10.0)) * 10)
	if (Input.is_physical_key_pressed(KEY_E)):
		$GUILayer/GUI/PartyStatusContainer/MemberStatus2.buff()
	if (Input.is_physical_key_pressed(KEY_R)):
		$GUILayer/GUI/PartyStatusContainer/MemberStatus3.debuff()
	if (Input.is_physical_key_pressed(KEY_T)):
		print($"Test/Paul Kirigaya")
		print($"Test/Paul Kirigaya".weapon)
