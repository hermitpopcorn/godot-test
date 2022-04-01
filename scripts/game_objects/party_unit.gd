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

func get_base_maxhp(): return get_base_stat(maxhp_curve)
func get_base_maxap(): return get_base_stat(maxap_curve)
func get_base_atk(): return get_base_stat(atk_curve)
func get_base_def(): return get_base_stat(def_curve)
func get_base_hit(): return get_base_stat(hit_curve)
func get_base_eva(): return get_base_stat(eva_curve)

func get_base_stat(curve):
	var on_level = self.level
	var value = curve[on_level]
	if (value != null): return value
	
	while (value == null):
		on_level -= 1
		value = curve[on_level]
		if (on_level <= 0): return 0
	return value

func get_maxhp():
	var base = get_base_maxhp()
	return base
func get_maxap():
	var base = get_base_maxap()
	return base
func get_atk():
	var base = get_base_atk()
	return base
func get_def():
	var base = get_base_def()
	return base
func get_hit():
	var base = get_base_hit()
	return base
func get_eva():
	var base = get_base_eva()
	return base

# equipment

var weapon
var armor
var accessory
