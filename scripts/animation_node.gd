extends Node2D

# returns the hit frame in seconds
func play(what: String) -> float:
	if what == null: what = "hit"
	$AnimationPlayer.play(what)
	match what:
		"hit": return 0.3
		"pierce": return 0.2
	return 0.2
