extends Unit

class_name EnemyUnit

func determine_target(party_battlers: Array, enemy_battlers: Array, party_actions: Dictionary):
	var randomizer = RandomNumberGenerator.new()
	randomizer.randomize()
	return party_battlers[randomizer.randi_range(0, party_battlers.size() - 1)]

func decide_actions(party_battlers: Array, enemy_battlers: Array, party_actions: Dictionary) -> Array:
	var actions = []
	for i in self.actions_per_turn:
		actions.append({
			"action": BattleDatabase.Actions.ATTACK,
			"target": determine_target(party_battlers, enemy_battlers, party_actions),
		})
	return actions

func repeat_action(action: Dictionary) -> Array:
	var repeated_actions = []
	for i in self.actions_per_turn: repeated_actions.append(action)
	return repeated_actions
