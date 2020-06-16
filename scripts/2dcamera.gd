extends Camera2D

export var move_speed = 400
var initial_position
var game_resolution

func _ready():
	self.initial_position = self.global_position
	self.game_resolution = {
		'width': ProjectSettings.get_setting("display/window/size/width"),
		'height': ProjectSettings.get_setting("display/window/size/height")
	}

func _process(delta):
	if !self.find_parent("Scene*").check_event_processor_active():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left"):
			self.move(Vector2.LEFT, delta)
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right"):
			self.move(Vector2.RIGHT, delta)
		if Input.is_action_pressed("move_up") or Input.is_action_pressed("ui_up"):
			self.move(Vector2.UP, delta)
		if Input.is_action_pressed("move_down") or Input.is_action_pressed("ui_down"):
			self.move(Vector2.DOWN, delta)
	
func move(direction, delta):
	var next = self.global_position + (move_speed * direction * delta)
	if direction == Vector2.LEFT and (next.x - self.initial_position.x) < self.limit_left:
		return
	elif direction == Vector2.RIGHT and (next.x + self.game_resolution.width / 2) > self.limit_right:
		return
	if direction == Vector2.UP and (next.y - self.initial_position.y) < self.limit_top:
		return
	elif direction == Vector2.DOWN and (next.y + self.game_resolution.height / 2) > self.limit_bottom:
		return
	else:
		self.global_position = next
