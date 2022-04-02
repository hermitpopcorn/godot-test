extends Unit

class_name PartyUnit

# party unit exclusive stats

var level = 1
var lck = 5

# stat curves (scaling by level)

var maxhp_curve = { 1: 200 }
var maxap_curve = { 1: 150 }
var atk_curve = { 1: 10 }
var def_curve = { 1: 10 }
var hit_curve = { 1: 10 }
var eva_curve = { 1: 10 }

func get_base_maxhp(): return get_base_stat_from_curve(maxhp_curve)
func get_base_maxap(): return get_base_stat_from_curve(maxap_curve)
func get_base_atk(): return get_base_stat_from_curve(atk_curve)
func get_base_def(): return get_base_stat_from_curve(def_curve)
func get_base_hit(): return get_base_stat_from_curve(hit_curve)
func get_base_eva(): return get_base_stat_from_curve(eva_curve)

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

export(PackedScene) var battler_panel_texture_rect = null
