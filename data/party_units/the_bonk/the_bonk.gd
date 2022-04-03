extends PartyUnit

func _init():
	name = "The Bonk"
	level = 1
	maxhp_curve = { 1: 200 }
	maxap_curve = { 1: 140 }
	atk_curve = { 1: 9 }
	def_curve = { 1: 12 }
	hit_curve = { 1: 7 }
	eva_curve = { 1: 5 }
	
	full_heal()
	
	weapon = preload("res://data/weapons/comically_large_spoons/plastic_spoon.tres")
	
	battler_textures = preload("res://data/party_units/the_bonk/the_bonk-BattlerTextureRect.tscn").instance()

