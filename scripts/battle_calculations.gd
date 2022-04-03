var rng: RandomNumberGenerator
func _init():
	rng = RandomNumberGenerator.new()

var hitmiss_difference_power_factor = 1.5
var hitmiss_divide_factor = 2
var overaccuracy_limit = 1.25
var hit_variance = 5

var base_damage_factor = 100
var damage_variance = 12

func calculate_hitchance(hit, eva) -> float:
	rng.randomize()
	var variance = rng.randf() * self.hit_variance
	var difference = float(eva) - float(hit)
	var dodge_factor = (
		pow(abs(difference), self.hitmiss_difference_power_factor) # difference ^ power factor
		* sign(difference) # set negative if HIT is bigger than EVA (and thus lowering the hit chance)
		/ self.hitmiss_divide_factor # divide by divide factor
	)
	# dampen overaccuracy (to allow variance)
	if (self.overaccuracy_limit != 0):
		dodge_factor = max(self.overaccuracy_limit * -1, dodge_factor)
	if OS.is_debug_build(): print("[BCAL][HITMISS] ", "HIT/EVA Difference: ", eva - hit, " | Dodge Factor: ", dodge_factor, " | Variance: ", variance)
	return (100 - dodge_factor - variance) / 100

func calculate_hit_or_miss(hit, eva) -> bool:
	var hit_chance = calculate_hitchance(hit, eva)
	rng.randomize()
	var hit_roll = rng.randf()
	return hit_chance > hit_roll

func calculate_damage(atk, def) -> float:
	rng.randomize()
	var variance = (rng.randf() * (self.damage_variance * 2)) - self.damage_variance
	var difference = float(atk) - float(def)
	if OS.is_debug_build(): print("[BCAL][DAMAGE] ", "ATK/DEF Difference: ", atk - def, " | Variance: ", variance)
	return round(
		(
			atk * (
				(self.base_damage_factor + difference)
				/ (self.base_damage_factor + def)
			)
		) * ((100 + variance) / 100)
	)

func process_attack(attacking_battler: Unit, attacked_battler: Unit) -> Dictionary:
	# check if miss or not
	var hit: bool = calculate_hit_or_miss(attacking_battler.hit, attacked_battler.eva)
	if not hit: return { 'hit': false }
	var damage: int = int(calculate_damage(attacking_battler.atk, attacked_battler.def))
	return { 'hit': true, 'hp': damage * -1 }
