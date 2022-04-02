extends Control

onready var panel_background: Node = $Panel/PanelBackground
func get_panel_background(): return self.panel_background
onready var overlay_container: Node = $Panel/PanelOverlays
func get_overlay_container(): return self.overlay_container
onready var full_overlay_container: Node = $Panel/FullOverlays
func get_full_overlay_container(): return self.full_overlay_container

onready var animation_player: AnimationPlayer = $AnimationPlayer

var maxhp = 100
var hp = 100
var maxap = 100
var ap = 100

func _ready():
	$Panel/VBoxContainer/HBoxContainer/HPContainer/CenterContainer/HPNumber.text = String(self.hp)
	$Panel/VBoxContainer/HBoxContainer/HPContainer/HPBar/Change.value = self.hp
	$Panel/VBoxContainer/HBoxContainer/HPContainer/HPBar.value = self.hp
	$Panel/VBoxContainer/HBoxContainer/APContainer/CenterContainer/APNumber.text = String(self.ap)
	$Panel/VBoxContainer/HBoxContainer/APContainer/APBar/Change.value = self.ap
	$Panel/VBoxContainer/HBoxContainer/APContainer/APBar.value = self.ap

func attach(unit: PartyUnit):
	$Panel/VBoxContainer/MarginContainer/Name.set_text(unit.name)
	if (unit.battler_panel_texture_rect):
		$Panel/PanelBackground.add_child(unit.battler_panel_texture_rect)
	
	self.maxhp = unit.maxhp
	self.hp = unit.hp
	self.maxap = unit.maxap
	self.ap = unit.ap
	update_hp_number()
	update_ap_number()
	update_hp_bar()
	update_ap_bar()

# damage or heal

func damage(amount):
	self.hp -= amount
	self.hp = min(max(0, self.hp), self.maxhp)
	
	if (amount > 0):
		var shake_strength = max((amount / self.maxhp) * 75, 20)
		self.shake(1, shake_strength, 1)
		self.damage_flash()
		self.create_flying_number('damage', amount)
	else:
		self.heal_flash()
		self.create_flying_number('heal', amount * -1)
	self.update_hp_number()
	self.update_hp_bar()

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

# update hp/ap text

onready var hp_number = $Panel/VBoxContainer/HBoxContainer/HPContainer/CenterContainer/HPNumber
onready var ap_number = $Panel/VBoxContainer/HBoxContainer/APContainer/CenterContainer/APNumber

func update_hp_number(): self.hp_number.set_text(String(self.hp))
func update_ap_number(): self.ap_number.set_text(String(self.ap))

# update hp/ap bar

onready var hp_bar = $Panel/VBoxContainer/HBoxContainer/HPContainer/HPBar
onready var hp_bar_change = $Panel/VBoxContainer/HBoxContainer/HPContainer/HPBar/Change
onready var hp_bar_tween = $Tweens/HPBarTween

onready var ap_bar = $Panel/VBoxContainer/HBoxContainer/APContainer/APBar
onready var ap_bar_change = $Panel/VBoxContainer/HBoxContainer/APContainer/APBar/Change
onready var ap_bar_tween = $Tweens/HPBarTween

func update_hp_bar(): self.update_bar('hp')
func update_ap_bar(): self.update_bar('ap')

func update_bar(type: String):
	var new_percentage: int
	var bar: TextureProgress
	var bar_change: TextureProgress
	var tween: Tween
	var decrease: bool
	match type:
		'hp':
			new_percentage = int(floor((self.hp / self.maxhp) * 100))
			bar = self.hp_bar
			bar_change = self.hp_bar_change
			tween = self.hp_bar_tween
		'ap':
			new_percentage = int(floor((self.ap / self.maxap) * 100))
			bar = self.ap_bar
			bar_change = self.hp_bar_change
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

func create_flying_number(type: String, number: int):
	var flying_text = self.flying_text_basis.duplicate()
	flying_text.modulate.a = 0
	self.flying_text_container.add_child(flying_text)
	match type:
		'damage': flying_text.self_modulate = Color("e04747")
		'heal': flying_text.self_modulate = Color("92d481")
	flying_text.set_text(String(number))
	flying_text.set_anchors_preset(Control.PRESET_CENTER_TOP)
	flying_text.modulate.a = 1
	flying_text.visible = true
	flying_text_tween.interpolate_property(flying_text, "rect_position:y", 0.0, -150, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	flying_text_tween.interpolate_property(flying_text, "modulate:a", 1.0, 0.0, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	flying_text_tween.start()

func _on_FlyingTextTween_tween_completed(object, key):
	if (key == 'modulate:a' && object.modulate.a == 0):
		object.queue_free()
