extends PartyUnit

func _init():
	maxhp_curve = {
		1: 250
	}
	maxap_curve = {
		1: 200
	}
	weapon = preload("res://data/weapons/shinai_n_suru.tscn").instance()
