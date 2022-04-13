extends PartyUnit

func _init():
	name = "rif/KAIZER"
	level = 1
	maxhp_curve = { 1: 75 }
	maxap_curve = { 1: 110 }
	atk_curve = { 1: 13 }
	def_curve = { 1: 6 }
	hit_curve = { 1: 9 }
	eva_curve = { 1: 6 }
	skills_curve = { 1: [SkillDatabase.get_skill('break'), SkillDatabase.get_skill('harden')] }
	
	full_heal()
	
	weapon = preload("res://data/weapons/laser_guns/butterfly.tres")
	
	battler_textures = preload("res://data/party_units/rifkaizer/rifkaizer-battler_textures.tscn").instance()

