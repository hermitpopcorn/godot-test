extends PartyUnit

func _init():
	name = "Paul Kirigaya"
	maxhp_curve = { 1: 170 }
	maxap_curve = { 1: 150 }
	atk_curve = { 1: 12 }
	def_curve = { 1: 9 }
	hit_curve = { 1: 8 }
	eva_curve = { 1: 6 }
	
	full_heal()
	
	weapon = preload("res://data/weapons/dual_swords/shinai_n_suru.tres")
	
	battler_panel_texture_rect = preload("res://data/party_units/paul_kirigaya/paul_kirigaya-BattlerTextureRect.tscn").instance()
