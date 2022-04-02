extends PartyUnit

func _init():
	name = "Kaput Hunter"
	level = 1
	maxhp_curve = { 1: 130 }
	maxap_curve = { 1: 160 }
	atk_curve = { 1: 11 }
	def_curve = { 1: 6 }
	hit_curve = { 1: 12 }
	eva_curve = { 1: 8 }
	
	full_heal()
	
	weapon = preload("res://data/weapons/bayonets/cross_knife.tres")
	
	battler_textures = preload("res://data/party_units/kaput_hunter/kaput_hunter-BattlerTextureRect.tscn").instance()

