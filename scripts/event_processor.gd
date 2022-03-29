extends Node

class_name EventProcessor

onready var message_box: Node = $MessageBoxUILayer/MessageBox
onready var display_container: Node = $EventDisplayLayer/DisplayContainer
onready var background_container: Node = $EventDisplayLayer/DisplayContainer/BackgroundContainer
onready var sprites_container: Node = $EventDisplayLayer/DisplayContainer/SpriteContainer
onready var audio_container: Node = $AudioContainer
onready var tweens_container: Node = $TweensContainer
onready var wait_timer: Timer = $WaitTimer

var camera
var sequence
var current_index = -1
var running = false
var active = false
var nextable = true

var sprites = {}
var audio = {}
var sprite_tweens = {}

var wait_queue = []

signal sequence_finished
signal sequence_paused
signal hover_on
signal hover_off

func _ready():
	self.message_box.hide(false)
	
	# debugging tools
	$EventDisplayLayer/SequenceIndexDisplay.visible = OS.is_debug_build()

func set_camera(new_camera):
	self.camera = new_camera

func set_sequence(new_sequence: Array):
	self.sequence = new_sequence

func make_tween(node: Node):
	var tween: Tween = Tween.new()
	tween.connect("tween_all_completed", self, "_on_sprite_tween_completed", [tween, node])
	self.tweens_container.add_child(tween)
	
	# register to container variable
	if !(self.sprite_tweens.has(node)):
		self.sprite_tweens[node] = [];
	self.sprite_tweens[node].append(tween)
	
	return tween 

func start():
	if OS.is_debug_build(): print("[EVPR] sequence started")
	
	self.reset()
	self.resume()

func resume():
	self.running = true
	self.active = true
	
	self._advance_sequence()

func pause():
	self.running = false
	if OS.is_debug_build(): print("[EVPR] sequence paused")
	emit_signal("sequence_paused")

func reset():
	self.running = false
	self.current_index = -1
	if OS.is_debug_build(): $EventDisplayLayer/SequenceIndexDisplay.set_text(String(self.current_index))
	self.active = false

func _advance_sequence():
	# clear wait
	self.wait_timer.stop()

	self.current_index += 1
	if OS.is_debug_build(): $EventDisplayLayer/SequenceIndexDisplay.set_text(String(self.current_index))
	
	# if there are still more to process
	if (self.current_index < self.sequence.size()):
		self._execute_sequence(self.current_index)
	# if end of sequence
	else:
		self.running = false
		self.active = false
		if OS.is_debug_build(): print("[EVPR] sequence finished")
		emit_signal("sequence_finished")

func _execute_sequence(index: int):
	if OS.is_debug_build(): print("[EVPR] executing sequence index " + str(index))
	var entry = self.sequence[index]
	
	# array will be converetd to dictionary and be processed in the following if block
	if (entry is Array):
		entry = self.translate_shortcode(entry)
	
	if (entry is Dictionary):
		match entry.command:
			"hide_message_box":
				self.message_box.hide()
			"show_message_box":
				self.message_box.show()
			"sprite":
				self.show_sprite(entry.options)
			"container":
				self.show_container(entry.options)
			"audio":
				self.play_audio(entry.options)
			"pause_sequence":
				self.pause()
			_:
				push_error("invalid event command")
				self._advance_sequence()
	elif (entry is String):
		self.show_text(entry)
	elif (entry is float):
		self.wait(entry)
	elif (entry is FuncRef):
		entry.call_func()
		if OS.is_debug_build(): print("[EVPR] next by callable finish")
		self._advance_sequence()

func wait(length: float):
	self.wait_timer.wait_time = length
	self.wait_timer.start()

func show_text(text: String):
	var options = {}

	var separator_position = text.find("|")
	if (separator_position > 0):
		var split_text = text.split("|")
		
		var hue = 0
		var hue_separator_position = split_text[0].find("#")
		if (hue_separator_position > 0):
			var hue_split_text = split_text[0].split("#")
			hue = hue_split_text[1].to_float()
			split_text[0] = hue_split_text[0]
		
		options["nameplate"] = {
			"name": split_text[0],
			"hue": hue
		}
		text = split_text[1]

	self.message_box.show_text(text, options)

func play_audio(options: Dictionary):
	if (options.action == "bgm"):
		# stop current BGM if different
		if (self.bgm_player.is_playing()):
			if (self.audio["bgm"] != options.src):
				self.bgm_player.stop()
			else:
				# cancel if same
				return
		self.bgm_player.stream = options.src if options.src is Resource else load(options.src)
		self.audio["bgm"] = options.src
		self.bgm_player.play()
		if OS.is_debug_build(): print("[EVPR] next by audio play (bgm)")
	elif (options.action == "voice" || options.action == "sfx"):
		# assign from options if given, or set default
		var key = options.action
		if (options.has("key")): key = options.key
		# remove existing audio (with same key) beforehand
		if (self.audio.has(key)):
			self.audio[key].queue_free()
			self.audio_container.remove_child(self.audio[key])
			self.audio.erase(key)
		# create new AudioStreamPlayer
		var new_audio = AudioStreamPlayer.new()
		new_audio.stream = options.src if options.src is Resource else load(options.src)
		match (options.action):
			"voice": new_audio.bus = "Voice"
			"sfx": new_audio.bus = "SFX"
		self.audio[key] = new_audio
		self.audio_container.add_child(new_audio)
		new_audio.connect("finished", self, "_on_audio_finish", [options.action, key])
		new_audio.play()
		if OS.is_debug_build(): print("[EVPR] next by audio play (" + options.action + ")")
	else:
		push_warning("invalid audio action: " + options.action)
	self._advance_sequence()

func _on_audio_finish(type: String, key: String):
	if (type == "voice" || type == "sfx"):
		self.audio[key].queue_free()
		self.audio_container.remove_child(self.audio[key])
		self.audio.erase(key)

func show_container(options: Dictionary):
	var target
	match (options.key):
		"sprites":
			target = self.sprites_container
		"background", "bg":
			target = self.background_container
	
	self._manipulate_sprite(target, options)

func show_sprite(options: Dictionary):
	var sprite: Node
	
	# if new (by create or take) sprite
	if (options.action == "show" || options.action == "take"):
		# remove existing one beforehand
		if (self.sprites.has(options.key)):
			self.sprites[options.key].queue_free()
			if (options.key.substr(0, 2) == "bg"):
				self.background_container.remove_child(self.sprites[options.key])
			else:
				self.sprites_container.remove_child(self.sprites[options.key])
			self.sprites.erase(options.key)
		# create new sprite
		if (options.action == "show"):
			sprite = TextureRect.new()
			sprite.texture = options.src if options.src is Resource else load(options.src)
			sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if (options.key.substr(0, 2) == "bg"):
				sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				sprite.expand = false
				sprite.rect_size = Vector2(int(ProjectSettings.get_setting("display/window/size/width")), int(ProjectSettings.get_setting("display/window/size/height")))
			else:
				sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				sprite.expand = true
				sprite.rect_min_size.x = sprite.texture.get_width()
				sprite.rect_min_size.y = min(sprite.texture.get_height(), int(ProjectSettings.get_setting("display/window/size/height")))
				sprite.set_pivot_offset(Vector2(sprite.rect_min_size.x / 2, sprite.rect_min_size.y / 2))
			if (options.has("scale")):
				sprite.rect_scale = options.scale
			else:
				sprite.rect_scale = Vector2(1, 1)
			#if (options.has("z_index")):
				#sprite.z_index = options.z_index
			if (options.has("position")):
				sprite.rect_position = self.calculate_position(sprite, options.position)
			sprite.modulate.a = 0 # start invisible
		# take existing sprite
		elif (options.action == "take"):
			sprite = options.node
			sprite.modulate.a = 0
			sprite.visible = true
			(sprite.get_parent()).remove_child(sprite)
		
		# add to container
		if (options.key.substr(0, 2) == "bg"):
			# add to bg container
			self.background_container.add_child(sprite)
		else:
			# add to sprite contianer
			self.sprites_container.add_child(sprite)
		# register sprite to collection
		self.sprites[options.key] = sprite
	# if manipulating existing sprite
	else:
		sprite = self.sprites[options.key]
	
	self._manipulate_sprite(sprite, options)

func calculate_position(sprite: Node, new_position: Vector2):
	# only applies to control nodes
	if (!(sprite is Control)): return new_position
	var pivot_offset = sprite.get_pivot_offset()
	return Vector2(new_position.x - pivot_offset.x, new_position.y - pivot_offset.y)

func _manipulate_sprite(target: Node, options: Dictionary):
	var duration = 1; if options.has("duration"): duration = options.duration
	var delay = 0; if options.has("delay"): delay = options.delay
	var wait_for_animation = true; if (options.has("wait")): wait_for_animation = options.wait
	
	match options.action:
		"show", "hide":
			# interpolate visibility
			var tween = self.make_tween(target)
			tween.interpolate_property(target, "modulate:a", target.modulate.a, (1 if options.action == "show" else 0), duration, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, delay)
			if (wait_for_animation): self.wait_queue.push_back(tween)
			tween.start()
		"change":
			if (!(target is TextureRect) && !(target is Sprite)): push_error("'Change' event called on invalid type")
			target.texture = options.src if options.src is Resource else load(options.src)
		"move":
			# move according to options
			var tween = self.make_tween(target)
			if (options.has("scale")):
				tween.interpolate_property(target, "rect_scale" if target is Control else "scale", target.rect_scale if target is Control else target.scale, options.scale, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, delay)
			if (options.has("rotation")):
				tween.interpolate_property(target, "rect_rotation" if target is Control  else "rotation", target.rect_rotation if target is Control else target.rotation, options.rotation, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, delay)
			if (options.has("position")):
				tween.interpolate_property(target, "rect_position" if target is Control  else "position", target.rect_position if target is Control else target.position, self.calculate_position(target, options.position), duration, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, delay)
			if (options.has("opacity")):
				tween.interpolate_property(target, "modulate:a", target.modulate.a, options.opacity, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, delay)
			if (wait_for_animation): self.wait_queue.push_back(tween)
			tween.start()
		"dim", "light":
			var color = Color("#7c7c7c")
			if (options.action == "light"): color = Color("#ffffff")
			if (!options.has("duration")): duration = 0.2 # minimum duration
			# keep opacity
			var alpha = target.modulate.a
			color.a = alpha
			var tween = self.make_tween(target)
			tween.interpolate_property(target, "modulate", target.modulate, color, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, delay)
			if (wait_for_animation): self.wait_queue.push_back(tween)
			tween.start()
		"stop":
			for tween in self.sprite_tweens[target]: tween.stop_all()
		"resume":
			for tween in self.sprite_tweens[target]: tween.resume_all()
		"clear":
			for tween in self.sprite_tweens[target]: tween.remove_all()
			self.sprite_tweens[target].clear()
		"reset":
			target.rect_scale = Vector2(1, 1)
			target.rect_rotation = 0
			target.rect_position = Vector2(0, 0)
		"remove":
			target.queue_free()
	
	# immediately advance if queue is empty
	if (self.wait_queue.size() == 0):
		if OS.is_debug_build(): print("[EVPR] next by zero wait queue show sprite/container")
		self._advance_sequence()

func translate_shortcode(shortcode: Array):
	var command: String = shortcode[0]
	var options: Dictionary
	var translated: Dictionary

	if (!command.begins_with(">")): push_error("Shortcode string didn't start with '>'.")
	if (shortcode.size() == 2):
		options = shortcode[1]

	# main command
	var split_command: Array = command.split("|")
	translated = { "command": split_command[0].trim_prefix(">") }

	# options (action & key)
	if (split_command.size() > 1):
		options.action = split_command[1]
		translated.options = options
		if (split_command.size() >= 3):
			translated.options.key = split_command[2]
	# additional options (skip wait)
	if (split_command.size() >= 4):
		if (translated.command != "voice"):
			if (split_command[3] == "nowait"):
				translated.options.wait = false
			elif (split_command[3] == "wait"):
				translated.options.wait = true

	return translated

func _on_next(sender = null):
	if (self.running && self.nextable):
		# cancel if queue is not empty
		if (self.wait_queue.size() > 0): return false

		if OS.is_debug_build(): print("[EVPR] next by next")
		self._advance_sequence()

func _on_MessageBox_finished_typing(tags = null):
	if ("no_confirmation" in tags):
		self._advance_sequence()

func _on_MessageBox_finished_tweening():
	if (self.wait_queue.size() == 0 && self.running):
		if OS.is_debug_build(): print("[EVPR] next by mbox finished tweening")
		self._advance_sequence()

func _on_sprite_tween_completed(tween: Tween, node: Node):
	# remove from tween registry
	self.sprite_tweens[node].erase(tween)
	# delete tween
	tween.queue_free()
	
	if (self.wait_queue.has(tween)):
		self.wait_queue.erase(tween)
		if (self.wait_queue.size() == 0 && self.running):
			if OS.is_debug_build(): print("[EVPR] next by sprite tween completed")
			self._advance_sequence()

func _on_WaitTimer_timeout():
	if OS.is_debug_build(): print("[EVPR] next by wait timeout")
	self._advance_sequence()

func _on_hover(emitter): emit_signal("hover_on", emitter)
func _off_hover(emitter): emit_signal("hover_off", emitter)
