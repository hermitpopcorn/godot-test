extends Resource

class_name Skill

export(String) var key
export(String) var name
export(int) var ap_cost = 0 setget ,get_ap_cost
export(float) var hp_cost = 0 setget ,get_hp_cost
export(int) var base_power = 0
export(String) var description
export(bool) var usable_outside_battle: bool = false
export(BattleDatabase.TargetingType) var targeting_type = BattleDatabase.TargetingType.NONE
export(BattleDatabase.SkillType) var skill_type = BattleDatabase.SkillType.DAMAGE
export(int) var speed_penalty = 3

func get_ap_cost():
	return ap_cost

func get_hp_cost():
	return hp_cost

func calc_hp_cost(maxhp) -> int:
	if hp_cost == 0: return 0
	return int(round(maxhp * hp_cost))

func get_power():
	return base_power

func get_infotext_string(user: Unit, target: Array) -> String:
	var target_string = null
	if user == target.front():
		target_string = "self"
	elif target.size() == 1:
		target_string = target.front().name
	elif target.size() > 1:
		target_string = target.front().name + "'s team"
	return user.name + " casts " + self.name + ((" on " + target_string) if target_string != null else "") + "!"

func drain_hpap(user: Unit):
	if user is EnemyUnit: return true
	if self.ap_cost > 0:
		if user.ap < self.ap_cost:
			return false
	if self.hp_cost > 0:
		if user.hp <= self.calc_hp_cost(user.maxhp):
			return false
	
	if self.ap_cost > 0: user.ap -= self.ap_cost
	if self.hp_cost > 0: user.hp -= self.calc_hp_cost(user.maxhp)
	
	return true

func apply_effect(user: Unit, targets: Array, battle_calculations = null) -> Dictionary:
	var results = {}
	for target in targets:
		results[target] = { 'hit': false }
	return results

func get_animation() -> Dictionary:
	return {
		"user": null,
		"target": null,
		"scene": null,
	}
