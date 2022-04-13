extends Resource

class_name Unit

var name = "Zeneon"

# stats

var maxhp = 1 setget set_maxhp, get_maxhp
var hp = 1 setget set_hp, get_hp
var atk = 1 setget set_atk, get_atk
var def = 1 setget set_def, get_def
var hit = 1 setget set_hit, get_hit
var eva = 1 setget set_eva, get_eva

# stat setter/getters (for overriding)

func set_maxhp(new_value): maxhp = new_value
func set_atk(new_value): atk = new_value
func set_def(new_value): def = new_value
func set_hit(new_value): hit = new_value
func set_eva(new_value): eva = new_value

# hp, ap setter/getter

signal hp_changed; signal hp_increased; signal hp_decreased
signal death
signal buff_changed
signal state_changed

func set_hp(new_value):
	if (hp > new_value):
		emit_signal("hp_decreased")
	elif (hp < new_value):
		emit_signal("hp_increased")
	var change = new_value - hp
	hp = int(max(0, new_value))
	emit_signal("hp_changed", { "new_hp": hp, "change": change })
	if hp < 1:
		clear_states()
		add_state(BattleDatabase.UnitStates.KNOCKOUT)
		emit_signal("death")

func get_hp(): return hp

func full_heal():
	self.hp = self.maxhp

# other stats

func get_stat(stat):
	var base
	match stat.to_lower():
		'maxhp': base = maxhp
		'atk': base = atk
		'def': base = def
		'hit': base = hit
		'eva': base = eva
		'spd': base = spd
	var buff_modifier: float = get_buff_modifier(stat, base)
	var calculated = round(float(base) + buff_modifier)
	return calculated

func get_maxhp(): return get_stat('maxhp')
func get_atk(): return get_stat('atk')
func get_def(): return get_stat('def')
func get_hit(): return get_stat('hit')
func get_eva(): return get_stat('eva')

# speed

var spd = 20 setget set_spd, get_spd

func set_spd(new_value): spd = new_value
func get_spd(): return get_stat('spd')

var actions_per_turn = 1
var multi_action_type = BattleDatabase.MultiActionType.CONSECUTIVE

# buffs and states

var buffs = {}
var states = {}

func is_dead(): return states.has(BattleDatabase.UnitStates.KNOCKOUT)
func is_knocked_out(): return states.has(BattleDatabase.UnitStates.KNOCKOUT)
func can_move(): return !states.has(BattleDatabase.UnitStates.KNOCKOUT)

func add_state(state, data = true):
	states[state] = data
	emit_signal("state_changed", { "added": [state] })

func remove_state(state):
	states.erase(state)
	emit_signal("state_changed", { "removed": [state] })

func clear_states():
	var current_states = states.duplicate()
	states.clear()
	emit_signal("state_changed", { "removed": current_states })

func apply_buff(buff, amount):
	if amount == 0:
		buffs.erase(buff)
		emit_signal("buff_changed", { "applied": [buff, 0] })
	else:
		if buffs.has(buff):
			buffs[buff] += amount
			if buffs[buff] > 3: buffs[buff] = 3
			if buffs[buff] < -3: buffs[buff] = -3
		else:
			buffs[buff] = amount
		emit_signal("buff_changed", { "applied": [buff, buffs[buff]] })
		if buffs[buff] == 0: buffs.erase(buff)

func set_buff(buff, amount):
	buffs[buff] = amount
	emit_signal("buff_changed", { "applied": [buff, amount] })

func remove_buff(buff):
	buffs.erase(buff)
	emit_signal("buff_changed", { "applied": [buff, 0] })

func clear_buffs():
	buffs.clear()
	emit_signal("buff_changed", { "cleared": true })

func get_buff_modifier(stat: String, base_stat: int) -> float:
	var buff_amount = 0
	if ['atk', 'def', 'hit', 'eva'].has(stat):
		match stat.to_lower():
			'atk': buff_amount = buffs[BattleDatabase.BuffsDebuffs.ATK] if buffs.has(BattleDatabase.BuffsDebuffs.ATK) else 0
			'def': buff_amount = buffs[BattleDatabase.BuffsDebuffs.DEF] if buffs.has(BattleDatabase.BuffsDebuffs.DEF) else 0
			'hit': buff_amount = buffs[BattleDatabase.BuffsDebuffs.HIT] if buffs.has(BattleDatabase.BuffsDebuffs.HIT) else 0
			'eva': buff_amount = buffs[BattleDatabase.BuffsDebuffs.EVA] if buffs.has(BattleDatabase.BuffsDebuffs.EVA) else 0
		var bm = 0.0
		if buff_amount > 0:
			bm = [0.0, 0.2, 0.35, 0.5][int(abs(buff_amount))]
		else:
			bm = [0.0, 0.15, 0.25, 0.4][int(abs(buff_amount))]
			bm = bm * -1
		return float(bm) * float(base_stat)
	return 0.0

func get_buffs_in_string():
	var buff_strings = []
	for buff_type in BattleDatabase.BuffsDebuffs.values():
		if buffs.has(buff_type):
			var buff_name = BattleDatabase.BuffsDebuffs.keys()[buff_type]
			var amount = ""
			if buffs[buff_type] > 0:
				amount = "+".repeat(buffs[buff_type])
			elif buffs[buff_type] < 0:
				amount = "-".repeat(buffs[buff_type] * -1)
			buff_strings.append(buff_name + amount)
	return buff_strings

var defending = false

# visuals

export(PackedScene) var attack_animation_scene
export(String) var attack_animation_name

func get_attack_animation():
	if attack_animation_scene != null and attack_animation_name != null:
		return { "packed_scene": attack_animation_scene, "animation_name": attack_animation_name }
	else:
		return { "packed_scene": preload("res://animations/attacks.tscn"), "animation_name": "hit" }

signal miss
func signal_miss():
	emit_signal("miss")
