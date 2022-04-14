extends Skill

func _init():
	name = "Break"
	key = "break"
	ap_cost = 20
	base_power = 5
	description = "Attacks one unit and lowers their defense."
	targeting_type = BattleDatabase.TargetingType.SINGLE
	skill_type = BattleDatabase.SkillType.DAMAGE
	speed_penalty = 5

func apply_effect(user: Unit, targets: Array, battle_calculations = null):
	var results = {}
	for target in targets:
		var result = battle_calculations.process_attack(user, target, self.get_power())
		if (result.hit):
			target.apply_buff(BattleDatabase.BuffsDebuffs.DEF, -1)
		results[target] = result
	
	return results

func get_animation() -> Dictionary:
	return {
		"user": null,
		"target": {
			"panel": [{ "packed_scene": preload("res://animations/attacks.tscn"), "animation_name": "strike" }, "debuff_flash"],
			"sprite": [{ "packed_scene": preload("res://animations/attacks.tscn"), "animation_name": "strike" }],
		},
		"scene": null,
	}
