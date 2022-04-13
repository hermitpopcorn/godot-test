extends EnemyUnit

func _init(assign_name = null):
	name = "M.E.G.A. Kompret"
	if assign_name != null: name = assign_name
	maxhp = 295
	atk = 25
	def = 18
	hit = 14
	eva = 8
	full_heal()
	actions_per_turn = 1
	multi_action_type = BattleDatabase.MultiActionType.CONSECUTIVE

func decide_actions(party_battlers: Array, enemy_battlers: Array, party_actions: Dictionary, turn_number: int) -> Array:
	var hp_percentage = (float(hp) / float(maxhp)) * 100
	if hp_percentage < 25:
		return repeat_action({
			"action": BattleDatabase.Actions.DEFEND,
		})
	return .decide_actions(party_battlers, enemy_battlers, party_actions, turn_number)
