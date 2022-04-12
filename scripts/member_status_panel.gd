extends Control

signal mouse_hover
signal mouse_blur
signal mouse_click

onready var panel_background: Node = $Panel/PanelBackground
func get_panel_background(): return self.panel_background
onready var overlay_container: Node = $Panel/PanelOverlays
func get_overlay_container(): return self.overlay_container
onready var full_overlay_container: Node = $Panel/FullOverlays
func get_full_overlay_container(): return self.full_overlay_container

var panel_background_battler: Node
var unit: PartyUnit

onready var animation_player: AnimationPlayer = $AnimationPlayer

func attach(u: PartyUnit):
	unit = u
	
	# rewrite name
	$Panel/VBoxContainer/MarginContainer/Name.set_text(unit.name)
	
	# set battler textures
	self.panel_background_battler = unit.battler_textures.get_node("PanelBackground").duplicate()
	if (self.panel_background_battler):
		$Panel/PanelBackground.add_child(self.panel_background_battler)
	# get icon, set invisible (to be copied by the battle scene script)
	var icon: Control = unit.battler_textures.get_node("Icon").duplicate()
	icon.visible = false
	self.add_child(icon)
	
	self.hp_number.set_text(String(unit.hp))
	self.ap_number.set_text(String(unit.ap))
	var hp_percentage = int(floor((float(unit.hp) / float(unit.maxhp)) * 100))
	self.hp_bar.value = hp_percentage
	var ap_percentage = int(floor((float(unit.ap) / float(unit.maxap)) * 100))
	self.ap_bar.value = ap_percentage
	
	connect_hpap_changes()
	connect_state_changes()

func connect_icon(icon: Control):
	icon.connect("mouse_entered", self, "_on_self_mouse_entered", ["icon"])
	icon.connect("mouse_exited", self, "_on_self_mouse_exited", ["icon"])

func connect_hpap_changes():
	unit.connect("hp_changed", self, "update_hp_display_by_signal")
	unit.connect("hp_changed", self, "damage_by_signal")
	unit.connect("ap_changed", self, "update_ap_display_by_signal")
	unit.connect("miss", self, "miss_by_signal")

func connect_state_changes():
	unit.connect("state_changed", self, "update_state_by_signal")

# active status

var active = false setget set_active
onready var active_tween = $Tweens/ActiveTween
onready var looping_active_tween = $Tweens/ActiveTween/LoopingActiveTween

func set_active(new_status: bool):
	active = new_status
	self.active_tween.remove_all()
	if (new_status == true):
		self.active_tween.interpolate_property(self.panel_background, "self_modulate:a", self.panel_background.self_modulate.a, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.looping_active_tween.interpolate_method(self.panel_background, "set_hue", 1, 0.9, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.looping_active_tween.interpolate_method(self.panel_background, "set_hue", 0.9, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
		self.active_tween.start()
		self.looping_active_tween.start()
	else:
		self.looping_active_tween.remove_all()
		self.active_tween.interpolate_property(self.panel_background, "self_modulate:a", self.panel_background.self_modulate.a, 0.5, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.active_tween.interpolate_method(self.panel_background, "set_hue", self.panel_background.get_material().get_shader_param("hue"), 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		self.active_tween.start()

# damage or heal

func damage_by_signal(change_data): return damage(change_data.change)
func damage(amount):
	if (amount > 0):
		self.heal_flash()
	else:
		var shake_strength = min(max((abs(float(amount)) / abs(float(unit.maxhp))) * 75, 20), 150)
		self.shake(1, shake_strength, 1)
		self.damage_flash()
	self.create_flying_number(amount)

func miss_by_signal(): return miss()
func miss():
	var flying_text = self.flying_text_basis.duplicate()
	flying_text.modulate.a = 0
	flying_text_container.add_child(flying_text)
	flying_text.self_modulate = Color("7529e4")
	flying_text.set_text("MISS")
	flying_text.set_anchors_preset(Control.PRESET_CENTER_TOP)
	flying_text.modulate.a = 1
	flying_text.visible = true
	flying_text_tween.interpolate_property(flying_text, "rect_position:y", 0.0, -150, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	flying_text_tween.interpolate_property(flying_text, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.0)
	flying_text_tween.start()

# shake

onready var panel: Node = $Panel
onready var shake_tween: Tween = $Tweens/ShakeTween
var current_shake_priority = 0

func _move(vector):
	self.panel.rect_position = Vector2(rand_range(-vector.x, vector.x), rand_range(-vector.y, vector.y))

func shake(shake_length, shake_power, shake_priority):
	if shake_priority >= self.current_shake_priority:
		self.current_shake_priority = shake_priority
		self.shake_tween.interpolate_method(self, "_move", Vector2(shake_power, shake_power), Vector2(0, 0), shake_length, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
		self.shake_tween.start()

func _on_ShakeTween_tween_completed(object, key):
	self.current_shake_priority = 0

# update hp/ap display

func update_hp_display_by_signal(change_data: Dictionary):
	update_hp_number(change_data.new_hp)
	update_hp_bar(change_data.new_hp)
func update_hp_display():
	update_hp_number()
	update_hp_bar()

func update_ap_display_by_signal(change_data: Dictionary):
	update_ap_number(change_data.new_ap)
	update_ap_bar(change_data.new_ap)
func update_ap_display():
	update_ap_number()
	update_ap_bar()

# update hp/ap text

onready var hp_number = $Panel/VBoxContainer/HBoxContainer/HPContainer/CenterContainer/HPNumber
onready var ap_number = $Panel/VBoxContainer/HBoxContainer/APContainer/CenterContainer/APNumber

func update_hp_number(new_value = null):
	if unit != null: self.hp_number.set_text(String(new_value) if new_value != null else String(unit.hp))
func update_ap_number(new_value = null):
	if unit != null: self.ap_number.set_text(String(new_value) if new_value != null else String(unit.ap))

# update hp/ap bar

onready var hp_bar = $Panel/VBoxContainer/HBoxContainer/HPContainer/HPBar
onready var hp_bar_change = $Panel/VBoxContainer/HBoxContainer/HPContainer/HPBar/Change
onready var hp_bar_tween = $Tweens/HPBarTween

onready var ap_bar = $Panel/VBoxContainer/HBoxContainer/APContainer/APBar
onready var ap_bar_change = $Panel/VBoxContainer/HBoxContainer/APContainer/APBar/Change
onready var ap_bar_tween = $Tweens/HPBarTween

func update_hp_bar(new_value = null): self.update_bar('hp', new_value)
func update_ap_bar(new_value = null): self.update_bar('ap', new_value)

func update_bar(type: String, new_value = null):
	if (unit == null): return
	
	var new_percentage: int
	var bar: TextureProgress
	var bar_change: TextureProgress
	var tween: Tween
	var decrease: bool
	match type:
		'hp':
			new_percentage = int(floor((float(new_value if new_value != null else unit.hp) / float(unit.maxhp)) * 100))
			bar = self.hp_bar
			bar_change = self.hp_bar_change
			tween = self.hp_bar_tween
		'ap':
			new_percentage = int(floor((float(new_value if new_value != null else unit.ap) / float(unit.maxap)) * 100))
			bar = self.ap_bar
			bar_change = self.ap_bar_change
			tween = self.ap_bar_tween
	
	decrease = new_percentage < bar.value
	if (decrease):
		bar_change.set_tint_progress(Color.red)
		bar.value = new_percentage
	else:
		bar_change.set_tint_progress(Color.green)
		bar_change.value = new_percentage
	
	tween.remove_all()
	var tween_target = bar_change if decrease else bar
	tween.interpolate_property(
		tween_target,
		"value",
		tween_target.value,
		new_percentage,
		0.25,
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN,
		0.5
	)
	tween.start()

# damage flash

func damage_flash():
	self.animation_player.stop(true)
	self.animation_player.play("RESET")
	yield(get_tree().create_timer(0.01), "timeout")
	self.animation_player.play("DamageFlash")

# heal flash

func heal_flash():
	self.animation_player.stop(true)
	self.animation_player.play("RESET")
	yield(get_tree().create_timer(0.01), "timeout")
	self.animation_player.play("HealFlash")

# buff flash

onready var buff_tween: Tween = $Tweens/BuffTween
onready var buff_overlay_rect: TextureRect = $Panel/PanelOverlays/BuffOverlayRect

func buff(): self.buffdebuff(true)
func debuff(): self.buffdebuff(false)

func buffdebuff(buff: bool):
	self.buff_tween.stop_all()
	self.panel_background.set_shine_width(0.2)
	self.panel_background.set_shine_angle(90)
	if (buff):
		self.panel_background.set_shine_location(1.2)
		self.panel_background.set_shine_color(Color.green)
		self.buff_overlay_rect.get_material().set_shader_param("hue", 1)
	else:
		self.panel_background.set_shine_location(-0.2)
		self.panel_background.set_shine_color(Color.red)
		self.buff_overlay_rect.get_material().set_shader_param("hue", 0)
	self.buff_overlay_rect.modulate.a = 0
	self.buff_tween.interpolate_property(self.buff_overlay_rect, "modulate:a", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if (buff):
		self.buff_tween.interpolate_method(self.panel_background, "set_shine_location", 1.2, -0.2, 0.6, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.1)
	else:
		self.buff_tween.interpolate_method(self.panel_background, "set_shine_location", -0.2, 1.2, 0.6, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.1)
	self.buff_tween.interpolate_property(self.buff_overlay_rect, "modulate:a", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.7)
	self.buff_tween.start()

func _on_BuffTween_tween_all_completed():
	self.buff_overlay_rect.modulate.a = 0

# flying numbers

onready var flying_text_container = $FlyingTexts
onready var flying_text_basis = $FlyingTexts/Sample
onready var flying_text_tween = $Tweens/FlyingTextTween

func create_flying_number(number):
	var type = 'neutral'
	if (number < 0): type = 'damage'
	if (number > 0): type = 'heal'
	
	var flying_text = self.flying_text_basis.duplicate()
	flying_text.modulate.a = 0
	self.flying_text_container.add_child(flying_text)
	match type:
		'damage': flying_text.self_modulate = Color("e04747")
		'heal': flying_text.self_modulate = Color("92d481")
	flying_text.set_text(String(int(abs(number))))
	flying_text.set_anchors_preset(Control.PRESET_CENTER_TOP)
	flying_text.modulate.a = 1
	flying_text.visible = true
	flying_text_tween.interpolate_property(flying_text, "rect_position:y", 0.0, -150, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	flying_text_tween.interpolate_property(flying_text, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1.0)
	flying_text_tween.start()

func _on_FlyingTextTween_tween_completed(object, key):
	if (key == 'modulate:a' && object.modulate.a == 0):
		object.queue_free()

var hovered: bool = false

func _process(delta):
	if Input.is_action_just_pressed("mouse_left") and hovered:
		emit_signal("mouse_click", self)

func _on_self_mouse_entered(_area = null):
	hovered = true
	if not active: self.panel_background.self_modulate.a = 1
	emit_signal("mouse_hover", self)

func _on_self_mouse_exited(_area = null):
	hovered = false
	if not active: self.panel_background.self_modulate.a = 125.0/255.0
	emit_signal("mouse_blur", self)

onready var action_indicator = $Panel/ActionIndicatorContainer
onready var action_indicator_label = $Panel/ActionIndicatorContainer/ActionIndicatorLabel

func unset_action(): set_action(null)

func set_action(text = null):
	if text == null:
		action_indicator.set_visible(false)
	else:
		action_indicator_label.set_text(text)
		action_indicator.set_visible(true)

onready var dead_overlay = full_overlay_container.get_node("DeadOverlayRect")

func update_state_by_signal(change_data: Dictionary):
	dead_overlay.visible = unit.is_dead()

func get_infotext():
	var name = unit.name
	
	var buffs_text = ""
	var buffs = unit.get_buffs_in_string()
	for i in buffs:
		buffs_text += i + ", "
	buffs_text = buffs_text.trim_suffix(", ")
	
	return name + (" [" + buffs_text + "]" if buffs_text.length() > 0 else "")
