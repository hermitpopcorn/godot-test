extends KinematicBody2D

class_name Player

export(int) var walk_speed = 350 # pixels per second

var linear_vel = Vector2()

export(String, "up", "down", "left", "right") var facing = "down"

var anim = ""
var new_anim = ""

enum { STATE_IDLE, STATE_WALKING, STATE_BLOCKED }

var state = STATE_IDLE

func _physics_process(_delta):
	## PROCESS STATES
	match state:
		STATE_BLOCKED:
			new_anim = "idle_" + facing
			pass
		STATE_IDLE:
			if (
				Input.is_action_pressed("move_down") or
				Input.is_action_pressed("move_left") or
				Input.is_action_pressed("move_right") or
				Input.is_action_pressed("move_up")
				or
				Input.is_action_pressed("ui_down") or
				Input.is_action_pressed("ui_left") or
				Input.is_action_pressed("ui_right") or
				Input.is_action_pressed("ui_up")
			):
				state = STATE_WALKING
				print ("WALK!")
			pass
		STATE_WALKING:
			linear_vel = move_and_slide(linear_vel)
			
			var target_speed = Vector2()
			
			if (Input.is_action_pressed("move_down") or Input.is_action_pressed("ui_down")):
				target_speed += Vector2.DOWN
			if (Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left")):
				target_speed += Vector2.LEFT
			if (Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right")):
				target_speed += Vector2.RIGHT
			if (Input.is_action_pressed("move_up") or Input.is_action_pressed("ui_up")):
				target_speed += Vector2.UP
			
			target_speed *= self.walk_speed
			linear_vel = target_speed
			
			_update_facing()
			
			if linear_vel.length() > 5:
				new_anim = "walk_" + facing
			else:
				goto_idle()
			pass
	
	## UPDATE ANIMATION
	if new_anim != anim:
		anim = new_anim
		#$anims.play(anim)
	pass

func block():
	state = STATE_BLOCKED

func unblock():
	state = STATE_IDLE

## HELPER FUNCS
func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + facing
	state = STATE_IDLE

func _update_facing():
	if Input.is_action_pressed("move_left"):
		facing = "left"
	if Input.is_action_pressed("move_right"):
		facing = "right"
	if Input.is_action_pressed("move_up"):
		facing = "up"
	if Input.is_action_pressed("move_down"):
		facing = "down"
