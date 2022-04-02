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
signal ap_changed; signal ap_increased; signal ap_decreased

func set_hp(new_value):
	if (hp > new_value):
		emit_signal("hp_changed")
		emit_signal("hp_decreased")
	elif (hp < new_value):
		emit_signal("hp_changed")
		emit_signal("hp_increased")
	hp = new_value

func get_hp(): return hp

func full_heal():
	self.hp = self.maxhp
	self.ap = self.maxap
	emit_signal("hp_changed")
	emit_signal("ap_changed")

# speed

var spd = 20 setget set_spd, get_spd

func set_spd(new_value): spd = new_value
func get_spd(): return spd

# buffs

var active_buffs = {}
var active_status_effect = {}
