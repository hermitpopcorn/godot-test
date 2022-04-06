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
func get_maxhp(): return maxhp
func set_atk(new_value): atk = new_value
func get_atk(): return atk
func set_def(new_value): def = new_value
func get_def(): return def
func set_hit(new_value): hit = new_value
func get_hit(): return hit
func set_eva(new_value): eva = new_value
func get_eva(): return eva

# hp, ap setter/getter

signal hp_changed; signal hp_increased; signal hp_decreased
signal death
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

# speed

var spd = 20 setget set_spd, get_spd

func set_spd(new_value): spd = new_value
func get_spd(): return spd

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

var defending = false

# visuals

export(PackedScene) var attack_animation_scene
export(String) var attack_animation_name

func get_attack_animation():
	if attack_animation_scene != null and attack_animation_name != null:
		return { "packed_scene": attack_animation_scene, "animation_name": attack_animation_name }
	else:
		return { "packed_scene": preload("res://animations/attacks.tscn"), "animation_name": "hit" }
