var rng: RandomNumberGenerator
func _init():
	rng = RandomNumberGenerator.new()

var HITMISS_DIFFERENCE_POWER_FACTOR = 1.5
var HITMISS_DIVIDE_FACTOR = 2
var OVERACCURACY_LIMIT = 1.25
var HIT_VARIANCE = 5

var BASE_DAMAGE_FACTOR = 100
var DAMAGE_VARIANCE = 12 # -6% to 6%
var DEFENSE_VARIANCE = 10 # -5% to 5%

var ATTACK_SPEED_PENALTY = 2

func calculate_hitchance(a: Unit, b: Unit) -> float:
	rng.randomize()
	
	# calculate dodge factor
	var difference = float(b.eva) - float(a.hit)
	var dodge_factor = (
		pow(abs(difference), HITMISS_DIFFERENCE_POWER_FACTOR) # difference ^ power factor
		* sign(difference) # set negative if HIT is bigger than EVA (and thus lowering the hit chance)
		/ HITMISS_DIVIDE_FACTOR # divide by divide factor
	)
	
	# dampen overaccuracy (to allow variance)
	if (OVERACCURACY_LIMIT != 0):
		dodge_factor = max(OVERACCURACY_LIMIT * -1, dodge_factor)
	
	var variance = rng.randf() * HIT_VARIANCE
	if OS.is_debug_build(): print("[BCAL][HITMISS] ", "HIT/EVA Difference: ", b.eva - a.hit, " | Dodge Factor: ", dodge_factor, " | Variance: ", variance)
	return (100 - dodge_factor - variance) / 100

func calculate_hit_or_miss(a: Unit, b: Unit) -> bool:
	var hit_chance = calculate_hitchance(a, b)
	rng.randomize()
	var hit_roll = rng.randf()
	return hit_chance > hit_roll

func calculate_damage(a: Unit, b: Unit) -> float:
	rng.randomize()
	var variance = (rng.randf() * (DAMAGE_VARIANCE * 2)) - DAMAGE_VARIANCE
	var difference = float(a.atk) - float(b.def)
	if OS.is_debug_build(): print("[BCAL][DAMAGE] ", "ATK/DEF Difference: ", a.atk - b.def, " | Variance: ", variance)
	var damage = (
		(
			a.atk * (
				(BASE_DAMAGE_FACTOR + difference)
				/ (BASE_DAMAGE_FACTOR + b.def)
			)
		) * ((100 + variance) / 100)
	)
	if b.defending:
		rng.randomize()
		var defense_variance = (rng.randf() * (DEFENSE_VARIANCE * 2)) - DEFENSE_VARIANCE
		damage = damage * (50 + defense_variance) / 100
	return round(damage)

func process_attack(attacking_battler: Unit, attacked_battler: Unit) -> Dictionary:
	# check if miss or not
	var hit: bool = calculate_hit_or_miss(attacking_battler, attacked_battler)
	if not hit: return { 'hit': false }
	var damage: int = int(calculate_damage(attacking_battler, attacked_battler))
	return { 'hit': true, 'hp': damage * -1 }
