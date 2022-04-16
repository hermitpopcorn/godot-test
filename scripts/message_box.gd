extends Control

class_name MessageBox

export var message_speed: int = 50 # in miliseconds
export var play_advance_click_sound = true

onready var background = $Background
onready var message = $Background/Message
onready var nameplate = $Background/Nameplate
onready var nameplate_text = $Background/Nameplate/NameText
onready var next_caret = $Background/NextCaret
onready var tween = $Tween
onready var message_tick_timer = $MessageTickTimer
onready var click_sound_player = $ClickSound

var message_length: int
var typing_finsihed: bool = true
var tweening_finished: bool = true
var state: String = "disabled" # "disabled", "typing", "waiting_input", "standby"
var tags = []
var instructions = {}
var temporary_message_speed: int = 0

signal finished_typing
signal finished_tweening
signal clicked
signal next
signal hover_on
signal hover_off

func _ready():
	self.message.bbcode_text = ""
	self.visible = true if (self.modulate.a == 1) else false
	self.state = "standby"

func show_text(text, options: Dictionary = {}):
	self.state = "typing"
	
	# check for message tags
	self.tags = []
	var tag_scan = true
	while (tag_scan):
		# continue text or fresh text
		if (text.begins_with("_")):
			text = text.substr(1)
			self.tags.push_back("pickup")
		# skip without player confirmation
		elif (text.ends_with(">>")):
			text = text.substr(0, text.length() - 2)
			self.tags.push_back("no_confirmation")
		else:
			tag_scan = false
	
	# check for message instructions
	self.instructions = {}
	var instruction_scan = true
	var push_by = 0
	if ("pickup" in self.tags):
		push_by = (self.get_bbcodeless_text(self.message.bbcode_text)).length()
	while (instruction_scan):
		var opening_bracket_position = text.find("{")
		if (opening_bracket_position != -1):
			
			# count all preceeding bbcodes
			var scan_index = 0
			var bbcodes = [];
			while (scan_index <= opening_bracket_position):
				var s_pos = text.find("[", scan_index)
				if (s_pos == -1 || s_pos > opening_bracket_position):
					break
				else:
					var e_pos = text.find("]", scan_index + 1)
					if (e_pos == -1):
						break
					else:
						bbcodes.push_back([s_pos, e_pos])
						scan_index = e_pos
			
			var closing_bracket_position = text.find("}")
			if (closing_bracket_position != -1):
				var instruction = text.substr(opening_bracket_position, closing_bracket_position - opening_bracket_position + 1)
				var instruction_index = opening_bracket_position;
				for i in bbcodes:
					instruction_index -= ((i[1] - i[0]) + 1)
				if (!self.instructions.has(push_by + instruction_index)):
					self.instructions[push_by + instruction_index] = []
				self.instructions[push_by + instruction_index].append(instruction.substr(1, instruction.length() - 2))
				text.erase(opening_bracket_position, closing_bracket_position - opening_bracket_position + 1)
			else:
				instruction_scan = false
		else:
			instruction_scan = false
		
	if ("pickup" in self.tags):
		self.message.visible_characters = (self.get_bbcodeless_text(self.message.bbcode_text)).length()
		self.message.bbcode_text = self.message.bbcode_text + text
	else:
		self.message.bbcode_text = text
		self.message.visible_characters = 0
	self.message_length = (self.get_bbcodeless_text(self.message.bbcode_text)).length()
	self.typing_finsihed = false
	self.next_caret.visible = false
	if (options.has("nameplate")):
		var hue = 0
		if (options["nameplate"].has("hue")):
			hue = options["nameplate"]["hue"]
		self._show_nameplate(options["nameplate"]["name"], hue)
	else:
		self._hide_nameplate()
	
	self._go_over_instructions()
	if (self.temporary_message_speed > 0):
		self.message_tick_timer.start((float(self.temporary_message_speed) / 1000))
		self.temporary_message_speed = 0
	else:
		self.message_tick_timer.start(float(self.message_speed) / 1000)

func get_bbcodeless_text(text):
	if !(text):
		return text
	var do = true
	while (do):
		var s_pos = text.find("[")
		if (s_pos == -1):
			do = false
		else:
			var e_pos = text.find("]")
			text.erase(s_pos, (e_pos - s_pos) + 1)
	return text

func _go_over_instructions():
	if (self.message.visible_characters in self.instructions):
		for instruction in self.instructions[self.message.visible_characters]:
			if (instruction.begins_with("w")):
				self.message_tick_timer.stop()
				var wait_timer = Timer.new()
				wait_timer.one_shot = true
				wait_timer.wait_time = float(instruction.substr(1))
				wait_timer.connect("timeout", self, "_intext_timer_timeout", [wait_timer])
				self.message_tick_timer.add_child(wait_timer)
				wait_timer.start()
			elif (instruction.begins_with("s")):
				var speed = instruction.substr(1)
				# reset if unspecified
				if (speed == ""): speed = self.message_speed
				else: speed = speed.to_int()
				
				# if already started typing text, set timer wait time. else, set temp message speed
				if (self.message.visible_characters > 0):
					self.message_tick_timer.wait_time = float(speed) / 1000
				else:
					self.temporary_message_speed = speed

func _type_text_character():
	self.message.visible_characters += 1
	if (self.message.visible_characters >= self.message_length):
		self._end_typing()
	else:
		self._go_over_instructions()

func _intext_timer_timeout(itself):
	# remove in-text timer from main timer and restart main timer
	self.message_tick_timer.remove_child(itself)
	self.message_tick_timer.start()

func _show_nameplate(name: String, hue: float = 0.0):
	if (self.nameplate.visible == false || self.nameplate.modulate.a < 0.1):
		self.nameplate.modulate.a = 1
		self.nameplate.visible = true
	self.nameplate_text.bbcode_text = "[center]" + name + "[/center]"
	self.nameplate.get_material().set_shader_param("shift_amount", hue)

func _hide_nameplate():
	self.nameplate.visible = false

func _skip_typing():
	self.message_tick_timer.stop()
	self.message.visible_characters = self.message.bbcode_text.length()
	self._end_typing()

func _end_typing():
	self.message_tick_timer.stop()
	for i in self.message_tick_timer.get_children():
		self.message_tick_timer.remove_child(i)
	self.typing_finsihed = true
	self.state = "waiting_input"
	if !("no_confirmation" in self.tags):
		self.next_caret.visible = true
	emit_signal("finished_typing", self.tags)

func hide(animate: bool = true):
	self.toggle_visibility(false, animate)

func show(animate: bool = true):
	self.toggle_visibility(true, animate)

func toggle_visibility(target_visibility: bool, animate: bool = true):
	self._hide_nameplate()
	self.next_caret.visible = false
	if target_visibility == true:
		self.modulate.a = 0;
		self.visible = true
	else:
		self.message.text = ""
	if (animate):
		self.tween.interpolate_property(self, "modulate:a", (0 if target_visibility else 1), (1 if target_visibility else 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.tween.interpolate_property( self.background, "margin_top", (0 if target_visibility else -260), (-260 if target_visibility else 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.tweening_finished = false
		self.tween.start()
	else:
		self.modulate.a = (1 if target_visibility else 0)
		self.tweening_finished = true
		if self.modulate.a == 1:
			self.state = "standby"
		else:
			self.state = "disabled"
		if self.modulate.a == 0: self.visible = false
		self.background.margin_top = (-260 if target_visibility else 0)
		self._end_tween()

func _skip_tween():
	self.tween.playback_speed = 10.0

func _end_tween():
	self.tween.playback_speed = 1.0
	self.tween.remove_all()
	self.tweening_finished = true
	if self.modulate.a == 1: self.state = "standby"; else: self.state = "disabled"
	if self.modulate.a == 0: self.visible = false
	emit_signal("finished_tweening")

func _advance():
	if self.typing_finsihed && self.tweening_finished:
		self.next_caret.visible = false
		self._play_click_sfx()
		emit_signal("next")
		self.state = "standby"
	else:
		if !self.typing_finsihed:
			self._skip_typing()
		if !self.tweening_finished:
			self._skip_tween()

func _play_click_sfx():
	if (!self.play_advance_click_sound): return
	if (self.state != "waiting_input"): return
	self.click_sound_player.play()

func _on_click(event):
	if (event is InputEventMouseButton):
		if (event.button_index == BUTTON_LEFT and event.pressed):
			emit_signal("clicked")
			self._advance()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("clicked")
		self._advance()

func _on_tween_all_completed():
	self._end_tween() # same procedure anyway

func _on_tween_started(object, key):
	if (object == self && key == ":modulate:a"):
		if (self.visible == false):
			self.message.bbcode_text = ""
			self.message.visible_characters = 0

func _on_tween_completed(object, key):
	if (object == self && key == ":modulate:a"):
		self.visible = true if (self.modulate.a == 1) else false

func _on_ClickableArea_mouse_entered(): emit_signal("hover_on")
func _on_ClickableArea_mouse_exited(): emit_signal("hover_off")

func _on_hover(): emit_signal("hover_on")
func _on_blur(): emit_signal("hover_off")
