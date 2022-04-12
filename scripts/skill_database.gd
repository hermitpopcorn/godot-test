extends Node

var skill_registry: Dictionary = {}

func _init():
	register_skills("res://data/skills")

func register_skills(directory: String):
	var dir = Directory.new()
	if dir.open(directory) == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename != "." and filename != "..":
				if dir.current_is_dir():
					register_skills(filename)
				else:
					if filename.ends_with(".gd"):
						var skill = load(dir.get_current_dir() + "/" + filename).new()
						skill_registry[skill.key] = skill
			filename = dir.get_next()
	else:
		push_error("An error occurred when trying to access the skills folder.")

func get_skill(key: String):
	if skill_registry.has(key):
		return skill_registry[key]
	else:
		push_error("No skill found for key " + key)
	return null
