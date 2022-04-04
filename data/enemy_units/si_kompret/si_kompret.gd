extends EnemyUnit

func _init(assign_name = null):
	name = "Si Kompret"
	if assign_name != null: name = assign_name
	maxhp = 95
	atk = 15
	def = 9
	hit = 8
	eva = 3
	full_heal()
