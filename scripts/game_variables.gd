extends Node

var variables: Dictionary = {}

func _ready():
	self.reset()

func get(key):
	if (self.variables.has(key)):
		return self.variables[key]
	else:
		return null

func set(key, value):
	self.variables[key] = value

func reset():
	self.variables = {}
	print ("[VARS] game variables (re)initialized")
