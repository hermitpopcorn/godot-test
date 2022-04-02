extends Node

onready var gui: Node = $GUILayer/GUI

# shake

onready var shake_tween: Tween = $GUILayer/ShakeTween
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

export(Array, Resource) var party_members

func _ready():
	var kaput = preload("res://data/party_units/kaput_hunter.gd").new()
	var paul = preload("res://data/party_units/paul_kirigaya.gd").new()
	var rifkaizer = preload("res://data/party_units/rifkaizer.gd").new()
	var the_bonk = preload("res://data/party_units/the_bonk.gd").new()
	party_members.append(kaput)
	party_members.append(paul)
	party_members.append(rifkaizer)
	party_members.append(the_bonk)
	$GUILayer/GUI/PartyStatusContainer/MemberStatus.attach(self.party_members[0])
	$GUILayer/GUI/PartyStatusContainer/MemberStatus2.attach(self.party_members[1])
	$GUILayer/GUI/PartyStatusContainer/MemberStatus3.attach(self.party_members[2])
	$GUILayer/GUI/PartyStatusContainer/MemberStatus4.attach(self.party_members[3])

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
		print(self.party_members[0])
		print(self.party_members[0].weapon)
		var w: Equipment = self.party_members[0].weapon
		print(w.name)
	if (Input.is_physical_key_pressed(KEY_Y)):
		$GUILayer/GUI/PartyStatusContainer/MemberStatus/AnimationPlayer.play("RESET")
