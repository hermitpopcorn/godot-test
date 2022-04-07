extends Node

enum InfoTextType { PROMPT, PARTY_INFO, ENEMY_INFO, NARRATION }

var battle_calculations = preload("res://scripts/battle_calculations.gd").new()

onready var gui: Node = $GUILayer/GUI

func _ready():
	_debug_ready()
	start_battle()

var stop = true
var turn_number = 0
var party_battlers = []
var party_battlers_link = {} # connects party battlers with the member status panel
var enemy_battlers = []
var enemy_battlers_link = {} # connects enemy battlers with their respective nodes
var party_actions = {} # temporary variable to store inputted party actions before merged to actions
var actions = [] # all actions to be taken, both party's and enemies'
var actions_link = {} # connectsbattlers with their chosen [actions]
var turn_order = [] # array of battlers (units) showing who moves first
var speed_penalties = {}

onready var party_status_container = $GUILayer/GUI/PartyStatusContainer
onready var command_panel = $GUILayer/GUI/CommandPanel
onready var active_battler_portrait = $GUILayer/GUI/ActiveBattlerPortrait

func prepare_ui():
	# create party member panels
	var member_status_panel_packedscene = preload("res://components/member_status.tscn")
	for unit in party_battlers:
		var new_member_status_panel = member_status_panel_packedscene.instance()
		self.party_status_container.add_child(new_member_status_panel)
		new_member_status_panel.attach(unit)
		self.party_battlers_link[unit] = new_member_status_panel
		new_member_status_panel.connect("mouse_hover", self, "_on_party_hover")
		new_member_status_panel.connect("mouse_blur", self, "_on_party_blur")
		new_member_status_panel.connect("mouse_click", self, "_on_party_click")
		unit.connect("death", self, "_on_party_death", [unit])
	
	# add portraits
	for unit in party_battlers:
		var portrait: TextureRect = unit.battler_textures.get_node("PanelBackground").duplicate()
		self.active_battler_portrait.add_child(portrait)
		portrait.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_COVERED)
		portrait.set_anchors_and_margins_preset(Control.PRESET_WIDE)
		portrait.rect_position.x = self.active_battler_portrait.rect_size.x
	self.active_battler_portrait.visible = false
	
	# hide command panel
	self.command_panel.rect_position.x = self.command_panel.rect_size.x * -1
	self.command_panel.visible = false

onready var enemies_container = $Enemies

func prepare_enemy_battlers(enemy_cluster: Node):
	self.enemy_battlers_link.clear()
	self.enemies_container.add_child(enemy_cluster)
	for node in enemy_cluster.get_children():
		self.enemy_battlers.append(node.unit)
		self.enemy_battlers_link[node.unit] = node
		node.connect("mouse_hover", self, "_on_enemy_hover")
		node.connect("mouse_blur", self, "_on_enemy_blur")
		node.connect("mouse_click", self, "_on_enemy_click")
		node.unit.connect("death", self, "_on_enemy_death", [node.unit])

func start_battle():
	# TODO: process pre battle things
	turn_number = 1
	stop = false
	start_turn()

func stop_battle():
	stop = true

func start_turn():
	actions.clear()
	calculate_turn_order()
	start_command_input()

func process_turn():
	decide_enemy_actions()
	
	reorder_turns()
	
	while (turn_order.size() > 0) and !stop:
		var acting_battler = turn_order.pop_front()
		
		# skip if dead
		if !acting_battler.can_move():
			erase_turn_icon(acting_battler)
			continue;
		
		# get action
		var action = actions[actions_link[acting_battler].pop_front()]
		
		# do action
		yield(
			execute_action(acting_battler, action),
		"completed")
		
		# wait
		yield(get_tree().create_timer(0.2), "timeout")
		
		# cleanup
		erase_turn_icon(acting_battler)
		remove_infotext(InfoTextType.NARRATION)
		
		# TODO: victory and defeat
		check_battle_end()
	
	yield(get_tree().create_timer(0.5), "timeout")
	end_turn()

func check_battle_end():
	if check_enemy_all_dead():
		victory()
	elif check_party_all_dead():
		defeat()

func check_enemy_all_dead():
	for i in enemy_battlers:
		if !i.is_dead(): return false
	return true

func check_party_all_dead():
	for i in party_battlers:
		if !i.is_dead(): return false
	return true

func victory():
	stop_battle()
	clear_defenses()
	add_infotext(InfoTextType.NARRATION, "Glory to mankind.")

func defeat():
	stop_battle()
	add_infotext(InfoTextType.NARRATION, "The party is wiped out...")
	yield(get_tree().create_timer(0.5), "timeout")
	# game_over()

func execute_action(battler, action_dict: Dictionary):
	var action = action_dict.action
	var target = action_dict.target if action_dict.has('target') else null
	
	# TODO: randomize target if target is dead
	if target != null:
		if target is Unit and target.is_dead():
			if (battler is PartyUnit):
				target = randomize_enemy_target()
			elif (battler is EnemyUnit):
				target = randomize_party_target()
			else:
				return
	
	match action:
		BattleDatabase.Actions.ATTACK:
			yield(
				execute_attack(battler, target),
			"completed")
		BattleDatabase.Actions.DEFEND:
			yield(
				execute_defend(battler),
			"completed")
				
func randomize_enemy_target(): return randomize_target(enemy_battlers)
func randomize_party_target(): return randomize_target(party_battlers)

func randomize_target(battlers):
	var randomizer = RandomNumberGenerator.new()
	var living_targets = []
	for i in battlers:
		if not i.is_dead(): living_targets.append(i)
	if living_targets.empty(): return null
	randomizer.randomize()
	var random_index = randomizer.randi_range(0, living_targets.size() - 1)
	return living_targets[random_index]

func highlight_active_party_member(attacking_battler):
	self.party_battlers_link[attacking_battler].active = true
	
	var index = self.party_battlers_link[attacking_battler].get_index()
	var p = self.active_battler_portrait.get_child(index)
	p.visible = true
	self.atp_tween.interpolate_property(p, "rect_position:x", self.active_battler_portrait.rect_size.x, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	self.atp_tween.start()

func dehighlight_active_party_member(attacking_battler):
	self.party_battlers_link[attacking_battler].active = false
	
	var index = self.party_battlers_link[attacking_battler].get_index()
	var p = self.active_battler_portrait.get_child(index)
	self.atp_tween.interpolate_property(p, "rect_position:x", p.rect_position.x, self.active_battler_portrait.rect_size.x, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	self.atp_tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	p.visible = false

func execute_attack(attacking_battler, attacked_battler):
	highlight_action(attacking_battler)
	add_infotext(InfoTextType.NARRATION, attacking_battler.name + " attacks " + attacked_battler.name + "!")
	yield(get_tree().create_timer(0.4), "timeout")
	
	var result = battle_calculations.process_attack(attacking_battler, attacked_battler)
	if not result.hit:
		add_infotext(InfoTextType.NARRATION, "But they missed...")
		yield(get_tree().create_timer(1), "timeout")
	else:
		var animation
		animation = attacking_battler.get_attack_animation()
		yield(
			play_animation(animation, attacked_battler, result),
		"completed")
	
	# penalty
	add_speed_penalty(attacking_battler, battle_calculations.ATTACK_SPEED_PENALTY)
	
	dehighlight_action(attacking_battler)

func execute_defend(defending_battler):
	highlight_action(defending_battler)
	add_infotext(InfoTextType.NARRATION, defending_battler.name + " raises their guard!")
	yield(get_tree().create_timer(1), "timeout")
	
	defending_battler.defending = true
	dehighlight_action(defending_battler)

func highlight_action(battler):
	if (battler is PartyUnit):
		highlight_active_party_member(battler)
	elif (battler is EnemyUnit):
		self.enemy_battlers_link[battler].flash_action()

func dehighlight_action(battler):
	if (battler is PartyUnit):
		dehighlight_active_party_member(battler)

func add_speed_penalty(battler, speed_penalty):
	if not speed_penalties.has(battler): speed_penalties[battler] = 0
	speed_penalties[battler] += speed_penalty

onready var animation_layer = $AnimationLayer

func play_animation(animation: Dictionary, battler: Unit, result):
	var position: Vector2 = Vector2(0, 0)
	if (battler is PartyUnit):
		position = self.party_status_container.get_position()
		position += self.party_battlers_link[battler].get_position()
		position += self.party_battlers_link[battler].get_size() / 2
	elif (battler is EnemyUnit):
		position = self.enemies_container.get_position()
		position += self.enemy_battlers_link[battler].get_position()
	
	var animation_node: Node = animation.packed_scene.instance()
	animation_layer.add_child(animation_node)
	animation_node.set_position(position)
	var hit_frame = animation_node.play(animation.animation_name)
	yield(get_tree().create_timer(hit_frame), "timeout")
	add_infotext(InfoTextType.NARRATION, "Dealt " + String(abs(int(result.hp))) + " damage!")
	battler.hp += result.hp
	yield(get_tree().create_timer(0.5), "timeout")
	animation_node.queue_free()

func clear_defenses():
	for i in party_battlers: i.defending = false
	for i in enemy_battlers: i.defending = false

func end_turn():
	# do end turn things
	clear_defenses()
	
	if !stop:
		turn_number += 1
		start_turn()

func calculate_turn_order():
	self.turn_order = []
	var randomizer = RandomNumberGenerator.new()
	var speeds = []
	var all_battlers = []
	all_battlers.append_array(party_battlers)
	for unit in enemy_battlers:
		if unit.multi_action_type == BattleDatabase.MultiActionType.SPREAD:
			for times in unit.actions_per_turn:
				all_battlers.append(unit)
		else:
			all_battlers.append(unit)
	for battler in all_battlers:
		if battler.is_dead(): continue
		
		var speed: float = float(battler.spd)
		
		randomizer.randomize()
		speed += randomizer.randf_range(-2, 2)
		
		if (speed_penalties.has(battler)):
			speed -= speed_penalties[battler]
		
		speeds.append({ 'battler': battler, 'speed': speed })
	speeds.sort_custom(self, "sort_turn_order")
	for i in speeds:
		if i.battler.actions_per_turn > 1:
			if i.battler.multi_action_type == BattleDatabase.MultiActionType.CONSECUTIVE:
				for ii in i.battler.actions_per_turn:
					self.turn_order.append(i.battler)
				continue
		self.turn_order.append(i.battler)
	display_turn_order()

func sort_turn_order(a, b):
	if (a.speed > b.speed):
		return true
	else:
		return false

func reorder_turns():
	var move_up_battler = []
	var move_up_action = []
	var action_index_track = {}
	for battler in turn_order:
		if !action_index_track.has(battler): action_index_track[battler] = -1
		action_index_track[battler] += 1
		
		var battler_actions = actions_link[battler]
		var action_index = battler_actions[action_index_track[battler]]
		var action_entry = actions[action_index]
		if action_entry.action == BattleDatabase.Actions.DEFEND:
			move_up_battler.append(battler)
			move_up_action.append({ "battler": battler, "action": action_index })
	
	for to_be_moved in move_up_action:
		var index = actions_link[to_be_moved.battler].find_last(to_be_moved.action)
		var action = actions_link[to_be_moved.battler].pop_at(index)
		actions_link[to_be_moved.battler].push_front(action)
	
	move_up_battler.invert()
	for to_be_moved in move_up_battler:
		var index = turn_order.find_last(to_be_moved)
		var battler = turn_order.pop_at(index)
		turn_order.push_front(battler)

onready var turn_order_container = $GUILayer/GUI/TurnOrderDisplay/TurnOrderContainer
var turn_order_link = {}

func display_turn_order():
	# clear
	turn_order_link.clear()
	for i in turn_order_container.get_children():
		if i is Label: continue
		i.queue_free()
	# add
	for battler in turn_order:
		var icon: Control
		if battler is EnemyUnit:
			icon = self.enemy_battlers_link[battler].get_node("Icon").duplicate()
		elif battler is PartyUnit:
			icon = self.party_battlers_link[battler].get_node("Icon").duplicate()
			self.party_battlers_link[battler].connect_icon(icon)
		icon.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
		icon.set_v_size_flags(Control.SIZE_SHRINK_CENTER)
		turn_order_container.add_child(icon)
		icon.visible = true
		turn_order_link[icon] = battler

func erase_turn_icon(battler, all = false):
	for icon in turn_order_link.keys():
		if turn_order_link[icon] == battler:
			turn_order_link.erase(icon)
			icon.queue_free()
			if not all: return

onready var command_panel_tween = $GUILayer/CommandPanelTween
var active_input_index

func start_command_input():
	self.party_actions.clear()
	for i in party_battlers: unset_party_member_action(i) # clear action indicators
	
	self.command_panel_tween.remove_all()
	self.command_panel.visible = true
	self.command_panel_tween.interpolate_property(self.command_panel, "rect_position:x", self.command_panel.rect_size.x * -1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	self.command_panel_tween.start()
	
	active_input_index = -1
	next_command_input()

onready var command_buttons_container = $GUILayer/GUI/CommandPanel/ButtonsContainer

func next_command_input():
	selected_action = null
	remove_infotext(InfoTextType.PROMPT)
	for i in command_buttons_container.get_children(): i.disabled = false
	active_input_index += 1
	
	if (active_input_index < self.party_battlers.size()):
		if !self.party_battlers[active_input_index].can_move(): return next_command_input()
		show_active_input_member(active_input_index)
	else:
		end_command_input()
		process_turn()

func prev_command_input():
	if active_input_index <= 0: return
	if !get_backable_command_index(): return
	unset_party_member_action(party_battlers[active_input_index - 1])
	active_input_index -= 1
	if (self.party_battlers[active_input_index].is_dead()): return prev_command_input()
	show_active_input_member(active_input_index)

func get_nextable_command_index():
	var nextable = false
	var index_change = 1
	while !nextable:
		if self.party_battlers[active_input_index - index_change].can_move():
			return active_input_index + index_change
		else:
			index_change += 1
		if active_input_index > (self.party_battlers.size() - 1): return false

func get_backable_command_index():
	var backable = false
	var index_change = 1
	while !backable:
		if self.party_battlers[active_input_index - index_change].can_move():
			return active_input_index - index_change
		else:
			index_change += 1
		if (active_input_index - index_change) < 0: return false

func end_command_input():
	active_input_index = -1

	# shelve command panel
	self.command_panel_tween.remove_all()
	self.command_panel_tween.interpolate_property(self.command_panel, "rect_position:x", 0, self.command_panel.rect_size.x * -1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	self.command_panel_tween.start()

	# shelve portraits
	self.atp_tween.remove_all()
	for p in self.active_battler_portrait.get_children():
		self.atp_tween.interpolate_property(p, "rect_position:x", 0, self.active_battler_portrait.rect_size.x, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	self.atp_tween.start()

	# merge actions
	for battler in party_actions.keys():
		actions.append(party_actions[battler])
		var action_index = actions.size() - 1
		actions_link[battler] = [action_index]

onready var atp_tween = $GUILayer/PortraitTween

func show_active_input_member(index: int):
	# update command panel button(s)
	update_cancel_button()
	# reset everyone else
	for i in self.party_status_container.get_children(): i.active = false
	self.active_battler_portrait.visible = false
	for i in self.active_battler_portrait.get_children():
		i.visible = false
		i.rect_position.x = self.active_battler_portrait.rect_size.x
	# bring up active one
	self.party_status_container.get_child(index).active = true
	var p = self.active_battler_portrait.get_child(index)
	self.active_battler_portrait.visible = true
	p.visible = true
	self.atp_tween.remove_all()
	self.atp_tween.interpolate_property(p, "rect_position:x", self.active_battler_portrait.rect_size.x, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	self.atp_tween.start()

var selected_action = null

onready var button_tween = $GUILayer/ButtonTween
onready var attack_button = $GUILayer/GUI/CommandPanel/ButtonsContainer/Attack

func _on_Attack_button_up():
	if active_input_index < 0: return
	if selected_action == BattleDatabase.Actions.ATTACK: return
	attack_button.disabled = true
	selected_action = BattleDatabase.Actions.ATTACK
	start_targeting()

onready var defend_button = $GUILayer/GUI/CommandPanel/ButtonsContainer/Defend

func _on_Defend_button_up():
	cancel_selected_action()
	if active_input_index < 0: return
	set_party_member_action(self.party_battlers[self.active_input_index], {
		'action': BattleDatabase.Actions.DEFEND,
	})
	next_command_input()

onready var cancel_button = $GUILayer/GUI/CommandPanel/ButtonsContainer/Cancel

func _on_Cancel_button_up():
	if targeting_mode:
		cancel_selected_action()
	else:
		if active_input_index > 0: prev_command_input()
	update_cancel_button()

func cancel_selected_action():
	if selected_action == BattleDatabase.Actions.ATTACK:
		targeting_mode = false
		attack_button.disabled = false
		remove_infotext(InfoTextType.PROMPT)

func update_cancel_button():
	if targeting_mode:
		show_cancel_button("Cancel")
	elif active_input_index > 0:
		if get_backable_command_index():
			show_cancel_button("Back")
		else:
			hide_cancel_button()
	else:
		hide_cancel_button()

func show_cancel_button(text = null):
	if text != null:
		cancel_button.set_text(text)
	cancel_button.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	button_tween.remove_all()
	button_tween.interpolate_property(cancel_button, "self_modulate:a", cancel_button.self_modulate.a, 1, 0.2)
	button_tween.start()
func hide_cancel_button():
	cancel_button.set_default_cursor_shape(Control.CURSOR_ARROW)
	button_tween.remove_all()
	button_tween.interpolate_property(cancel_button, "self_modulate:a", cancel_button.self_modulate.a, 0, 0.2)
	button_tween.start()

func decide_enemy_actions():
	for unit in enemy_battlers:
		actions_link[unit] = []
		for action in unit.decide_actions(party_battlers, enemy_battlers, party_actions, turn_number):
			actions.append(action)
			var action_index = actions.size() - 1
			actions_link[unit].append(action_index)

var targeting_mode: bool = false

func start_targeting():
	targeting_mode = true
	update_cancel_button()
	add_infotext(InfoTextType.PROMPT, "Choose a target.")

var hovered_objects = {}

func _on_enemy_hover(node: Node, hovered_area: Array):
	if not hovered_objects.has(node):
		hovered_objects[node] = hovered_area
		add_infotext(InfoTextType.ENEMY_INFO, node.unit.name)

func _on_enemy_blur(node: Node, blurred_area: String):
	if hovered_objects.has(node):
		hovered_objects[node].erase(blurred_area)
		if hovered_objects[node].size() < 1:
			hovered_objects.erase(node)
			remove_infotext(InfoTextType.ENEMY_INFO)

func _on_enemy_click(node: Node, hovered_area: Array):
	if (targeting_mode):
		end_targeting(node.unit)

func _on_party_hover(node: Node):
	if not hovered_objects.has(node):
		hovered_objects[node] = ['status_panel']
		add_infotext(InfoTextType.PARTY_INFO, node.unit.name)

func _on_party_blur(node: Node):
	if hovered_objects.has(node):
		hovered_objects[node].erase('status_panel')
		if hovered_objects[node].size() < 1:
			hovered_objects.erase(node)
			remove_infotext(InfoTextType.PARTY_INFO)

func _on_party_click(node: Node):
	if (targeting_mode):
		end_targeting(node.unit)

func end_targeting(target_battler):
	self.targeting_mode = false
	set_party_member_action(self.party_battlers[self.active_input_index], {
		'action': self.selected_action,
		'target': target_battler,
	})
	next_command_input()

func action_string(action):
	match action:
		BattleDatabase.Actions.ATTACK: return "Attack"
		BattleDatabase.Actions.SKILL: return "Skill"
		BattleDatabase.Actions.DEFEND: return "Defend"
		BattleDatabase.Actions.CHANGE_EQUIPMENT: return "Equip"
		BattleDatabase.Actions.USE_ITEM: return "Item"
		BattleDatabase.Actions.RUN: return "Run"
	return "???"

func unset_party_member_action(battler):
	party_actions.erase(battler)
	party_battlers_link[battler].unset_action()

func set_party_member_action(battler: PartyUnit, the_action: Dictionary):
	party_actions[battler] = the_action
	party_battlers_link[battler].set_action(action_string(the_action.action))

var active_info_texts = {}
onready var infopanel_text = $GUILayer/GUI/InfoPanel/InfoPanelText

func add_infotext(type: int, text: String):
	active_info_texts[type] = text
	refresh_infotext()

func remove_infotext(type: int):
	active_info_texts.erase(type)
	refresh_infotext()

func refresh_infotext():
	if active_info_texts.size() < 1:
		infopanel_text.bbcode_text = ""
		return
	if active_info_texts.size() == 1:
		infopanel_text.bbcode_text = active_info_texts.values().front()
		return
	# sort by priority and display most important
	infopanel_text.bbcode_text = active_info_texts[active_info_texts.keys().max()]

func _on_enemy_death(unit: EnemyUnit):
	var node: Node = enemy_battlers_link[unit]
	turn_order.erase(node.unit)
	erase_turn_icon(node.unit, true)
	var death_animation_time = node.animate_death()
	yield(get_tree().create_timer(death_animation_time), "timeout")
	node.visible = false

func _on_party_death(unit: PartyUnit):
	pass

# visual effect
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

func _debug_ready():
	var kaput = preload("res://data/party_units/kaput_hunter/kaput_hunter.gd").new()
	var paul = preload("res://data/party_units/paul_kirigaya/paul_kirigaya.gd").new()
	var rifkaizer = preload("res://data/party_units/rifkaizer/rifkaizer.gd").new()
	var the_bonk = preload("res://data/party_units/the_bonk/the_bonk.gd").new()
	party_battlers.append(kaput)
	party_battlers.append(paul)
	party_battlers.append(rifkaizer)
	party_battlers.append(the_bonk)
	prepare_enemy_battlers(preload("res://data/enemy_clusters/si_kompret_bunshin.tscn").instance())
	prepare_ui()

func _input(event):
	if (Input.is_physical_key_pressed(KEY_Q)):
		gui_shake(1, 50, 1)
	if (Input.is_physical_key_pressed(KEY_W)):
		self.party_status_container.get_child(round(rand_range(0, 3))).damage(round(rand_range(-10.0, 10.0)) * 10)
	if (Input.is_physical_key_pressed(KEY_E)):
		self.party_status_container.get_child(round(rand_range(0, 3))).buff()
	if (Input.is_physical_key_pressed(KEY_R)):
		self.party_status_container.get_child(round(rand_range(0, 3))).debuff()
	if (Input.is_physical_key_pressed(KEY_Y)):
		self.party_status_container.get_child(round(rand_range(0, 3))).get_node("AnimationPlayer").play("RESET")
	if (Input.is_physical_key_pressed(KEY_U)):
		print(party_battlers[0].weapon.item_type)
		print(party_battlers[1].weapon.item_type)
		print(party_battlers[2].weapon.item_type)
		print(party_battlers[3].weapon.item_type)
