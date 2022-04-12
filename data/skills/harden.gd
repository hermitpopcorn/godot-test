extends Skill

func _init():
	name = "Harden"
	key = "harden"
	ap_cost = 15
	base_power = 0
	description = "Raise defense for one unit."
	targeting_type = BattleDatabase.TargetingType.SINGLE
	speed_penalty = 3

func apply_effect(user: Unit, targets: Array, battle_calculations = null):
	var target = targets.front()
	target.apply_buff(BattleDatabase.BuffsDebuffs.DEF, 1)
	return { target: { 'hit': true } }

func get_animation() -> Dictionary:
	return {
		"user": null,
		"target": {
			"panel": ["buff_flash"],
			"sprite": [{ "packed_scene": preload("res://animations/attacks.tscn"), "animation_name": "hit" }],
		},
		"scene": null,
	}
