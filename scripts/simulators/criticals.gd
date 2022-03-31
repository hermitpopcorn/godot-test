extends Node

onready var rng = RandomNumberGenerator.new()
var lck_points = 20
var lck_distrib_chance = [
	1,
	2, 2,
	3, 3, 3, 3, 3,
	4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
	5, 5, 5, 5, 5, 5, 5, 5,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	7, 7, 7, 7, 7,
	8, 8, 8,
	9, 9,
	10
]
var party_luck = [10, 5, 4, 1]
var critical_deal_chance = {
	0: 0,
	1: 1.0/100,
	2: 3.0/100,
	3: 5.0/100,
	4: 8.0/100,
	5: 10.0/100,
	6: 15.0/100,
	7: 19.0/100,
	8: 27.0/100,
	9: 35.0/100,
	10: 40.0/100,
}
var critical_receive_chance = {
	0: 0,
	1: 25.0/100,
	2: 21.0/100,
	3: 16.0/100,
	4: 12.0/100,
	5: 10.0/100,
	6: 9.0/100,
	7: 8.0/100,
	8: 5.0/100,
	9: 2.0/100,
	10: 1.0/100,
}
var critical_deal_proof = 0.0
var critical_receive_proof = 0.0
var critical_deal_proof_decay = 0.1
var critical_receive_proof_decay = 0.1
var critical_deal_proof_increase = 0.3
var critical_receive_proof_increase = 0.4

func _input(event):
	if (Input.is_key_pressed(KEY_Q)): reroll()
	if (Input.is_key_pressed(KEY_W)): attack()
	if (Input.is_key_pressed(KEY_E)): defense()
	if (Input.is_key_pressed(KEY_R)): simulate(10, true)
	if (Input.is_key_pressed(KEY_T)): simulate(10, false)

func reroll():
	print("=== Reroll ===")
	rng.randomize()
	var remaining = self.lck_points
	var distribution_table = self.lck_distrib_chance.duplicate()
	var distribution = []
	for i in 3:
		if (remaining <= 10):
			for ii in range(remaining, 10+1):
				while distribution_table.has(ii): distribution_table.erase(ii)
		
		var random_index = rng.randi_range(0, distribution_table.size() - 1)
		var luck = distribution_table[random_index]
		distribution_table.remove(random_index)
		remaining -= luck
		distribution.append(luck)
	
	while (remaining > 10):
		var random_index = rng.randi_range(0, 2)
		if (distribution[random_index] < 9):
			distribution[random_index] += 1
			remaining -= 1
	
	distribution.append(remaining)
	distribution.shuffle()
	print("Reroll complete: " + String(distribution))
	self.party_luck = distribution.duplicate()

func attack() -> Array:
	print("=== Attack ===")
	return battle_turn('a')

func defense() -> Array:
	print("=== Defense ===")
	return battle_turn('d')

func battle_turn(what) -> Array:
	var critical_status = []
	var log_backlog = []
	for i in party_luck:
		rng.randomize()
		var critical = false
		var critical_chance = 0
		if (what == 'a'):
			critical_chance = self.critical_deal_chance.get(i)
		elif (what == 'd'):
			critical_chance = self.critical_receive_chance.get(i)
		var hit = rng.randf()
		if (hit <= critical_chance):
			critical = true
			
			# critical canceler
			var canceler_chance = 0
			if (what == 'a'): canceler_chance = self.critical_deal_proof
			elif (what == 'd'): canceler_chance = self.critical_receive_proof
			if (canceler_chance > 0):
				rng.randomize()
				var cancel_hit = rng.randf()
				if (cancel_hit <= canceler_chance):
					log_backlog.append("> CRITICAL canceled!")
					critical = false
			
			if (critical):
				if (what == 'a'):
					self.critical_deal_proof += self.critical_deal_proof_increase
					if (self.critical_deal_proof > 1.0): self.critical_deal_proof = 1.0
					log_backlog.append("> Critical Deal Proof increased to " + String(self.critical_deal_proof))
				elif (what == 'd'):
					self.critical_receive_proof += self.critical_receive_proof_increase
					if (self.critical_receive_proof > 1.0): self.critical_receive_proof = 1.0
					log_backlog.append("> Critical Receive Proof increased to " + String(self.critical_receive_proof))
		
		critical_status.append(critical)
		print("Luck " + String(i) + ": " + ("CRITICAL" if critical else "normal"), " ", [hit, critical_chance])
		while (log_backlog.size() > 0): print(log_backlog.pop_front())
	print ("... Turn End ...")
	if (what == 'a'):
		self.critical_deal_proof = max(self.critical_deal_proof - self.critical_deal_proof_decay, 0.0)
		print("Critical Deal Proof reduced to " + String(self.critical_deal_proof))
	elif (what == 'd'):
		self.critical_receive_proof = max(self.critical_receive_proof - self.critical_receive_proof_decay, 0.0)
		print("Critical Receive Proof reduced to " + String(self.critical_receive_proof))
	return critical_status

func simulate(times: int, reroll: bool = false):
	var criticals_dealt = {}
	var criticals_received = {}
	for i in self.party_luck.size():
		criticals_dealt[i] = 0
		criticals_received[i] = 0
	for i in times:
		print("[ Simulation " + String(i + 1) + " ]")
		if (reroll == true):
			self.reroll()
		var attack = self.attack()
		for ii in attack.size():
			if (attack[ii] == true): criticals_dealt[ii] += 1
		var defense = self.defense()
		for ii in defense.size():
			if (defense[ii] == true): criticals_received[ii] += 1
		print("")
	print("--- Simulation finished. ---")
	print("Criticals dealt:")
	for i in self.party_luck.size():
		if (!reroll): print(self.party_luck[i], ": ", criticals_dealt[i])
		else: print("Position " + String(i), ": ", criticals_dealt[i])
	print("Criticals received:")
	for i in self.party_luck.size():
		if (!reroll): print(self.party_luck[i], ": ", criticals_received[i])
		else: print("Position " + String(i), ": ", criticals_received[i])
	
