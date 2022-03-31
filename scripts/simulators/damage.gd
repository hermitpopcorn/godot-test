extends Node

onready var rng = RandomNumberGenerator.new()

var base_damage_factor = 100
var damage_variance = 12

var simulator_atk = 50
var simulator_def = 50

func calculate_damage(atk, def):
	rng.randomize()
	var variance = (rng.randf() * (self.damage_variance * 2)) - self.damage_variance
	var difference = float(atk) - float(def)
	print("Difference: ", atk - def, " | Variance: ", variance)
	return round(
		(
			atk * (
				(self.base_damage_factor + difference)
				/ (self.base_damage_factor + def)
			)
		) * ((100 + variance) / 100)
	)

func _input(event):
	if (Input.is_key_pressed(KEY_B)): hit()
	if (Input.is_key_pressed(KEY_N)): simulate(100)
	if (Input.is_key_pressed(KEY_Z)):
		self.simulator_atk -= 1
		print("ATK reduced to ", [self.simulator_atk])
	if (Input.is_key_pressed(KEY_X)):
		self.simulator_atk += 1
		print("ATK increased to ", [self.simulator_atk])
	if (Input.is_key_pressed(KEY_C)):
		self.simulator_def -= 1
		print("DEF reduced to ", [self.simulator_def])
	if (Input.is_key_pressed(KEY_V)):
		self.simulator_def += 1
		print("DEF increased to ", [self.simulator_def])

func hit():
	print("====== ", self.simulator_atk, " ATK -> ", self.simulator_def, " DEF ======")
	var damage = self.calculate_damage(self.simulator_atk, self.simulator_def)
	print("DAMAGE: ", damage)
	return damage

func simulate(times: int):
	var damage_numbers = []
	for i in times:
		print("[ Simulation " + String(i + 1) + " ]")
		var result = self.hit()
		damage_numbers.append(result)
	print("--- Simulation finished. ---")
	var total = 0
	var highest = -1
	var lowest = -1
	for i in damage_numbers:
		total += i
		if (highest == -1): highest = i
		elif (i > highest): highest = i
		if (lowest == -1): lowest = i
		elif (i < lowest): lowest = i
	print("Mean damage: ", float(total) / damage_numbers.size())
	print("Highest damage: ", highest)
	print("Lowest damage: ", lowest)
