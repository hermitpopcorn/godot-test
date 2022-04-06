extends EnemyUnit

func _init(assign_name = null):
	name = "Si Kompret"
	if assign_name != null: name = assign_name
	maxhp = 95
	atk = 15
	def = 9
	hit = 8
	eva = 3
	full_heal()
	actions_per_turn = 2
	multi_action_type = BattleDatabase.MultiActionType.CONSECUTIVE

func decide_actions(party_battlers: Array, enemy_battlers: Array, party_actions: Dictionary) -> Array:
	var hp_percentage = (float(hp) / float(maxhp)) * 100
	if hp_percentage < 25:
		return repeat_action({
			"action": BattleDatabase.Actions.DEFEND,
		})
	return .decide_actions(party_battlers, enemy_battlers, party_actions)
