extends Node

onready var rng = RandomNumberGenerator.new()

var hitmiss_difference_power_factor = 1.5
var hitmiss_divide_factor = 2
var overaccuracy_limit = 1.25
var hit_variance = 5

var party_hit = 20
var party_eva = 20
var enemy_hit = 20
var enemy_eva = 20

func calculate_hitmiss(hit, eva):
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
	print("Difference: ", eva - hit, " | Dodge Factor: ", dodge_factor, " | Variance: ", variance)
	return (100 - dodge_factor - variance) / 100

func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")): hit()
	if (Input.is_action_just_pressed("toggle_cursor")): simulate(100)
	if (Input.is_action_just_pressed("ui_left")):
		party_hit -= 1
		party_eva -= 1
		print("Party HIT/EVA reduced to ", [party_hit, party_eva])
	if (Input.is_action_just_pressed("ui_right")):
		party_hit += 1
		party_eva += 1
		print("Party HIT/EVA increased to ", [party_hit, party_eva])
	if (Input.is_action_just_pressed("ui_down")):
		enemy_hit -= 1
		enemy_eva -= 1
		print("Enemy HIT/EVA reduced to ", [enemy_hit, enemy_eva])
	if (Input.is_action_just_pressed("ui_up")):
		enemy_hit += 1
		enemy_eva += 1
		print("Enemy HIT/EVA increased to ", [enemy_hit, enemy_eva])

func hit():
	var hit_chance
	var hit_roll
	var hit_success
	
	print("====== P -> E ======")
	hit_chance = calculate_hitmiss(party_hit, enemy_eva)
	rng.randomize()
	hit_roll = rng.randf()
	hit_success = hit_chance > hit_roll
	print("Hit chance: ", hit_chance, " | Hit roll: ", hit_roll)
	print("=> HIT!" if hit_success else "=> MISS...")
	var player_hit_success = hit_success
	
	print("====== E -> P ======")
	hit_chance = calculate_hitmiss(enemy_hit, party_eva)
	rng.randomize()
	hit_roll = rng.randf()
	hit_success = hit_chance > hit_roll
	print("Hit chance: ", hit_chance, " | Hit roll: ", hit_roll)
	print("=> HIT!" if hit_success else "=> MISS...")
	var enemy_hit_success = hit_success
	return [player_hit_success, enemy_hit_success]

func simulate(times: int):
	var player_hits = 0
	var enemy_hits = 0
	for i in times:
		print("[ Simulation " + String(i + 1) + " ]")
		var result = hit()
		if (result[0] == true): player_hits += 1
		if (result[1] == true): enemy_hits += 1
		print("")
	print("--- Simulation finished. ---")
	print("Player hits: ", player_hits , "/", times)
	print("Enemy hits: ", enemy_hits, "/", times)
