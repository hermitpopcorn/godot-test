extends Unit

class_name PartyUnit

signal ap_changed; signal ap_increased; signal ap_decreased

# party unit exclusive stats

var maxap = 1 setget set_maxap, get_maxap
var ap = 1 setget set_ap, get_ap
func set_maxap(new_value): maxap = new_value
func set_ap(new_value):
	if (ap > new_value):
		emit_signal("ap_changed")
		emit_signal("ap_decreased")
	elif (ap < new_value):
		emit_signal("ap_changed")
		emit_signal("ap_increased")
	ap = new_value
func get_ap(): return ap

func full_heal():
	.full_heal()
	self.ap = self.maxap
	emit_signal("ap_changed")

var level = 1
var lck = 5

# stat curves (scaling by level)

var maxhp_curve = { 1: 200 }
var maxap_curve = { 1: 150 }
var atk_curve = { 1: 10 }
var def_curve = { 1: 10 }
var hit_curve = { 1: 10 }
var eva_curve = { 1: 10 }
var spd_curve = { 1: 20 }

func get_base_maxhp(): return get_base_stat_from_curve(maxhp_curve)
func get_base_maxap(): return get_base_stat_from_curve(maxap_curve)
func get_base_atk(): return get_base_stat_from_curve(atk_curve)
func get_base_def(): return get_base_stat_from_curve(def_curve)
func get_base_hit(): return get_base_stat_from_curve(hit_curve)
func get_base_eva(): return get_base_stat_from_curve(eva_curve)
func get_base_spd(): return get_base_stat_from_curve(spd_curve)

func get_base_stat_from_curve(curve, at_level = null):
	var on_level = at_level if at_level != null else self.level
	var value = curve[on_level]
	if (value != null): return value
	
	while (value == null):
		on_level -= 1
		value = curve[on_level]
		if (on_level <= 0): return 0
	return value

func get_base_stat(stat):
	return self.call("get_base_" + stat)

func get_stat(stat):
	var base = get_base_stat(stat)
	var equipment = get_equipment_stat(stat)
	return base + equipment

func get_maxhp(): return get_stat('maxhp')
func get_maxap(): return get_stat('maxap')
func get_atk(): return get_stat('atk')
func get_def(): return get_stat('def')
func get_hit(): return get_stat('hit')
func get_eva(): return get_stat('eva')
func get_spd(): return get_stat('spd')

# equipment

export(Resource) var weapon = null
export(Resource) var armor = null
export(Resource) var accessory = null

func get_equipment_stat(stat):
	var sum: int = 0
	if (self.weapon): sum += weapon.get(stat)
	if (self.armor): sum += armor.get(stat)
	if (self.accessory): sum += accessory.get(stat)
	return sum

# visuals

export(PackedScene) var battler_textures = null

func get_attack_animation():
	if weapon != null:
		if weapon.animation_scene != null and weapon.animation_name != null:
			return { 'packed_scene': weapon.animation_scene, 'animation_name': weapon.animation_name }
	
	return .get_attack_animation()
